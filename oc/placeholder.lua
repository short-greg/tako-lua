require 'oc.pkg'
require 'oc.class'
require 'oc.ops.table'
require 'oc.chain'
require 'oc.oc'
require 'oc.ops.ops'

--! ######################################
--! Placeholder is a convenience module used in order to 
--! create references to other nerves, functions 
--! and data within the chain definition.
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
  --! Will create a chain with an oc.MyRef at the
  --! end of the chain.
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
