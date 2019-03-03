require 'oc.class'


do
  --- Generate a tensor
  -- The  methods of objects of this class depend on the 
  -- state of the class.  Various types of tensors can be
  -- generated with objects of this type
  -- 
  -- Calls to tensor transformations will result in the
  -- the calls being added to the Call List and
  -- executed when resetting.
  -- 
  -- @usage
  -- Tensor():dynamic() <- the tensor will be updated with
  -- each call to updateOutput
  -- Tensor():static() <- the output tensor will be
  -- updated only on reset or initialization
  -- Tensor():trainable() <- makes a static tensor so 
  -- where gradients will be accumulated
  -- Tensor():double() <- 
  -- 
  -- @input nil
  -- @output Tensor
  local Tensor = oc.class(
    'ocnn.Tensor'
  )
  ocnn.Tensor = Tensor

  function Tensor:__init(generator, genArgs)
    self._generator = generator
    self._genArgs = genArgs
  end
  
  function Tensor:generate()
    local output = self._generator(
      table.unpack(self._genArgs)
    )
    
    --! Perform all other transformations
    for i=1, #self._callList do
      output = output[self._callList[1]](
        output, table.unpack(self._callList[2])
      )
    end
    return output
  end
  
  function Tensor:reset()
    self.output = nil
    self:updateOutput()
  end
  
  local trainableGrad = function (self, input, gradOutput)
    --! Accumulate grad parameters if the tensor
    --! is 'trainable'.
    self.gradAcc:add(gradOutput)
  end
  
  local nonTrainableGrad = function (self, input, gradOutput)
    --! Do not accumulate
  end
  
  local acc = function (self, input, gradOutput)
    --! Do not accumulate
   -- self.gradAcc:add(gradOutput)
  end

  local staticOut = function (self, input)
    if self.output == nil then
      return self:generate()
    else
      return self.output
    end
  end
  
  local dynamicOut = function (self, input)
    return self:generate()
  end
  
  function Tensor:resize(...)
    table.insert(
      callList, {'resize', table.pack(...)}
    )
  end

  --- @param val - integer value to offset tensor by number
  function Tensor:add(val)
    table.insert(
      callList, {'add', {val}}
    )
  end

  --- @param val - integer value to scale output by - number
  function Tensor:mul(val)
    table.insert(
      callList, {'mul', {val}}
    )
  end

  --- Convert to double
  function Tensor:double()
    table.insert(
      callList, {'double', {}}
    )
  end

  --- Convert to byte
  function Tensor:byte()
    table.insert(
      callList, {'byte', {}}
    )
  end

  --- Convert to long
  function Tensor:long()
    table.insert(
      callList, {'long', {}}
    )
  end

  --- Convert to static
  function Tensor:static()
    self.out = staticOut
    self.grad = nonTrainableGrad
    self.acc = acc
  end

  --- Convert to dynamic
  function Tensor:dynamic()
    self.out = dynamicOut
    self.grad = nonTrainableGrad
    self.acc = acc
  end

  --- Convert to trainable tensor
  function Tensor:trainable()
    self.out = staticOut
    self.grad = trainableGrad
    self.acc = acc
  end
end

ocnn.randn = function (...)
  ocnn.Tensor{
    generator=torch.randn,
    genArgs=table.pack(...)
  }
end

ocnn.rand = function (...)
  ocnn.Tensor{
    generator=torch.rand,
    genArgs=table.pack(...)
  }
end

ocnn.ones = function (...)
  ocnn.Tensor{
    generator=torch.ones,
    genArgs=table.pack(...)
  }
end

ocnn.zeros = function (...)
  ocnn.Tensor(
    torch.zeros,
    table.pack(...)
  )
end


ocnn.DoubleTensor = function (...)
  ocnn.Tensor(
    torch.DoubleTensor,
    table.pack(...)
  )
end

ocnn.LongTensor = function (...)
  ocnn.Tensor(
    torch.LongTensor,
    table.pack(...)
  )
end

ocnn.ByteTensor = function (...)
  ocnn.Tensor(
    torch.ByteTensor,
    table.pack(...)
  )
end
