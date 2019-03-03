require 'oc.class'


do
  --- Module that checks whether a tensor is valid
  -- @usage
  -- 1) Checking whether a tensor is valid
  -- 2) For generating modules whose arguments have
  --    not been fully defined like with 
  --    nn.Linear():d(nil, 16) <- must figure out what the
  --    input size is
  
  -- @usage
  -- tensor = ocnn.CheckTensor(1, 1, 1):type('double'):range(-1, 1)
  -- tensor:sample() -> Tensor{{{-1.0}}} 
  --
  -- @input - Tensor
  -- @output - Tensor
  -- raises error if tensor does not meet the conditions specified
  local CheckTensor = oc.class(
    'ocnn.CheckTensor'
  )
  
  local SIZE_POS = 1
  local TYPE_POS = 2
  local MINVAL_POS = 3
  local MAXVAL_POS = 4
  
  function CheckTensor:__init(...)
    self._size = nil
    self._min = nil
    self._max = nil
    self._type = nil
    self._checklist = {}
    self:size(...)
  end
  
  function CheckTensor:out(input)
    for k, checkFunc in pairs(self._checklist) do
      checkFunc(self, input)
    end
    return input
  end

  function CheckTensor:grad(
    input, gradOutput  
  )
    return gradOutput
  end

  --- generate a sample tensor that passes the
  -- check conditions
  -- @return torch.Tensor
  function CheckTensor:sample()
    local tensor
    if self._checklist[SIZE_POS] then
      local size = torch.LongStorage(self._size.n)
      for i=1, self._size.n do
        if self._size[i] then
          size[i] = self._size[i]
        else
          size[i] = 1
        end
      end
      tensor = torch.ones(size)
    else
      tensor = torch.Tensor{1}
    end
    
    if self._checklist[TYPE_POS] then
      tensor:type(self._typeString)
    end
    
    if self._checklist[MINVAL_POS] then
      tensor:mul(self._min)
    elseif self._checklist[MAXVAL_POS] then
      tensor:mul(self._max)
    end
    return tensor
  end

  --- specify the size of each dimension of the tensor
  -- and the number of dimensions the tensor should have
  -- to avoid specifying the dimension for a particular
  -- dimension set that dimension size to nil
  function CheckTensor:size(...)
    self._size = table.pack(...)
    if self._size.n > 0 then
      self._checklist[SIZE_POS] = self.sizeCheck
    else
      self._checklist[SIZE_POS] = nil
    end
    return self
  end
  
  --- Ensure that the type of the input is the proper type
  function CheckTensor:typeCheck(input)
    assert(
      input:type() == self._typeString,
      string.format(
        'The type of input %s does not match the '..
        'CheckTensor type %s', input:type(), self._typeString
      )
    )
  end

  --- Ensure that no values int he input are less
  -- than the specified minimum value
  function CheckTensor:minCheck(input)
    local inputMin = input[input:lt(self._min)]:min()
    assert(
      inputMin >= self._min,
      string.format(
        'The minimum value in the input %d is below the  '..
        'designated min %d', inputMin, self._min
      )
    )
  end

  function CheckTensor:type(typeString)
    self._typeString = typeString
    if typeString ~= '' then
      self._checklist[TYPE_POS] = self.typeCheck
    else
      self._checklist[TYPE_POS] = nil
    end
    return self
  end
  
  function CheckTensor:range(min, max)
    self._min = min
    self._max = max

    if min ~= nil then
      self._checklist[MINVAL_POS] = self.minCheck
    else
      self._checklist[MINVAL_POS] = nil
      
    end
    
    if max ~= nil then
      self._checklist[MAXVAL_POS] = self.maxCheck
    else
      self._checklist[MAXVAL_POS] = nil
    end
    return self
  end

  --- Ensure that no values in the input are greater
  -- than the specified maximum value
  function CheckTensor:maxCheck(input)
    local inputMax = input[input:gt(self._max)]:max()
    assert(
      inputMax <= self._max,
      string.format(
        'The maximum value in the input %d is above the  '..
        'designated max %d', inputMax, self._max
      )
    )
  end

  --- Ensure that the size of the tensor to input
  -- is the same as that of the 
  function CheckTensor:sizeCheck(input)
    local inputSize = input:size()
    assert(
      #inputSize == self._size.n,
      string.format(
        'The number of dimensions for inputSize %d does not '..
        'match check size %d ', #inputSize, self._size.n
    ))
    
    for i=1, #inputSize do
      assert(
        self._size[i] == nil or
        self._size[i] == inputSize[i],
        string.format(
          'The size of input %s does not match %s',
          tostring(inputSize), tostring(self._size)
        )
      )
    end
  end
end
