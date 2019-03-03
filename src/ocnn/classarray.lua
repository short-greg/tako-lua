require 'ocnn.pkg'
require 'oc.nerve'
require 'nn'


do
  --- ClassArray chooses a nerve to send the input
  -- through based on the class of the input.
  --
  -- @usage 
  --    numClasses = 2
  --    nn.Linear(2, 2) .. oc.Onto(oc.my.class) ..
  --       ocnn.ClassArray(numClasses, nn.Linear(2, 2))
  -- 
  -- @input {classIndex, nerveInput}
  -- @output moduleInput processed depending on the
  -- class
  local ClassArray, parent = oc.class(
    'ocnn.ClassArray', oc.Nerve
  )
  ocnn.ClassArray = ClassArray

  function ClassArray:__init(k, nerves)
    --! @param k
    --! @param processor
    assert(k > 0, 'Argument k must be greater than 0')
    parent.__init(self)
    self.k = k or 1
    if torch.type(nerves) == 'table' then
      self._modules = nerves
    else
      self._modules = {}
      for i=1, k do
        self._modules[i] = oc.nerve(nerves):clone()
      end
    end
    self._moduleInputs = {}
  end

  function ClassArray:out(input)
    local class = input[1]
    local moduleInput = input[2]
    
    local curOutput
    local output
    local sortedClass, index = torch.sort(class)
    local sortedInputs = moduleInput:index(1, index)
    local revIndex = index:clone():zero()
    for i=1, index:size(1) do
      revIndex[ index[i] ] = i
    end
    local curPos = 1
    for i=1, self.k do
      local numClass = class:eq(i):sum()
      if numClass > 0 then
        local curInput = sortedInputs:narrow(
          1, curPos, numClass
        )
        self._modules[i]:inform(curInput)
        
        self._moduleInputs[i] = curInput
        local curOutput = self._modules[i]:probe()
        if not output then
          local outputSizeBase = curOutput:size()
          outputSizeBase[1] = class:size(1) 
          output = torch.Tensor():typeAs(
            curOutput
          ):resize(outputSizeBase):zero()
        end
        output:narrow(1, curPos, numClass):add(curOutput)
        curPos = curPos + numClass
      else
        self._moduleInputs[i] = nil
      end
    end
    output = output:index(1, revIndex)
    self.output = output
    self._revIndex = revIndex
    self._index = index
    self._sortedInputs = sortedInputs
    self._sortedClass = sortedClass
    return output
  end

  function ClassArray:grad(input, gradOutput)
    local class = input[1]
    -- local moduleInput = input[2]
    local curGradInput
    local moduleGradInput
    
    --! Need to sort the gradient by class
    local sortedGrad = gradOutput:index(1, self._index)
    local curPos = 1
    for i=1, self.k do
      local numClass = class:eq(i):sum()
      if numClass > 0 then
        local curGradOut = sortedGrad:narrow(
          1, curPos, numClass
        )
        
        self._modules[i]:informGrad(curGradOut)
        local curGradIn = self._modules[i]:probeGrad()
        
        if not moduleGradInput then
          local sizeBase = curGradIn:size()
          sizeBase[1] = class:size(1) 
          moduleGradInput = torch.Tensor():typeAs(
            curGradIn
          ):resize(sizeBase):zero()
        end
        
        moduleGradInput:narrow(
          1, curPos, numClass
        ):add(curGradIn)
        curPos = curPos + numClass
      end
    end
    moduleGradInput = moduleGradInput:index(
      1, self._revIndex
    )
    local gradInput = {
      nil, moduleGradInput
    }
    self.gradInput = gradInput
    return gradInput
  end

  function ClassArray:accGradParameters(input, gradOutput)
    for i=1, self.k do
      if self._moduleInputs[i] ~= nil then
        self._modules[i]:accumulate()
      end
    end
  end
  
  function ClassArray:rev()
    local modules = {}
    for i=1, #self._modules do
      table.insert(
        modules, oc.Reverse(self._modules[i])
      )
    end
    return ocnn.ClassArray(self.k, modules)
  end
end



--!#　TODO: Container but it does not inform inputs in 
--!          updateGradInput, accumulate
do
  --- Organize a tensor into a table with a list of 
  -- indices, one associated with each input
  -- 
  -- @input {index, tensorToOrganize}
  -- @output {{reversed index or nil}, 
  --          {organized tensor or nil}}
  --  The output reverse index makes it possible
  --  to regenerate the input (tensorToOrganize)
  --  if there are no entries for a particular
  --  index the output at that index will be nil
  local IndexArray, parent = oc.class(
    'ocnn.IndexArray', oc.Nerve
  )
  ocnn.IndexArray = IndexArray

  function IndexArray:__init(k)
    assert(k > 0, 'Argument k must be greater than 0')
    parent.__init(self)
    self.k = k or 1
  end

  function IndexArray:updateOutput(input)
    local class = input[1]
    local moduleInput = input[2]
    local curOutput
    local curOrderOutput

    local value = {}
    local order = {}
    local output = {
      order, value
    }

    local sortedClass, index = torch.sort(class)
    local sortedInputs = moduleInput:index(1, index)
    self._index = index
    local revIndex = torch.Tensor():typeAs(
      index
    ):resizeAs(index):zero()
    for i=1, index:size(1) do
      revIndex[index[i]] = i
    end
    local curPos = 1

    for i=1, self.k do
      -- Number of items to retrieve for class
      local numClass = class:eq(i):sum()
      local curInput = nil
      local curOrder = nil
      if numClass > 0 then
        curInput = sortedInputs:narrow(1, curPos, numClass)
        curOrder = revIndex:narrow(1, curPos, numClass)
      --[[
      else
        --! TODO: Specify the type
        curInput = torch.Tensor():typeAs(moduleInput)
        curOrder = torch.Tensor():typeAs(index)
      --]]
      end
      value[i] = curInput
      order[i] = curOrder
      curPos = curPos + numClass
    end

    self.output = output
    self._revIndex = revIndex
    return output
  end

  function IndexArray:updateGradInput(input, gradOutput)
    local class = input[1]
    -- local moduleInput = input[2]
    local curGradInput
    local moduleGradInput
    local gradInput
    local curPos = 1
    
    local gradNotNil = {}
    for i=1, self.k do
      if gradOutput[2][i] ~= nil then
        table.insert(gradNotNil, gradOutput[2][i])
      end
    end
    -- A) concatenate gradOutput
    -- B) concatenate the indices
    if #gradNotNil > 0 then
      local gradOutputCat = torch.cat(
        gradNotNil, 1
      )
      gradInput = {
        nil, gradOutputCat:index(1, self._revIndex)
      }
    else
      gradInput = {}
    end
    self.gradInput = gradInput
    return gradInput
  end
end
