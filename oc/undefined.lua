require 'oc.pkg'
require 'oc.class'
require 'oc.ops.table'
require 'oc.oc'


-- t:rev() <- 
-- 1. T=declare
-- 2. T=member
-- 3. T=module
-- If 1, t should be able to reverse at that time??? <- depends on
-- the class
-- for some classes return Rev class.. for others (like Linear) return
-- 
-- If 2, defined by the user who passes something in... create
-- MemberReverse
-- nn.Linear:member('') <- creates reverse member 
-- nn.Linear:rev() <- does not point to a specific module to
-- reverse
-- 
-- If there is no reverse for that type of module
-- will just create a
--
-- 
-- don't want to have to pass a value through the network
-- ocnn.CheckTensor() .. nn.Linear:d(nil, 2)
-- :outputSize(inputSize) <- 
-- nn.Linear:outputSize(inputSize) <- need this output size 
-- method
-- outputSample() <- if check tensor
-- - conv - 28, 28 <- not specified in nn.Convolution
-- Another option... wait until use to update.. With this 
-- approach
-- t:rev(false) <- will not fix the nerve on update (
--    reverse the module each time based on the input)
--    the default is to fix it
-- with this approach we do not need to use a bot to update
-- it or anything
-- instead of replacing could just have ._module point to the
-- new module oc.Reverse() ._moduleToReverse, ._module
-- I like this approach instead of replacing
-- 
-- t:rev()
-- nn.Linear:rev() <- no module have to define dynamically
-- overwrite the 


-- 1. Declaration
-- 3. Reverse
-- 4. ReverseType (set (the module to reverse)

do
  local Undefined, parent = oc.class(
    'oc.Undefined', oc.Nerve 
  )
  
  oc.Undefined = Undefined

  function Undefined:_define(input)
    error('Method define(input) not defined for the base class Undefined.')
  end
  
  function Undefined:_defineBase(input)
    local mod = self:_define(input)
    mod.input = input
    assert(
      mod,
      string.format(
        'The nerve for %s '.. 
        'has not been defined.', self._argName
      )
    )
    
    if mod:super() and mod:super() ~= self._super then
      error(
        string.format(
          'The super of the nerve %s has already been '..
          'set and it does not equal that of the '..
          'ArgNerve %s.',
          self._argName
        )
      )
    end

    if mod:owner() and mod:owner() ~= self._owner then
      error(
        string.format(
          'The owner of the nerve %s has already been '..
          'set and it does not equal that of the '..
          'ArgNerve %s.',
          self._argName
        )
      )      
    end
    mod._gradOn = self._gradOn
    mod._accOn = self._accOn
    mod._name = self._name
    mod._annotation = self._annotation
    mod._inAxon = self._inAxon
    mod._outAxons = self._outAxons
    mod._gradFunc = self._gradFunc

    if self:owner() then
      oc.bot.call:setOwner{
        args={self:owner()},
        cond=function (self, nerve) 
          return nerve.setOwner ~= nil 
        end
      }:exec(
        mod
      )
    end

    if self:super() then
      oc.bot.call:setSuper{
        args={self:super()},
        cond=function (self, nerve)  
          return nerve.setSuper ~= nil 
        end
      }:exec(
        mod
      )
    end
    return mod
  end
    
  function Undefined:out(input)
    -- Replace contents of self with created
    local defined = self:_defineBase(input)
    --defined:rewire(self)
    oc.ops.table.copyInto(self, defined)
    return self:stimulate(input)
  end
end


do
  local ArgNerve, parent = oc.class(
    'oc.ArgNerve', oc.Undefined
  )
  oc.ArgNerve = ArgNerve
  --! ArgNerve is used in declaration to create a variable nerve
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
  local Declaration, parent = oc.class(
    'oc.Declaration', oc.Undefined
  )
  --! Declares a nerve to be used in an arm
  --! @input Should not use updateOutput (must define)
  --! @gradOutput Should not use updateOutput (must define)
  --!
  oc.Declaration = Declaration

  function Declaration:__init(nerveType, ...)
    parent.__init(self)
    self._mod = nerveType
    self._arguments = table.pack(...)
  end
  
  function Declaration:grad()
    error(
      'Declaration cannot update grad input. '.. 
      'Must instantiate'
    )
  end
  
  function Declaration:accGradParameters()
    error(
      'Declaration cannot update grad input. '..  
      'Must instantiate')
  end
  
  function Declaration:_define(input)
    return oc.nerve(self._mod(
      table.unpack(self._arguments)
    ))
  end
  
  --! could create an argmap in declare if necessary
  --! add ArgFunc() <- which can be used to get retrieve the arg 
  --! if not defined
    
  function Declaration:updateArg(varName, val)
    --! Update the arg to use in declaration when
    --! defining
    --! @param varName - The variable to set
    --! @param val - The value to set hte argument to
    for i=1, #self._arguments do
      if oc.type(self._arguments[i]) == 'oc.Arg' and
         self._arguments[i]:name() == varName then
           
        self._arguments[i] = val
      end
    end
  end
  
  --! TODO: Do I really want to do this???
  --! 
  function Declaration:children()
    local children = {}
    for i=1, #self._arguments do
      if oc.isTypeOf(self._arguments[i], 'oc.Nerve') or
         oc.isTypeOf(self._arguments[i], 'oc.Chain') then
        table.insert(children, self._arguments[i])
      end
    end
    return children
  end
  
  function Declaration:updateArgs(argVals)
    --! Set the values for the Arg Variables
    --! for the declaration
    --! {string=<value>}
    --! 
    for argName, val in pairs(argVals) do
      self:updateArg(argName, val)
    end
  end
  
  function oc.declaration(cls, ...)
    --! TODO: Make sure it's not an instance
    assert(
      not oc.isInstance(cls),
      'Cannot make a declaration from an instance.'
    )
    
    return oc.Declaration(cls, ...)
  end
  
  --! need to reverse this because there may
  --! be some classes which use a subclass of declaration
  oc.Nerve.d = oc.declaration
end


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
  local Reverse, parent = oc.class(
    'oc.Reverse', oc.Undefined
  )
  
  --! Reverse a particular 
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
