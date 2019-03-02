require 'oc.pkg'
require 'nn'
require 'oc.class'
require 'oc.bot.init'
require 'oc.ops.table'
require 'oc.oc'


do
  local Strand, parent = oc.class(
    'oc.Strand'
  )
  --! ####################################
  --! Links multiple nerves together
  --! in a pipeline of processes.
  --!
  --! @example y = p1 .. p2 .. p3
  --!          y:stimulate(value) will send the
  --!          value through p1, p2 and then
  --!          p3.
  --! 
  --!          Note: y .. p4 will just extend
  --!          the strand.
  --!
  --!          oc.nerve(y) will output an Arm.
  --!
  --!          Strand also does not have
  --!          out and grad functions unlike Arm
  --! @input - Whatever the first member nerve takes
  --! @output - Whatever the member nerve outputs
  --! ####################################

  oc.Strand = Strand
  local myType = 'oc.Strand'

  function Strand:__init(...)
    --! @constructor
    --! @param ... - the nerves or nervables that
    --!              make up the strand
    local modules = table.pack(...)
    self._gradOn = true
    rawset(self, '_lhs', modules[1])
    rawset(self, '_rhs', modules[#modules])
  end
  
  function oc.concat(lhs, rhs)
    --! Concatenate two nerves or strands together
    --! to form a strand
    --! @param lhs - left hand side - nerve | strand
    --! @param rhs - right hand side - nerve | strand
    --! @return oc.Strand
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
      -- Neither are strands so simply create 
      --! modules and connect
      return oc.nerve(lhs):connect(oc.nerve(rhs))
    end
  end

  function Strand:lhs()
    --! Get the head of the strand
    --! @return nn.Module
    return self._lhs
  end

  function Strand:rhs()
    --! Get the tail nerve of the strand
    --! @return nn.Module
    return self._rhs
  end

  Strand.root = Strand.lhs
  Strand.leaf = Strand.rhs

  function Strand:__len__()
    --! The number of nerves in the strand
    --! @return int
    return self._rhs:getLength(self._lhs)
  end

  function Strand:gradOn()
    --! Convenience function to turn grad on in
    --! a strand
    --! To be used to define a strand simply
    --! @return oc.Strand
    self._gradOn = true
    oc.bot.call:gradOn():exec(self)
    return self
  end

  function Strand:gradOff()
    --! Convenience function to turn grad off
    --! in a strand when defining the sequence
    --! To be used to define a strand simply
    --! @return oc.Strand
    self.gradOn = false
    oc.bot.call:gradOff():exec(self)
    return self
  end

  function Strand:sub(lower, upper)
    --! Retrieve a sub strand of the strand
    --! @param lower The index of the start of the strand
    --! @param upper the index of the end of the strand
    --! @return oc.Strand
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

  function Strand:seq(lower, upper)
    --! Convert a strand to an nn.Sequential
    --! @param lower The lower bound of the 
    --! sequence - int
    --! @param upper The upper bound of the 
    --! sequence - int
    --! @return nn.Sequential
    local sub = self:sub(lower, upper)
    local mod = nn.Sequential()
    for i=1, #sub do
      mod:add(sub[i])
    end
    return mod
  end

  function Strand:modules()
    local seq, found = self._rhs:getSeq(self._lhs)
    return seq
  end

  function Strand:validStrand()
    --! Determine whether the strand is valid, which
    --! means the left hand side connects to the right
    --! hand side
    --! @return if they connect or not - bool
    if pcall(self._rhs.getLength, self, self._lhs) then
      return true
    else
      return false
    end
  end

  --! Convert the strand or substrand to an Arm 
  --! @param the start of the substrand to retrieve - int
  --! @param the end of the substrand to retrieve - int
  --! @return Arm
  function Strand:arm(lower, upper)
    local subStrand = self:sub(lower, upper)
    local arm = oc.Arm(subStrand)
    return arm
  end

  Strand.__nerve__ = Strand.arm

  function Strand.__index__(self, key)
    --! Retrieve a module or member from a strand
    --! @param key - Key specifying the module
    --! @return nerve, true if exists otherwise false
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
  
  function Strand.__newindex__(self, key, val)
    --! Cannot add to the strand
    -- TODO: Make sure I should not 
    --! be able to add to the strand
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

  function Strand:relaxed()
    --! Check whether the strand is relaxed
    --! by checking the tail nerve
    --! @return bool
    return self._rhs:relaxed()
  end

  function Strand:relaxedGrad()
    --! Check whether the gradient for the strand
    --! is relaxed by checking the head
    --! @return bool
    return self._lhs.relaxedGrad()
  end

  Strand.__concat__ = oc.concat

  function Strand:replaceModule(oldModule, replaceWith)
    --! Replace a nerve in the strand with a new module
    --! If the strand has been updated
    --!
    --! @param oldModule - The nerve to replace
    --! @param replaceWith - The new nerve 
    --! to put in the strand
    if self._lhs == oldModule then
      self._lhs = replaceWith
    end
    if self._rhs == oldModule then
      self._rhs = replaceWith
    end
  end

  function Strand:updateRefs(oldValue, newValue)
    --! 
    --! @param oldValue
    --! @param newValue
    oc.ops.table.updateRefs(self, oldModule, newModule)
  end

  function Strand.rewire(replaceWith, toReplace)  
    --!	@brief Replace an nn.Module 
    --! in an arm with another module
    --!        
    --! @param replaceWith - Module to replace 
    --! self with - oc.Strand
    --! @param toReplace - Module to replace 
    --! itself with - nn.Module | oc.Strand
    if oc.type(toReplace) == myType then
      replaceWith:lhs():rewireIn(toReplace:lhs())
      replaceWith:rhs():rewireOut(toReplace:rhs())
    else
      replaceWith:lhs():rewireIn(toReplace)
      replaceWith:rhs():rewireOut(toReplace)
    end
  end

  function Strand:incoming()
    --! Strand should not have incoming
    --! Used primarily for sending the bot 
    --! through the network
    return nil
  end
  
  function Strand:outgoing()
    --! Strand should not have outgoing modules
    --! Used primarily for tubing
    return {}
  end
  
  function Strand:internals()
    return {
      self._lhs
    }
  end

  function Strand:informGrad(gradOutput)
    --! Inform grad for the end nerve of the strand
    --! @param gradOutput GradOutput
    self._rhs:informGrad(gradOutput)
  end

  function Strand:probeGrad()
    --! Probe the gradient at the head of the strand
    --! @return Grad from the start of the strand
    if self.gradOn then
      return self._lhs:probeGrad()
    else
      return nil
    end
  end

  function Strand:inform(input)
    --! Inform input for the strand.  
    --! Will update the head nerve 
    --! of the strand
    --! @param input Input to the start of the strand
    self._lhs:inform(input)
  end

  function Strand:probe()
    --! Probe the end of the strand
    --! @return output of the beginning of the strand
    return self._rhs:probe()
  end

  function Strand:stimulate(input)
    --! inform and probe output for the strand
    --! @return value returned from probing the tail nerve
    self:inform(input)
    return self:probe()
  end
  
  function Strand:accumulate()
    self._lhs:accumulate()
  end

  function Strand:stimulateGrad(gradOutput)
    --! inform and probe grad for the strand
    --! @return value returned from probing the head nerve
    self:informGrad(gradOutput)
    return self:probeGrad()
  end

  function Strand.__eq__(lhs, rhs)
    return lhs:lhs() == rhs:lhs() and
            lhs:rhs() == rhs:rhs()
    --return torch.isequal(lhs:lhs(), rhs:lhs()) and 
    --       torch.isequal(lhs:rhs(), rhs:rhs())
  end
end


oc.Nerve.__concat__ = oc.concat
--! Link two nerves together.  
--! Both nerves must not be linked to any other modules
--! @param lhs - The module on the left-hand 
--! side of the concatentation
--! @param rhs  The module on the 
--! right-hand side of the concatenation
--! @return  rhs
