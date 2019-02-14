require 'ocnn.pkg'
require 'oc.nerve'
require 'ocnn.module'


do
  local Linear, parent = oc.class(
    'ocnn.Linear', oc.Nerve
  )
  --! ########################################
  --! Modifies nn.Linear so that
  --! the weights and biases are passed
  --! in as inputs rather than treated as values
  --! stored in the Linear nerve.
  --!
  --! @input {input, weight, bias}
  --!   - {torch.Tensor, torch.Tensor, torch.Tensor}
  --! @output torch.Tensor
  --! ########################################

  function Linear:__init(bias)
    bias = bias or true
    self._linear = nn.Linear(1, 1, bias)
    
    self.weightGradInput = torch.Tensor()
    self.biasGradInput = torch.Tensor()
  end
  
  function Linear:_updateLinear(weight, bias)
    self._linear.weight = weight
    self._linear.bias = bias
    if tostring(weight:size()) ~= 
       tostring(self._linear.gradWeight:size()) then
      self._linear.gradWeight:resizeAs(weight):typeAs(
        weight
      ):zero()
      self.weightGradInput:resizeAs(weight):copy(
        self._linear.gradWeight
      )
      if bias then
        self._linear.gradBias:resizeAs(bias):typeAs(
          bias
        ):zero()
        self.biasGradInput:resizeAs(bias):copy(
          self._linear.gradBias
        )
      end
    end
  end
  
  function Linear:updateOutput(input)
    self:_updateLinear(input[2], input[3])
    local output = self._linear:stimulate(input[1])
    self.output = output
    return output
  end
  
  function Linear:updateGradInput(
      input, gradOutput
    )
    self.inGradInput = self._linear:backward(
      input[1], gradOutput
    )
    self.weightGradInput:copy(self._linear.gradWeight)
    self.biasGradInput:copy(self._linear.gradBias)
    self.gradInput = {
      self.inGradInput,
      self.weightGradInput,
      self.biasGradInput
    }
    if input[3] then
      self._linear.gradBias:zero()
    end
    self._linear.gradWeight:zero()
    return self.gradInput
  end

  function Linear:accGradParameters(input, gradOutput)
  end
end

