require 'oc.pkg'
require 'oc.class'
require 'oc.oc'
require 'oc.nerve'
require 'oc.ops.table'

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
    'oc.ArmRef', oc.Nerve
  )
  oc.NerveRef = NerveRef
  --! References a nerve.
  --! @input: Input needed for the nerve it refers to
  --! @output: Output of the reference nerve
  
  function NerveRef:__init(ref)
    parent.__init(self)
    self._ref= oc.nerve(ref)
    self._nerve = nil
  end
  
  function NerveRef:out(input, toProbe)
    toProbe = toProbe or true
    local nerve = self._ref:out(input)
    if toProbe then
      return nerve:stimulate(input)
    else
      return nerve.output
    end
    self._nerve = nerve
  end
  
  function NerveRef:updateOutput(input, toProbe)
    local output = self:out(input, toProbe)
    self.output = output
    return output
  end
  
  function NerveRef:grad(input, gradOutput)
    return self._nerve:stimulateGrad(
      gradOutput
    )
  end

  function NerveRef:accGradParameters(input, gradOutput)
    self._nerve:accumulate()
  end

  function NerveRef:getRef()
    if self._owner then
      return getMember(self._owner, self._member)
    end
  end

  function NerveRef:getMemberName()
    return self._member
  end
  
  function NerveRef:children()
    return {self:getRef()}
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
    for i=1, #self._args do
      if oc.isTypeOf(self._args[i], 'oc.RefBase') then
        self._args[i]:setSuper(super)
      end
    end
  end
  
  function Call:setOwner(owner)
    for i=1, #self._args do
      if oc.isTypeOf(self._args[i], 'oc.RefBase') then
        self._args[i]:setOwner(owner)
      end
    end
  end
  oc.Call = Call
end
