require 'nn'
--require 'oc.ops.reverse'
require 'ocnn.pkg'


local function resizeToBatch(target, base)
  --! @param target
  --! @param base
  return torch.repeatTensor(
    base, target:size(1), 1
  )
end

local function updateTensor(curTensor, input_)
  --! @param curTensor
  --! @param input_
  if tostring(input_:size()) ~= 
     tostring(curTensor:size()) then
    return curTensor:typeAs(
      input_
    ):resizeAs(input_)
  else
    return curTensor
  end
end

function nn.BatchNormalization:rev()
  return ocnn.BatchNormalizationInv(self)
end


do
  local BatchNormalizationInv, parent = oc.class(
    'ocnn.BatchNormalizationInv', nn.Module
  )
  ocnn.BatchNormalizationInv = BatchNormalizationInv
  
  function BatchNormalizationInv:std(self)
    return self._normalizer.running_var:pow(0.5)
  end

  function BatchNormalizationInv:mean(self)
    return self._normalizer.running_mean
  end

  function BatchNormalizationInv:__init(batchNorm)
    parent.__init(self)
    assert(
      oc.isTypeOf(batchNorm, 'nn.BatchNormalization'),
      'Argument batchNorm must be of type '..
      'BatchNormalization'
    )
    self._normalizer = batchNorm
  end

  function BatchNormalizationInv:updateOutput(input)
    self.output = updateTensor(self.output, input):zero()
    
    if input:nElement() > 0 then
      self.output:add(input):add(
        resizeToBatch(input, self:mean())
      ):cmul(
        resizeToBatch(input, self:std())
      )
    end
    return self.output
  end
  
  function BatchNormalizationInv:updateGradInput(
    input, gradOutput
  )
    self.gradInput = updateTensor(
      self.gradInput, 
      input
    ):zero()
    self.gradInput:add(gradOutput):cmul(
      resizeToBatch(input, self:std())
    )
    return self.gradInput
  end
  
  --[[
  function nn.SpatialBatchNormalization:rev(dynamic)
    --! TODO Figure out what to od here.
    --! probably need a reverse class here
  end
  --]]
end
