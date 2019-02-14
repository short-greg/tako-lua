require 'oc.init'
require 'ocnn.pkg'

do
  local Clone, parent = torch.class(
    'ocnn.Clone', 'nn.Module'
  )
  
  function Clone:updateOutput(input)
    self.output = input:clone()
    return self.output
  end
  
  function Clone:updateGradInput(input, gradOutput)
    self.gradInput = gradOutput:clone()
    return self.gradInput
  end
end
