require 'oc.pkg'
require 'oc.nerve'
require 'oc.class'
require 'oc.undefined.base'
require 'oc.undefined.declaration'

--- Reverse a particular nerve 
-- (can be used in autoencoders etc)
--
-- nn.Linear:rev(nn.Linear(2, 4)) -> this will create
--   an nn.Linear(4, 2) upon definition
-- 
-- self.arm.encoder = nn.Linear(2, 4)
-- self.arm.decoder = self.encoder:rev()
-- 
-- self.arm.autoencode = r(oc.my.encoder) .. r(oc.my.decoder)
-- 
-- self.autoencode:stimulate(torch.randn(2, 2)) -> will
--   output a 2 x 2 tensor
-- 
-- t:rev()
-- nn.Linear:rev() <- no module have to 
-- define dynamically overwrite the 
--
-- DeclarationReverse is used for declarations
-- n = nn.Linear:d(2, 4)
-- n:rev() -> creates a DeclarationReverse

do
  --- Reverse a particular nerve
  local Reverse, parent = oc.class(
    'oc.Reverse', oc.Undefined
  )
  oc.Reverse = Reverse

  --- Reverse operation for a particular nerve
  -- The nerve should be defined within the 
  -- same Tako.
  --
  -- @param nerve - The nerve (or combination of 
  -- nerves to reverse) - oc.Nerve or {oc.Nerve}
  -- @param dynamic - Whether or not the nerve
  -- should be reversed with each update of the output
  -- If it is static, then the type of Reverse will
  -- change to the reversed nerve once it has been
  -- defined
  function Reverse:__init(nerve, dynamic)

    parent.__init(self)
    dynamic = dynamic or false
    --[[
    assert(
      oc.isTypeOf(nerve, 'oc.Nerve'),
      'Argument nerve must be of type oc.Nerve.'
    )
    assert(
      oc.isInstance(nerve),
      'Nerve to reverse must be an instance.'
    )
    --]]
    assert(
      type(dynamic) == 'boolean',
      'Argument dynamic must be of type boolean'
    )
    self._toReverse = nerve
    self._module = self._module or self._toReverse
    self._dynamic = dynamic
    if self._dynamic then
      self.out = self.outDynamic
    else
      self.out = parent.out
    end
  end

  --- The default is to just use the same module
  function Reverse:_defineBaseDynamic(input)
    local mod = self._module or self._toReverse
    mod = mod:clone()
    mod:clearState()
    self._defined = mod
    mod:relax()
    return mod
  end

  function Reverse:outDynamic(input)
    self:_defineBaseDynamic(input)
    return self._defined:stimulate(input)
  end
  
  function Reverse:grad(input, gradOutput)
    self._defined:stimulateGrad(gradOutput)
  end

  function Reverse:accGradParameters(input, gradOutput)
    self._defined:accumulate(gradOutput)
  end
  
  function oc.Nerve:rev(dynamic)
    return oc.Reverse(self, dynamic)
  end
end


do
  --- Used for creating a reverse of another 
  -- nerve which is a declaration
  -- 
  -- y = nn.Linear:d(2, 2)
  -- z = y:rev()
  local DeclarationReverse, parent = oc.class(
    'oc.DeclarationReverse', oc.Declaration
  )
  oc.DeclarationReverse = DeclarationReverse

  --! @param
  function DeclarationReverse:__init(nerve, dynamic)
    assert(
      oc.isTypeOf(nerve, 'oc.Declaration'),
      'Nerve passed into declaration reverse must be '..
      'of type declaration.'
    )
    parent.__init(self, nerve, dynamic)
  end
  
  function DeclarationReverse:_define(input)
    local reverser = self._mod:rev(self._dynamic)
    --! will call define on reverse
    return reverser:_define(input)
  end
  
  function oc.Declaration:rev()
    return DeclarationReverse(self, dynamic)
  end
end
