require 'oc.pkg'
require 'oc.class'
require 'oc.nerve'


do
  local ToNil, parent = oc.class(
    'oc.ToNil', oc.Nerve
  )
  --! ######################################
  --!	ToNil
  --! 
  --! oc.ToNil - Conver the input to a nil value
  --!
  --! ######################################
  oc.ToNil = ToNil
  
  function ToNil:out()
    return nil
  end
end
