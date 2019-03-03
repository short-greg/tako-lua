require 'oc.pkg'
require 'oc.nerve'
require 'oc.class'


do
  ---	The output of the nerve does not change
  -- It will throw an error if you inform
  -- it with anything but nil.
  --
  -- @usage y = oc.Const(1)
  --          y:stimulate() -> outputs 1
  --          y:stimulate(2) -> throws error
  --
  -- @input: nil (must not input anything)
  -- @output: the value of the constant
  local Const, parent = oc.class(
    'oc.Const', oc.Nerve
  )

  oc.Const = Const

  --- @constructor
  -- @param val The value to set the constant to
  function Const:__init(val)
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

  --- Must not use anything but nil for inform as const
  -- cannot be updated
  function Const:inform(input)
    assert(
      input == nil,
      'Cannot update the value of a constant'
    )
  end
end
