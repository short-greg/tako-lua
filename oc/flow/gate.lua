require 'oc.flow.pkg'
require 'oc.ops.module'
require 'oc.oc'
require 'oc.flow.mergein'


do
  local Gate, parent = oc.class(
    'oc.flow.Gate', oc.Nerve
  )
  --! ########################################
  --! Control structure that passes the outputs based on
  --! whether a condition is passed 
  --! (similar to an if-statement)
  --!
  --! Nerve: Can be set to probe or stimulate with the input
  --! Function: Can be set to send the input through 
  --!            the function
  --! format: function (self, input) ... end
  --!
  --! @input - The value that gets passed in
  --! @output - {passed?, <stream output>} - 
  --!            {boolean, <stream output>} - 
  --! 
  --! @example  oc.flow.Gate(
  --!   function (self, input) return input ~= nil end,
  --!   nn.Linear(2, 2)
  --! )
  --! 
  --! ########################################
  oc.flow.Gate = Gate

  function Gate:__init(condition, chain)
    --! 
    --! @param condition - Condition for passing the input
    --!   through the stream
    --! @param chain - the chain of processing to execute
    --! 
    parent.__init(self)
    self._modules = {}
    condition = condition or oc.Noop()
    self._modules.cond = oc.nerve(condition)
    self._input = nil
    self._modules.stream = oc.nerve(chain)
  end
  
  function Gate:children()
    return {self._modules.cond, self._modules.stream}
  end

  function Gate:out(input)
    --!  If the condition passes then output
    --!  the result of the internal module
    local output = {}
    self._input = input
    output[1] = self._modules.cond:stimulate(input[1])
    if output[1] == 1 then
      output[2] = self._modules.stream:stimulate(input[2])
    end
    self.output = output
    return output
  end
  
  Gate.out = Gate.updateOutput

  function Gate:grad(input, gradOutput)
    --! If the condition has passed on the forward
    --! pass then backpropagate the 
    local gradInput = {}
    --local pass = self._condition:probe()
    gradOutput[1] = self._modules.cond:stimulateGrad(
      gradOutput[1]
    )
    
    if self.output[1] == 1 then
      gradInput[2] = self._modules.stream:stimulateGrad(
        input[2], gradOutput[2]
      )
    end
    self.gradInput = gradInput
    return gradInput
  end
  
  Gate.grad = Gate.updateGradInput
  
  function Gate:accGradParameters(input, gradOutput)
    self._modules.cond:accGradParameters(
      input[1], gradOutput[1]
    )
    
    if self.output[1] == 1 then
      self._modules.stream:accGradParameters(
        input[2], gradOutput[2]
      )
    end
  end
end