require 'oc.pkg'
require 'oc.nerve'
require 'oc.class'
require 'oc.undefined.base'


-- t = oc.Stem()
-- t.T = oc.Linear:d(nil, nil)
-- t.arm = t.T .. oc.Sigmoid()
-- t.__call = function (self, sizeIn, sizeOut)
--   local cloned = self:clone()
--   t.T:setArgs(sizeIn, sizeOut)
--   return self:toArm()
-- )
-- t()

do
  local Arg = oc.class(
    'oc.Arg'
  )
  oc.Arg = Arg
  --! Arg is used in declaration to create a variable
  --! argument.  The main use for this is
  --! in order to create an arm of nerves
  --! using oc.stem.
  --! oc.stem(
  --!   oc.Linear:d(2, oc.arg.Z) .. oc.Linear(oc.arg.Z, 4)
  --! )
  function Arg:__init(argName)
    self._argName = argName
  end
  
  function Arg:name()
    return self._argName
  end

  function Arg:__nerve__()
    return oc.ArgNerve(self._argName)
  end
  
  Arg.__concat__ = oc.concat
  
  local argMeta = {}
  
  function argMeta:__index(index)
    return oc.Arg(index)
  end
  
  oc.arg = {}
  setmetatable(oc.arg, argMeta)
end


do
  local ArgNerve, parent = oc.class(
    'oc.ArgNerve', oc.Undefined
  )
  oc.ArgNerve = ArgNerve
  --! ArgNerve is used in declaration to 
  --! create a variable nerve
  --! argument.  The main use for this is
  --! in order to create an arm of nerves
  --! using oc.stem.
  --! arm = oc.stem(
  --!   oc.Linear:d(2, 4) .. oc.ArgNerve('X')
  --! )
  --! when creating the arm just pass in the 
  --! nerve.  arm(nn.Linear(4, 2))
  --! 

  function ArgNerve:__init(argName)
    parent.__init(self)
    self._argName = argName
    self._argNerve = nil
  end

  function ArgNerve:_define()
    --! The default 
    return self._module
    --mod:relaxGrad()
  end
  
  function ArgNerve:updateArgs(argVals)
    --! Set the values for the Arg Variables
    --! for the declaration
    --! {string=<value>}
    --! 
    for argName, val in pairs(argVals) do
      if argName == self._argName then
        local nerve = oc.nerve(val)
        assert(
          nerve:incoming() == nil and
          #nerve:outgoing() == 0,
          string.format(
            'The nerve %s cannot be connected to '..
            'other neves when setting it as an ArgNerve.',
            argName
          )
        )
        self._module = nerve
      end
    end
  end
end
