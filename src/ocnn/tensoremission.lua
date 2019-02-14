require 'oc.class'
require 'ocnn.ocnn'
require 'oc.pkg'


do
  local TensorEmission, parent = oc.class(
    'oc.TensorEmission', oc.Emission
  )
  --! ###################################################
  --! TensorEmission sublcasses Emission so that the 
  --! emission so that the Tensor can be modified in
  --! place in the emission.
  --!
  --! ###################################################
  oc.TensorEmission = TensorEmission

  function TensorEmission:set(val)
    --! @param val - the value to set the current index to
    self._vals[self._index] = ocnn.update(self._vals[self._index], val)
  end
end
