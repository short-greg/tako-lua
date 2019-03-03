require 'oc.pkg'
require 'nn'
require 'oc.class'
require 'oc.bot.init'
require 'oc.ops.table'
require 'oc.oc'


do
  --- Strand - Create a chain of multiple nerves
  -- Links multiple nerves together
  -- in a pipeline of processes.
  --
  -- @usage y = p1 .. p2 .. p3
  --          y:stimulate(value) will send the
  --          value through p1, p2 and then
  --          p3.
  -- 
  --          Note: y .. p4 will just extend
  --          the strand.
  --
  --          oc.nerve(y) will output an Arm.
  --
  --          Strand also does not have
  --          out and grad functions unlike Arm
  -- @input - Whatever the first member nerve takes
  -- @output - Whatever the member nerve outputs
  local Strand, parent = oc.class(
    'oc.Strand'
  )
  oc.Strand = Strand
  local myType = 'oc.Strand'

  --- @constructor
  -- @param ... - the nerves or nervables that
  --              make up the strand
  function Strand:__init(...)
    local modules = table.pack(...)
    self._gradOn = true
    rawset(self, '_lhs', modules[1])
    rawset(self, '_rhs', modules[#modules])
  end

  --- Concatenate two nerves or strands together
  -- to form a strand.
  --
  -- @param lhs - left hand side - nerve | strand
  -- @param rhs - right hand side - nerve | strand
  -- @return oc.Strand
  function oc.concat(lhs, rhs)
    local stream
    local modules
    -- Arms should not be concatenated
    if oc.type(lhs) == 'oc.Arm' then
      lhs = lhs:strand()
    end
    if oc.type(rhs) == 'oc.Arm' then
      rhs = rhs:strand()
    end
    if oc.isTypeOf(lhs, myType) and 
       oc.isTypeOf(rhs, myType) then
      local mid = lhs:rhs() .. rhs:lhs()
      return oc.Strand(
        table.unpack(
          oc.ops.table.listCat(
            lhs:modules(), rhs:modules()
          )
        )
      )
    elseif oc.isTypeOf(lhs, myType) then
      local rhsmod = oc.nerve(rhs)
      local _ = lhs:rhs() .. rhsmod
      return oc.Strand(
        table.unpack(
          oc.ops.table.listCat(lhs:modules(), {rhsmod})
        )
      )
    elseif oc.isTypeOf(rhs, myType) then
      local lhsmod = oc.nerve(lhs)
      local _ = lhsmod .. rhs:lhs()
      return oc.Strand(
        table.unpack(
          oc.ops.table.listCat({lhsmod}, rhs:modules())
        )
      )
    else 
      return oc.nerve(lhs):connect(oc.nerve(rhs))
    end
  end

  --- @return Get the head (lhs) nerve of the strand
  function Strand:lhs()
    return self._lhs
  end

  --- @return Get the tail (rhs) nerve of the strand
  function Strand:rhs()
    return self._rhs
  end

  Strand.root = Strand.lhs
  Strand.leaf = Strand.rhs

  --- @return The number of nerves in the strand -int
  function Strand:__len__()
    return self._rhs:getLength(self._lhs)
  end

  --- Convenience function to turn grad on in
  -- a strand
  -- To be used to define a strand simply
  -- @return oc.Strand
  function Strand:gradOn()
    self._gradOn = true
    oc.bot.call:gradOn():exec(self)
    return self
  end

  --- Convenience function to turn grad off
  -- in a strand when defining the sequence
  -- To be used to define a strand simply
  -- @return oc.Strand
  function Strand:gradOff()
    self.gradOn = false
    oc.bot.call:gradOff():exec(self)
    return self
  end

  --- Retrieve a sub strand of the strand
  -- @param lower The index of the start of the strand
  -- @param upper the index of the end of the strand
  -- @return oc.Strand
  function Strand:sub(lower, upper)
    local modules, found = self._rhs:getSeq(self._lhs)
    lower = lower or 1
    upper = upper or #modules
    assert(lower <= upper, 'Lower must be <= upper')
    
    local strand = oc.Strand(table.unpack(
      modules, lower, upper
    ))
    strand.gradOn = self.gradOn
    return strand
  end

  --- Convert a Strand to an nn.Sequential
  -- Used for getting trainable parameters
  -- @param lower The lower bound of the sequence - int
  -- @param upper The upper bound of the sequence - int
  -- @return nn.Sequential
  function Strand:seq(lower, upper)
    local sub = self:sub(lower, upper)
    local mod = nn.Sequential()
    for i=1, #sub do
      mod:add(sub[i])
    end
    return mod
  end

  --- @return The modules in the Strand
  function Strand:modules()
    local seq, found = self._rhs:getSeq(self._lhs)
    return seq
  end

  --- Determine whether the left side of the Strand connects to the right
  -- @return if they connect or not - bool
  function Strand:validStrand()
    if pcall(self._rhs.getLength, self, self._lhs) then
      return true
    else
      return false
    end
  end

  --- Convert the strand or substrand to an Arm 
  -- @param the start of the substrand to retrieve - int
  -- @param the end of the substrand to retrieve - int
  -- @return Arm
  function Strand:arm(lower, upper)
    local subStrand = self:sub(lower, upper)
    local arm = oc.Arm(subStrand)
    return arm
  end

  Strand.__nerve__ = Strand.arm

  --- Retrieve a module or member from a strand
  -- @param key - Key specifying the module
  -- @return nerve, true if exists otherwise false
  function Strand.__index__(self, key)
    if rawget(Strand, key) then
      return rawget(Strand, key)
    end
    
    if type(key) == 'number' then
      local modules = self._rhs:getSeq(self._lhs)
      if modules and modules[key] then
        return modules[key]
      end
    end
  end

  --- Cannot add to the strand
  -- TODO: Make sure it should not be able to add to the strand
  function Strand.__newindex__(self, key, val)
    if not oc.isInstance(self) then
      rawset(self, key, val)
      return
    end

    if key == '_modules' then
      assert(type(val) == 'table', 'Nerves must be a table')
      rawset(self, '_modules', val)
      return true
    end
    return false
  end

  --- @return whether the strand is relaxed
  --  by checking the tail nerve - bool
  function Strand:relaxed()
    return self._rhs:relaxed()
  end

  --- @return whether the gradient for the strand
  -- is relaxed by checking the head
  function Strand:relaxedGrad()

    return self._lhs.relaxedGrad()
  end

  Strand.__concat__ = oc.concat

  --- Replace a nerve in the strand with a new module
  -- If the strand has been updated
  --
  -- @param oldModule - The nerve to replace
  -- @param replaceWith - The new nerve 
  -- to put in the strand
  function Strand:replaceModule(oldModule, replaceWith)
    if self._lhs == oldModule then
      self._lhs = replaceWith
    end
    if self._rhs == oldModule then
      self._rhs = replaceWith
    end
  end

  -- @param oldValue
  -- @param newValue
  function Strand:updateRefs(oldValue, newValue)
    oc.ops.table.updateRefs(self, oldModule, newModule)
  end

  ---	@brief Replace an nn.Module 
  -- in an arm with another module
  --        
  -- @param replaceWith - Module to replace 
  -- self with - oc.Strand
  -- @param toReplace - Module to replace 
  -- itself with - nn.Module | oc.Strand
  function Strand.rewire(replaceWith, toReplace)  
    if oc.type(toReplace) == myType then
      replaceWith:lhs():rewireIn(toReplace:lhs())
      replaceWith:rhs():rewireOut(toReplace:rhs())
    else
      replaceWith:lhs():rewireIn(toReplace)
      replaceWith:rhs():rewireOut(toReplace)
    end
  end

  --- Strand should not have incoming
  -- Used primarily for sending the bot 
  -- through the network
  function Strand:incoming()
    return nil
  end

  --- Strand should not have outgoing modules
  -- Used primarily for tubing
  function Strand:outgoing()
    return {}
  end
  
  --- @return the internal nerves for the strand - {self._lhs}
  function Strand:internals()
    return {
      self._lhs
    }
  end

  --- Inform grad for the rhs nerve of the strand
  function Strand:informGrad(gradOutput)
    self._rhs:informGrad(gradOutput)
  end

  --- Probe the gradient at the lhs of the strand
  -- @return GradInput from the lhs of the strand
  function Strand:probeGrad()
    if self.gradOn then
      return self._lhs:probeGrad()
    else
      return nil
    end
  end

  --- Inform the lhs of the strand. 
  -- @param input Input to the start of the strand
  function Strand:inform(input)
    self._lhs:inform(input)
  end

  --- Probe the rhs of the strand
  -- @return output of the rhs of the strand
  function Strand:probe()
    return self._rhs:probe()
  end

  --- inform and probe output for the strand
  -- @return value returned from probing the rhs
  function Strand:stimulate(input)
    self:inform(input)
    return self:probe()
  end

  --- Accumulate the gradients
  function Strand:accumulate()
    self._lhs:accumulate()
  end

  --- inform and probe gradOutput for the strand
  -- @return value returned from probing the lhs nerve
  function Strand:stimulateGrad(gradOutput)
    self:informGrad(gradOutput)
    return self:probeGrad()
  end

  function Strand.__eq__(lhs, rhs)
    return lhs:lhs() == rhs:lhs() and
            lhs:rhs() == rhs:rhs()
  end
end


--- Link two nerves together.  
-- Both nerves must not be linked to any other modules
-- @param lhs - The module on the left-hand 
-- side of the concatentation
-- @param rhs  The module on the 
-- right-hand side of the concatenation
-- @return  rhs
oc.Nerve.__concat__ = oc.concat
