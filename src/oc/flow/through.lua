require 'oc.flow.pkg'
require 'oc.nerve'
require 'oc.class'


do
  local Through, parent = oc.class(
    'oc.Through', oc.Nerve
  )
  --! #####################################
  --! Stimulate an internal module and 
  --! output the data that was input
  --!
  --! @input - the input to the internal module
  --! @gradOutput - should be of the same 
  --! form as the gradInput of the internal module
  --!
  --! @example oc.Through(p1) .. p2 
  --!          wil send the input of the Through
  --!          into p2
  --! 
  --! TODO: Decide whether to delete this
  --!       There are some issues with it and
  --!       it can be easily created with a stem
  --! #####################################
  oc.Through = Through
  
  function Through:__init(nerve)
    --! @constructor
    --! @param nerve - nervable
    parent.__init(self)
    self._module = oc.nerve(nerve)
  end

  function Through:out(input)
    --! @param input - dataset
    self._moduleOutput = self._module:stimulate(input)
    return input
  end

  function Through:grad(input, gradOutput)
    local moduleGrad = self._module:stimulateGrad()

    if moduleGrad and gradOutput then
      return moduleGrad + gradOutput
    elseif moduleGrad then
      return moduleGrad
    elseif gradOutput then
      return gradOutput
    end
  end

  function Through:accGradParameters(input, gradOutput)
    self._module:accumulate()
  end
end
