require 'ocnn.pkg'
require 'oc.init'


do
  --- Adapter for criterions since nn.Criterion
  --  since criterions do not inherit from nn.Module
  --  their updateOutput method is different
  --
  --  @usage nn.Linear(2, 2) .. oc.Onto(oc.my.target) ..
  --       ocnn.Criterion(nn.MSECriterion())
  -- 
  --  @input {output, target}
  --  @gradOutput nil
  local Criterion, parent = oc.class(
    'ocnn.Criterion', oc.Nerve
  )
  ocnn.Criterion = Criterion
  
  function Criterion:__init(criterion, weightOnGrad)
    parent.__init(self)
    self._criterion = criterion
    self._weightOnGrad = weightOnGrad
  end
  
  function Criterion:out(input)
    return self._criterion:updateOutput(
      input[1],
      input[2]
    )
  end

  function Criterion:grad(input)
    local gradInput = {
      self._criterion:updateGradInput(
        input[1],
        input[2]
      )
    }
    if self._weightOnGrad then
      gradInput[1]:mul(self._weightOnGrad)
    end
    return gradInput
  end
end
