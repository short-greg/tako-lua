require 'oc.pkg'
require 'oc.class'
require 'oc.nerve'


do
  local ToNil, parent = oc.class(
    'oc.ToNil', oc.Nerve
  )
  --! ######################################
  --! Convert the input to a nil value
  --! @input - anything
  --! @output - nil
  --! ######################################
  oc.ToNil = ToNil
  
  function ToNil:out()
    return nil
  end
end
