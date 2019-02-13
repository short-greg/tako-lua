require 'oc.pkg'
require 'oc.nerve'
require 'oc.class'
require 'oc.undefined'
require 'oc.declaration'


--! #############################################
--! Reverse a particular nerve (can be used in 
--!
--! nn.Linear:rev(nn.Linear(2, 4)) -> this will create
--!   an nn.Linear(4, 2) upon definition
--! 
--! t:rev()
--! nn.Linear:rev() <- no module have to 
--! define dynamically overwrite the 
--!
--! #############################################

do
  local Reverse, parent = oc.class(
    'oc.Reverse', oc.Undefined
  )
  
  --! Reverse a particular nerve
  --!
  --!
  oc.Reverse = Reverse
  
  function Reverse:__init(nerve, dynamic)
    --! Reverse operation for a particular nerve
    --! The nerve should be defined within the 
    --! same Tako.
    --!
    --! @param nerve - The nerve (or combination of 
    --!        nerves to reverse) - oc.Nerve or {oc.Nerve}
    --! @param dynamic - Whether or not the nerve
    --!  should be reversed with each update of the output
    --!  If it is static, then the type of Reverse will
    --!  change to the reversed nerve once it has been
    --!  defined
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

  function Reverse:_defineBaseDynamic(input)
    --! The default is to just use the same module
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
  local DeclarationReverse, parent = oc.class(
    'oc.DeclarationReverse', oc.Declaration
  )
  --! Used for creating a reverse of another 
  --! nerve which is a declaration
  --! 
  --! y = nn.Linear:d(2, 2)
  --! z = y:rev()
  --! 
  oc.DeclarationReverse = DeclarationReverse
  function DeclarationReverse:__init(nerve, dynamic)
    --! 
    --! @param
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
