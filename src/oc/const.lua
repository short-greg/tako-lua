require 'oc.pkg'
require 'oc.nerve'
require 'oc.class'


do
  local Const, parent = oc.class(
    'oc.Const', oc.Nerve
  )
  --! ######################################
  --!	The output of the nerve does not change
  --! It will throw an error if you inform
  --! it with anything but nil.
  --!
  --! @example y = oc.Const(1)
  --!          y:stimulate() -> outputs 1
  --!          y:stimulate(2) -> throws error
  --!
  --! @input: nil (must not input anything)
  --! @output: the value of the constant
  --!
  --! ######################################
  oc.Const = Const

  function Const:__init(val)
    --! @constructor
    --! @param val The value to set the constant to
    parent.__init(self)
    self._val = val
  end
  
  function Const:out(input)
    assert(
      input == nil,
      'Cannot update the value of a constant'
    )
    return self._val
  end
  
  function Const:inform(input)
    --! Must not use anything but
    --! nil for inform as const
    --! cannot be updated
    assert(
      input == nil,
      'Cannot update the value of a constant'
    )
  end
end
