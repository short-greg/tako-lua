require 'ocnn.pkg'
require 'oc.nerve'
require 'oc.emission'
require 'oc.class'
require 'oc.ops.tensor'


do
  --- Nerve that flattens the input for batch mode.
  -- The output  is a tensor of N feature vectors.
  -- N is determined by the first size of the first 
  -- dimension of the input
  -- @param numClasses - Total number of classes - integer
  -- @param zeroStart - Whether the class numbering starts 
  -- from zero or not
  local FlattenBatch, parent = oc.class(
    'ocnn.FlattenBatch',
    oc.Nerve
  )
  ocnn.FlattenBatch = FlattenBatch

  function ocnn.FlattenBatch:__init()
    parent.__init(self)
  end
  
  function ocnn.FlattenBatch:out(input)
    return input:view(input:size(1), input:stride(1))
  end
  
  function ocnn.FlattenBatch:grad(input, gradOutput)
    return gradOutput:viewAs(input)
  end
end


do
  --- Nerve that flattens the input.
  -- The output  is a tensor of 1 feature vector.
  -- @input  torch.Tensor
  -- @output torch.Tensor (1 dimensional)
  local Flatten, parent = oc.class(
    'ocnn.Flatten',
    oc.Nerve
  )
  ocnn.Flatten = Flatten

  function ocnn.Flatten:__init()
    parent.__init(self)
  end
  
  function ocnn.Flatten:updateOutput(input)
    local output = input:view(input:nElement())
    self.output = output
    return output 
  end
  
  function ocnn.Flatten:updateGradInput(input, gradOutput)
    local gradInput = gradOutput:view(input:size())
    self.gradInput = gradInput
    return self.gradInput
  end
end


do
  --- View a tensor to be of the same dimension as another
  -- tensor.  Can be used to undo a flatten operation.
  -- @input  Emission{torch.Tensor, torch.Tensor}
  -- @output torch.Tensor
  local ViewAs, parent = oc.class(
    'ocnn.ViewAs',
    oc.Nerve
  )
  ocnn.ViewAs = ViewAs
  
  function ViewAs:__init()
    parent.__init(self)
  end

  function ViewAs:updateOutput(input)
    local output = input[1]:view(input[2]:size())
    self.output = output
    return output 
  end
  
  function ViewAs:updateGradInput(input, gradOutput)
    local gradInput = oc.Emission()
    gradInput:pushBack(gradOutput:view(input[1]:size()))
    self.gradInput = gradInput
    return self.gradInput
  end
end


do
  --- Concatenate an emission of tensors together into 
  -- åone tensor.
  -- @input oc.Emission{torch.Tensor}
  -- @output torch.Tensor
  local Concat, parent = oc.class(
    'ocnn.Concat',
    oc.Nerve
  )
  ocnn.Concat = Concat
  
  function Concat:__init(dim)
    parent.__init(self)
    self._dim = dim
  end
  
  function Concat:updateOutput(input)
    local output = torch.cat(input:totable(), self._dim)
    self.output = output
    return output 
  end
  
  function Concat:updateGradInput(input, gradOutput)
    local curStart = 1
    local curSize
    local gradInput = oc.Emission()
    for i=1, #input do
      curSize = input[i]:size(self._dim)
      gradInput:pushBack(
        gradOutput:narrow(self._dim, curStart, curSize)
      )
      curStart = curStart + curSize
    end
    self.gradInput = gradInput
    return gradInput
  end
end


do
  --- Get the sub tensor of a tensor that has 
  -- been passed in
  -- @input torch.Tensor
  -- @output torch.Tensor
  local Sub, parent = oc.class(
    'ocnn.Sub',
    oc.Nerve
  )
  ocnn.Sub = Sub

  function Sub:__init(dim, first, count)
    --! @param dim - The dimension to concatenate on
    parent.__init(self)
    self._dim = dim
    self._first = first
    self._count = count
    assert(
      self._count >= 1, 'The number to retrieve must be greater than 1'
    )
  end
  
  function Sub:updateOutput(input)
    local output = input:narrow(
      self._dim, self._first, self._count
    )
    self.output = output
    return output 
  end
  
  function Sub:updateGradInput(input, gradOutput)
    local curStart = 1
    local curSize
    local gradInput = torch.Tensor():resizeAs(input):zero()
    gradInput:narrow(self._dim, self._first, self._count):add(
      gradOutput
    )
    self.gradInput = gradInput
    return gradInput
  end
end


do

  --- Concatenate multiple tensors together of
  -- which some may be batch tensors and some 
  -- may not be.
  -- It repeats the tensor for as many elements
  -- there are in the batch tensors
  -- It is able to deal with combinations of batch 
  -- and non-batch tensors but there will be
  -- no effect if all are non-batch tensors
  --
  -- @input oc.Emission{torch.Tensor} (batch or not batch)
  -- each BatchTensor and each non-batch tensor
  -- must be of the same number of dimensions
  -- and non-batch tensors must only be a maximum
  -- of one dimension smaller than batch tensors
  --
  -- @output torch.Tensor
  local BatchConcat, parent = oc.class(
    'ocnn.BatchConcat',
    parent
  )
  
  function BatchConcat:_calcMaxDim(input)
    local maxDim = 0
    local size = 0
    for i=1, #input do
      local curDim = input[i]:dim()
      if curDim > maxDim then
        maxDim = curDim
        size = input[i]:size(curDim)
      end
      maxDim = math.max(maxDim, input[i]:dim())
    end
    return maxDim, size
  end
  
  function BatchConcat:_getRepeatTable(dim)
    local tb = {}
    for i=1, dim - 1 do
      table.insert(tb, 1)
    end
    return tb
  end
  
  function BatchConcat:_resize(input)
    --! @brief resize the input to be of the same
    --!        sizes as inputs that are batch tensors
    local dim, size = self:_calcMaxDim(input)
    local reshaped = oc.Emission()
    for i=1, #input do
      if input[i]:dim() == dim then
        reshaped:pushBack(input[i])
      else
        reshaped:pushBack(
          torch.repeatTensor(
            oc.ops.tensor.doBatchView(input[i]), 
            size, table.unpack(self:_getRepeatTable(dim))
          )
        )
      end
    end
    return reshaped
  end
  
  function BatchConcat:_addUp(input, gradOutput)
    local result = oc.Emission()
    local dim, size = self:_calcMaxDim(input)
    for i=1, #input do
      if input[i]:dim() == dim then
        result:pushBack(gradOutput[i])
      else
        result:pushBack(
          gradOutput[i]:sum(1):viewAs(input[i])
        )
      end
    end
    return result
  end
  
  function BatchConcat:updateOutput(input)
    local reshaped = self:_resize(input)
    return parent.updateOutput(self, reshaped)
  end
  
  function BatchConcat:updateGradInput(input, gradOutput)
    local gradInput = parent.updateGradInput(
      self, input, gradOutput
    )
    gradInput = self:_addUp(input, gradInput)
    self.gradInput = gradInput
    return gradInput
  end
end
