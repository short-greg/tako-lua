require 'oc.init'
require 'ocnn.pkg'

do
  --- Clone creates a clone of the Tensor input, and gradOutput
  --
  -- @input Tensor
  -- @output Tensor
  local Clone, parent = oc.class(
    'ocnn.Clone', nn.Module
  )
  ocnn.Clone = Clone
  function Clone:updateOutput(input)
    self.output = input:clone()
    return self.output
  end
  
  function Clone:updateGradInput(input, gradOutput)
    self.gradInput = gradOutput:clone()
    return self.gradInput
  end
end
