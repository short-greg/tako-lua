require 'oc.pkg'
require 'oc.class'
require 'oc.nerve'
require 'oc.oc'

do
  local Coalesce, parent = oc.class(
    'oc.Coalesce', oc.Nerve
  )
  --! ######################################
  --! Outputs a default value if the
  --! input is undefined (nil)
  --! The default value can be a reference
  --! or a value
  --!
  --! @example y = oc.Coalesce(2)
  --!          y:stimulate() will output 2
  --!          y:stimulate(4) will output 4
  --!
  --! @input anything
  --! @output default value if nothing is input
  --! ######################################
  oc.Coalesce = Coalesce
  
  local valueDefault, placeholderDefault
  
  function Coalesce:__init(defaultValue)
    --! Nerve with a default value
    --! a tentacle
    --! @param defaultValue
    parent.__init(self)
    self.default = value
    if oc.isTypeOf(self.default, oc.Placeholder) then
      self.evalDefault = valueDefault
    else
      self.evalDefault = valueDefault
    end
  end

  function Coalesce:out(input)
    if input == nil then
      return self:evalDefault()
    end
    return input
  end
  
  placeholderDefault = function (self)
    return self.default:eval(
      self._owner, self.default
    )
  end
  
  valueDefault = function (self)
    return self.default
  end
end
