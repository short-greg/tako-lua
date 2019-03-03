require 'oc.pkg'
require 'oc.class'
require 'oc.oc'
require 'oc.nerve'
require 'oc.ops.table'
require 'oc.strand'
require 'oc.ops.ops'

--! ################################################
--! @module Reference
--! References are nerves that perform an evaluation
--! on a table or function
--! 
--! There are 4 basic kinds of references
--! They can be created via placeholder as defined in the
--! placeholder class.  An example is 
--!      OutputFunction() .. oc.input(oc.my.x, oc.my.y)
--! 
--! Types:
--! Input: Does an evaluation on the input that
--!        is passed in from the preceding nerve.
--! My: Does an evaluation on the owner of the nerve
--!     (the tako or table instance that the nerve belongs to)
--! Val: Does an evaluation on a value that is passed
--!      into the nerve on construction
--! Ref : refers to a value that is passed in upon
--!      initialization.
--!
--! On top of that a NerveRef can be created using
--!   oc.r(oc.Ref or placeholder) 
--!   The nerve refs make the references accessible just
--!   like other nerves.
--! 
--! ################################################

local getMember = function(mod, path)
  --! Get the member for a module based on the path
  --! @param mdo - Module to retrieve member from
  --! @param path - string or {string}
  --! @return member
  local member
  if type(path) == 'string' then
    member = mod[path]
  else
    member = mod
    for i=1, #path do
      member = member[path[i]]
    end
  end
  return member
end


do
  local RefBase, parent = oc.class(
    'oc.RefBase', oc.Nerve
  )
  --! ##########################################
  --! @abstract
  --! Base nerve for all value references 
  --! (i.e. references to items other than arms)
  --! 
  --! ##########################################
  oc.RefBase = RefBase
  
  function RefBase:__init(
    path
  )
  --! @constructor
  --! @param path - path to access the value 
  --!             - {string} or strings
  --!
    parent.__init(self)
    self._path = path or {}
  end
  
  local function getVal(path, val, input)
    prevVal = val
    for i=1, #path do
      if oc.type(path[i]) == 'oc.Call' then
        val = path[i]:out(
          {prevVal, input, prevPrevVal}
        )
      else
        val = prevVal[path[i]]
      end
      prevPrevVal = prevVal
      prevVal = val
    end
    return val
  end

  function RefBase:out(
    input
  )
    local prevVal, prevPrevVal
    local path = self._path
    local val, status
    if type(path) == 'string' then
      val = self._baseVal[path]
    else
      status, val = pcall(
        getVal, path, self._baseVal, input
      )
      if status == false then
        error(
           string.format(
             'Could not access path %s for %s. %s', 
             oc.ops.table.serialize(path), tostring(self._baseVal),
             tostring(val)
           )
        )
      end
    end
    return val
  end

  function RefBase:grad(
    input, gradOutput
  )
    return nil
  end
  
  function RefBase:probe(probeReferent)
    --! TODO: finish this probe
    probeReferent = probeReferent or true
    if probeReferent then
    end
    return parent.probe(self)
  end
end


do
  local InputRef, parent = oc.class(
    'oc.InputRef', oc.RefBase
  )
  --! ##########################################
  --! References the input into the 
  --! nerve.
  --! 
  --! ##########################################
  oc.InputRef = InputRef
  
  function InputRef:out(input)
    self._baseVal = input
    return parent.out(self, input)
  end
end


do
  local MyRef, parent = oc.class(
    'oc.MyRef', oc.RefBase
  )
  --! ##########################################
  --! References the owner of the nerve.
  --! The owner will usually be a Tako.
  --! 
  --! ##########################################
  oc.MyRef = MyRef

  function MyRef:__init(
    path
  )
  --! @constructor
  --! @param path - path to access the value 
  --!             - {string} or string
  --!
    parent.__init(self, path)
    self._owner = nil
  end

  function MyRef:owner()
    return self._owner
  end

  --! The base class for all references
  --! @input Can be anything
  --! @output whatever the evaluation of the reference
  --!         spits out
  function MyRef:setOwner(owner)
    if not self._owner then
      self._owner = owner
      self._baseVal = owner
      for i=1, #self._path do
        if oc.type(self._path[i]) == 'oc.Call' then
          self._path[i]:setOwner(owner)
        end
      end
      return true
    end
    return false
  end
end


do
  local SuperRef, parent = oc.class(
    'oc.SuperRef', oc.RefBase
  )
  oc.SuperRef = SuperRef
  --! References the metatable of the tako the nerve
  --! belongs to.
  function SuperRef:__init(
    path
  )
  --! @constructor
  --! @param path - path to access the value 
  --!             - {string} or string
  --!
    parent.__init(self, path)
    self._super = nil
  end

  function SuperRef:super()
    return self._super
  end
  
  function SuperRef:setSuper(super)
    if not self._super then
      self._super = super
      self._baseVal = super
      for i=1, #self._path do
        if oc.type(self._path[i]) == 'oc.Call' then
          self._path[i]:setSuper(super)
        end
      end
      return true
    end
    return false
  end
end


do
  local ValRef, parent = oc.class(
    'oc.ValRef', oc.RefBase
  )
  oc.ValRef = ValRef
  --! References the val that is set upon construction
  --! or when using updateVal
  
  function ValRef:__init(
    val, path, args
  )
    --! @param val - the val to 
    --! @param path - path to access the value 
    --!             - {string} or string
    --! @param args - Args to pass if a function  {} or nil
    --!               (if args is nil will not call)
    parent.__init(self, path, args)
    self._baseVal = val
  end

  function ValRef:updateVal(val)
    --! Change the value that gets referred to in
    --! updateOutput
    --! @param val - Value to change baseVal to
    self._baseVal = val
  end
end


do
  local NerveRef, parent = oc.class(
    'oc.NerveRef', oc.Nerve
  )
  
  -- TODO: need to complete this
  -- right now it can only be set to stimulate
  -- the reference.. in some cases
  -- this is not what one wants to do
  -- like if using oc.Get <- just want to 
  -- get the output of the nerve being referenced......
  
  oc.NerveRef = NerveRef
  --! References a nerve.
  --! @input: Input needed for the nerve it refers to
  --! @output: Output of the reference nerve
  
  function NerveRef:__init(ref)
    parent.__init(self)
    self._ref= oc.nerve(ref)
    self._nerve = nil
    self._toProbe = true
  end
  
  function NerveRef:out(input)
    self._nerve = self._ref:stimulate(input)
    return self._nerve:stimulate(input)
  end
  
  function NerveRef:grad(input, gradOutput)
    return self._nerve:stimulateGrad(input)
  end
  
  function NerveRef:toProbe(toProbe)
    --! 
    --! @param toProbe - if set to false will not probe
    self._toProbe = toProbe
  end

  function NerveRef:accGradParameters(input, gradOutput)
    self._nerve:accumulate()
  end
  
  function NerveRef:internals()
    return {self._ref}
  end
  
  function NerveRef:setOwner(owner)
    if self._ref.setOwner then
      return self._ref:setOwner(owner)
    end
    return false
  end

  function NerveRef:setSuper(super)
    if self._ref.setSuper then
      return self._ref:setSuper(super)
    end
    return false
  end
end

function oc.r(ref)
  return oc.NerveRef(ref)
end


do
  local Call, parent = oc.class(
    'oc.Call', oc.Object
  )
  --! Object to call a function that exists
  --! within a reference.
  --! 
  --! @input {function, input, [object]}
  --!        input is the input into the ref
  --!        object is the object that contains the function
  --!        to use if a selfCall
  --! @output The output of the function
  function Call:__init(selfCall, ...)
    --! @constructor
    --! @param selfCall - Whether the function should
    --!        pass the object containing the function
    --!        as the first argument.
    local args = table.pack(...)
    self._args = {}
    for i=1, #args do
      if oc.isTypeOf(args[i], 'oc.Placeholder') or oc.isRefMeta(args[i]) then
        self._args[i] = oc.nerve(args[i])
      else
        self._args[i] = args[i]
      end
    end
    self._selfCall = selfCall
  end

  function Call:out(input)
    --! 
    --! @param input[1] - function to call
    --! @param input[2] - input
    --! @param input[3] - 'self' if it is a self call
    local argOutput = {}
    for i=1, #self._args do
      if oc.isTypeOf(self._args[i], 'oc.RefBase') then
        argOutput[i] = self._args[i]:out(input[2])
      else
        argOutput[i] = self._args[i]
      end
    end

    if self._selfCall then
      local result = input[1](
        input[3], table.unpack(argOutput)
      )
      return result
    else
      return input[1](
        table.unpack(argOutput)
      )
    end
  end
  
  local function getLoopStart(self)
    if self._selfCall then
      return 2
    else
      return 1
    end
  end
  
  function Call:setSuper(super)
    local curArg
    for i=1, #self._args do
      curArg =  self._args[i]
      if (oc.isTypeOf(curArg, oc.Nerve) or
          oc.type(curArg) == 'oc.Call') and
         curArg.setSuper then
        curArg:setSuper(owner)
      end
    end
  end
  
  function Call:setOwner(owner)
    local curArg
    for i=1, #self._args do
      curArg =  self._args[i]
      if (oc.isTypeOf(curArg, oc.Nerve) or
          oc.type(curArg) == 'oc.Call') and
         curArg.setOwner then
        curArg:setOwner(owner)
      end
    end
  end
  oc.Call = Call
end


--! ######################################
--! Placeholders are nerves used for convenience to
--! create references to other nerves, functions 
--! and data within the strand definition.
--! 
--! 
--! There are four basic types of placeholders
--! 
--! oc.input - Creates an input reference 
--!            (the input into the nere)
--! oc.my - Creates a reference to the 
--!         owner of the nerve (the Tako
--!         or some other table/object) to 
--!         access data within it
--! oc.super - Creates a reference to the 
--!          super class/tako of the nerve
--!         in order to call its 
--! oc.ref(value) - Creates a reference to the 
--!            value that gets passed in
--!
--! oc.r(oc.Ref) -> creates an NerveRef so that
--!         the reference will be treated like
--!         a nerve (will call inform, probe, informGrad
--!         etc)
--! 
--! @example - y = oc.r(oc.my.x) 
--!            oc.r() creates an arm reference to 
--!            the member x of self
--! @example - nn.Linear(2, 2)
--! @example oc.ref{y=1}.y <- will create a placeholder
--!            referring to the table {y=1} and 
--! 
--! You can create arm/nerve references for my, 
--! super, and ref.
--! This is used for 'essentially' having multiple inputs
--! into a nerve.  There is no arm reference for input however
--! since input is the value that gets passed into the arm 
--! (as of now).
--! ################################################

do
  local Placeholder, parent = oc.class(
    'oc.Placeholder'
  )
  --! ######################################
  --! @abstract
  --! 
  --! Base class for Plachoelders
  --!
  --! Used for declaring where a reference will
  --! point.  Placholders are used in place
  --! of actual Reference nerves for ease of use.
  --!
  --! Concatenating a placholder with a nerve
  --! will implicitly convert it to a Reference
  --! nerve.
  --!
  --! nn.Linear(2, 2) .. oc.my.x
  --! Will create a strand with an oc.MyRef at the
  --! end of the strand.
  --!
  --! Calling a placeholder will create a function
  --! call in the reference Call.  Placeholders can
  --! be passed into the function call.
  --!
  --! oc.my.x(oc.input) -> will call the function 
  --!   x with the input that was passed into the
  --!   
  --! oc.my:x(oc.input) -> will call the function 
  --!   x with the input that was passed into the
  --!   nerve as the second argument and x as
  --!   the first argument.
  --!
  --! oc.my.x(oc.input).y -> will pass the input into
  --!   the function x and then return the value
  --!   at key y in the index.
  --!
  --! ######################################
  oc.Placeholder = Placeholder

  function Placeholder:__init(params)
    --! @constructor 
    --! @param refType - Whether a global
    --! @param params.args - Arguments to a function call
    --! @param params.index - Index to access from reference
    --! @param params.reference - Reference to the item 
    --!        if DEFINED
    --! @param params._refType - 
    --parent.__init(self)
    params = params or {}
    rawset(self, '__refindex', params.index or {})
  end
  
  function Placeholder:__tostring__()
    --! @return representation of the placeholder - string
    return string.format(
      'Placeholder: %s to %s', 
      oc.type(self), 
      oc.ops.table.serialize(rawget(self, '__refindex'))
    )
  end

  function Placeholder:__index__(index)
    --! Define the item that gets called by 
    --! this reference
    --! @param index - index to the item
    --! @return self
    if rawget(Placeholder, index) then
      return rawget(Placeholder, index), true
    end

    if oc.isInstance(self) then
      table.insert(
        rawget(self, '__refindex'), index
      )
    else
      return false
    end
    return self
  end

  
  function Placeholder.__call__(self, ...)
    local selfCall
    local callArgs = table.pack(...)
    local isSelfCall = #callArgs > 0 and (
      callArgs[1] == self or callArgs[1] == self:__refMeta__()
    )

    if isSelfCall then
      selfCall = true
      callArgs[1] = self
    else
      selfCall = false
    end
    
    assert(
      not selfCall or (
        (selfCall and #self.__refindex == 0) or (
          selfCall and not oc.isTypeOf(
            self.__refindex[#self.__refindex],
            oc.Call
          )
    )))
    local argStart
    if selfCall then
      argStart = 2
    else
      argStart = 1
    end

    table.insert(
      self.__refindex,
      oc.Call(
        selfCall, 
        table.unpack(
          callArgs, argStart, table.maxn(callArgs)
        ))
    )
    return self
  end

  Placeholder.__concat__ = oc.concat
  
  function Placeholder:__newindex__(
    index, val
  )
    if not oc.isInstance(self) then
      rawset(self, index, val)
    end
  end
  
  function Placeholder:__refMeta__()
    error('Method refMeta not defined in base class.')
  end

  function Placeholder:__nerve__()
    error('Method __nerve__ not defined in base class.')
  end
end


do
  local InputPlaceholder, parent = oc.class(
    'oc.InputPlaceholder', oc.Placeholder
  )
  --! ######################################
  --! 
  --! References the input that is passed into the
  --! nerve.
  --!
  --! oc.input(1) <- will pass 1 into the function
  --!   that gets passed into the nerve as an input.
  --!
  --! oc.ref(x)(oc.input) will pass the input
  --!   into the function x as an argument.
  --!
  --! ######################################
  oc.InputPlaceholder = InputPlaceholder
  
  function InputPlaceholder:__index__(index)
    --! Define the item that gets called by 
    --! this reference
    --! @param index - index to the item
    --! @return self

    if rawget(InputPlaceholder, index) then
      return rawget(InputPlaceholder, index), true
    end
    return parent.__index__(self, index)
  end
    
  function InputPlaceholder:__nerve__()
    return oc.InputRef(self.__refindex)
  end
  
  function InputPlaceholder:__refMeta__()
    return oc.input
  end
end


do
  local MyPlaceholder, parent = oc.class(
    'oc.MyPlaceholder', oc.Placeholder
  )
  --! ######################################
  --! References the object that the nerve
  --! belongs to.  Possibly a Tako
  --!
  --! oc.my:y(oc.input, oc.my.x) will
  --!   call the Tako's function 'y' and 
  --!   pass in y as the first argument, the
  --!   input as the second argument
  --!   and Tako's member 'x' as the third.
  --!
  --! ######################################
  oc.MyPlaceholder = MyPlaceholder

  function MyPlaceholder:__index__(index)
    --! Define the item that gets called by 
    --! this reference
    --! @param index - index to the item
    --! @return self

    if rawget(MyPlaceholder, index) then
      return rawget(MyPlaceholder, index), true
    end
    return parent.__index__(self, index)
  end

  function MyPlaceholder:__nerve__()
    return oc.MyRef(self.__refindex)
  end
  
  function MyPlaceholder:__refMeta__()
    return oc.my
  end
end


do
  local ValPlaceholder, parent = oc.class(
    'oc.ValPlaceholder', oc.Placeholder
  )
  --! ######################################
  --! Used for referencing an arbitrary value.
  --!
  --! t = {1, 2, 3}
  --! oc.ref(t)[1] will output 1
  --! oc.ref(1) will also output 1
  --!
  --! ######################################
  oc.ValPlaceholder = ValPlaceholder

  function ValPlaceholder:__init(val, params)
    --! @constructor 
    --! @param val - The value to access
    parent.__init(self, params)
    rawset(self, '__ref', val)
  end
  
  function ValPlaceholder:__index__(index)
    --! Define the item that gets called by 
    --! this reference
    --! @param index - index to the item
    --! @return self
    if rawget(ValPlaceholder, index) then
      return rawget(ValPlaceholder, index), true
    end
    return parent.__index__(self, index)
  end
  
  function ValPlaceholder:__nerve__()
    return oc.ValRef(
      rawget(self, '__ref'), rawget(self, '__refindex')
    )
  end

  function ValPlaceholder:__refMeta__()
    return oc.ref
  end
end


do
  local SuperPlaceholder, parent = oc.class(
    'oc.SuperPlaceholder', oc.Placeholder
  )
  --! ######################################
  --! Used for referencing the super (parent) class
  --! of a Tako.
  --!
  --! oc.super.x <- Will create a placeholder 
  --! ######################################
  oc.SuperPlaceholder = SuperPlaceholder

  function SuperPlaceholder:__index__(index)
    --! Define the item that gets called by 
    --! this reference
    --! @param index - index to the item
    --! @return self
    if rawget(SuperPlaceholder, index) then
      return rawget(SuperPlaceholder, index), true
    end
    return parent.__index__(self, index)
  end

  function SuperPlaceholder:__nerve__()
    return oc.SuperRef(self.__refindex)
  end

  function SuperPlaceholder:__refMeta__()
    return oc.super
  end
end

--! ######################################
--! The meta tables below allow for the convenience
--! operations oc.my, oc.ref, oc.super, and 
--! oc.input
--!
--! ######################################
do
  --! For creating a RefPlaceholder
  local refmeta = {
    __refmeta=true,
    __call=function (self, val)
      return oc.ValPlaceholder(val)
    end,
    
    --!
    __index=function (self, index)
      error('')
    end,
    
    __newindex=function (self, index, val)
      error('')
    end,
    __nerve__=function (self)
      error('')
    end
    
  }
  oc.ref = {}
  setmetatable(oc.ref, refmeta)
end


do
  --! For creating a MyPlaceholder
  local myMeta = {
    __refmeta=true,
    __call=function (self, ...)
      return oc.MyPlaceholder()(...)
    end,
    --!
    __index=function (self, index)
      return oc.MyPlaceholder()[index]
    end,
    
    __newindex=function (self, index, val)
      error('')
    end,
    __nerve__=function (self)
      return oc.nerve(oc.MyPlaceholder())
    end
  }
  oc.my = {}

  setmetatable(oc.my, myMeta)
end


do
  --! For creating an SuperPlaceholder
  local superMeta = {
    __refmeta=true,
    __call=function (self, ...)
      return oc.SuperPlaceholder()(...)
    end,
    --!
    __index=function (self, index)
      return oc.SuperPlaceholder()[index]
    end,
    
    __newindex=function (self, index, val)
      error('')
    end,
    __nerve__=function (self)
      return oc.nerve(oc.SuperPlaceholder())
    end
  }
  oc.super = {}

  setmetatable(oc.super, superMeta)
end


do
  --! For creating an InputPlaceholder
  local inputMeta = {
    __refmeta=true,
    __call=function (self, ...)
      return oc.InputPlaceholder()(...)
    end,
    --!
    --! 
    __index=function (self, index)
      return oc.InputPlaceholder()[index]
    end,
    
    __newindex=function (self, index, val)
      error('')
    end,
    __nerve__=function (self)
      return oc.nerve(oc.InputPlaceholder())
    end

  }
  oc.input = {}
  setmetatable(oc.input, inputMeta)
end

--! TODO: I'm not sure what this is being used for
function oc.isRefMeta(val)
  return type(val) == 'table' and val.__refmeta
end


