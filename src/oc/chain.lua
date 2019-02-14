require 'oc.pkg'
require 'nn'
require 'oc.class'
require 'oc.bot.init'
require 'oc.ops.table'
require 'oc.oc'


do
  local Chain, parent = oc.class(
    'oc.Chain'
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
  --!          the chain.
  --!
  --!          oc.nerve(y) will output an Arm.
  --!
  --!          Chain also does not have
  --!          out and grad functions unlike Arm
  --! @input - Whatever the first member nerve takes
  --! @output - Whatever the member nerve outputs
  --! ####################################

  oc.Chain = Chain
  local myType = 'oc.Chain'

  function Chain:__init(...)
    --! @constructor
    --! @param ... - the nerves or nervables that
    --!              make up the chain
    local modules = table.pack(...)
    self._gradOn = true
    rawset(self, '_lhs', modules[1])
    rawset(self, '_rhs', modules[#modules])
  end
  
  function oc.concat(lhs, rhs)
    --! Concatenate two nerves or chains together
    --! to form a chain
    --! @param lhs - left hand side - nerve | chain
    --! @param rhs - right hand side - nerve | chain
    --! @return oc.Chain
    local stream
    local modules
    -- Arms should not be concatenated
    if oc.type(lhs) == 'oc.Arm' then
      lhs = lhs:chain()
    end
    if oc.type(rhs) == 'oc.Arm' then
      rhs = rhs:chain()
    end
    if oc.isTypeOf(lhs, myType) and 
       oc.isTypeOf(rhs, myType) then
      local mid = lhs:rhs() .. rhs:lhs()
      return oc.Chain(
        table.unpack(
          oc.ops.table.listCat(
            lhs:modules(), rhs:modules()
          )
        )
      )
    elseif oc.isTypeOf(lhs, myType) then
      local rhsmod = oc.nerve(rhs)
      local _ = lhs:rhs() .. rhsmod
      return oc.Chain(
        table.unpack(
          oc.ops.table.listCat(lhs:modules(), {rhsmod})
        )
      )
    elseif oc.isTypeOf(rhs, myType) then
      local lhsmod = oc.nerve(lhs)
      local _ = lhsmod .. rhs:lhs()
      return oc.Chain(
        table.unpack(
          oc.ops.table.listCat({lhsmod}, rhs:modules())
        )
      )
    else 
      -- Neither are chains so simply create 
      --! modules and connect
      return oc.nerve(lhs):connect(oc.nerve(rhs))
    end
  end

  function Chain:lhs()
    --! Get the head of the chain
    --! @return nn.Module
    return self._lhs
  end

  function Chain:rhs()
    --! Get the tail nerve of the chain
    --! @return nn.Module
    return self._rhs
  end

  Chain.root = Chain.lhs
  Chain.leaf = Chain.rhs

  function Chain:__len__()
    --! The number of nerves in the chain
    --! @return int
    return self._rhs:getLength(self._lhs)
  end

  function Chain:gradOn()
    --! Convenience function to turn grad on in
    --! a chain
    --! To be used to define a chain simply
    --! @return oc.Chain
    self._gradOn = true
    oc.bot.call:gradOn():exec(self)
    return self
  end

  function Chain:gradOff()
    --! Convenience function to turn grad off
    --! in a chain when defining the sequence
    --! To be used to define a chain simply
    --! @return oc.Chain
    self.gradOn = false
    oc.bot.call:gradOff():exec(self)
    return self
  end

  function Chain:sub(lower, upper)
    --! Retrieve a subchain of the chain
    --! @param lower The index of the start of the chain
    --! @param upper the index of the end of the chain
    --! @return oc.Chain
    local modules = self._rhs:getSeq(self._lhs)
    lower = lower or 1
    upper = upper or #modules
    assert(lower <= upper, 'Lower must be <= upper')
    
    local chain = oc.Chain(table.unpack(
      modules, lower, upper
    ))
    chain.gradOn = self.gradOn
    return chain
  end

  function Chain:seq(lower, upper)
    --! Convert a chain to an nn.Sequential
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

  function Chain:modules()
    return self._rhs:getSeq(self._lhs)
  end

  function Chain:validChain()
    --! Determine whether the chain is valid, which
    --! means the left hand side connects to the right
    --! hand side
    --! @return if they connect or not - bool
    if pcall(self._rhs.getLength, self, self._lhs) then
      return true
    else
      return false
    end
  end

  --! Convert the chain or subchain to an Arm 
  --! @param the start of the subchain to retrieve - int
  --! @param the end of the subchain to retrieve - int
  --! @return Arm
  function Chain:arm(lower, upper)
    local subChain = self:sub(lower, upper)
    local arm = oc.Arm(subChain)
    return arm
  end

  Chain.__nerve__ = Chain.arm

  function Chain.__index__(self, key)
    --! Retrieve a module or member from a chain
    --! @param key - Key specifying the module
    --! @return nerve, true if exists otherwise false
    if rawget(Chain, key) then
      return rawget(Chain, key)
    end
    
    if type(key) == 'number' then
      local modules = self._rhs:getSeq(self._lhs)
      if modules and modules[key] then
        return modules[key]
      end
    end
  end
  
  function Chain.__newindex__(self, key, val)
    --! Cannot add to the chain
    -- TODO: Make sure I should not 
    --! be able to add to the chain
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

  function Chain:relaxed()
    --! Check whether the chain is relaxed
    --! by checking the tail nerve
    --! @return bool
    return self._rhs:relaxed()
  end

  function Chain:relaxedGrad()
    --! Check whether the gradient for the chain
    --! is relaxed by checking the head
    --! @return bool
    return self._lhs.relaxedGrad()
  end

  Chain.__concat__ = oc.concat

  function Chain:replaceModule(oldModule, replaceWith)
    --! Replace a nerve in the chain with a new module
    --! If the chain has been updated
    --!
    --! @param oldModule - The nerve to replace
    --! @param replaceWith - The new nerve 
    --! to put in the chain
    if self._lhs == oldModule then
      self._lhs = replaceWith
    end
    if self._rhs == oldModule then
      self._rhs = replaceWith
    end
  end

  function Chain:updateRefs(oldValue, newValue)
    --! 
    --! @param oldValue
    --! @param newValue
    oc.ops.table.updateRefs(self, oldModule, newModule)
  end

  function Chain.rewire(replaceWith, toReplace)  
    --!	@brief Replace an nn.Module 
    --! in an arm with another module
    --!        
    --! @param replaceWith - Module to replace 
    --! self with - oc.Chain
    --! @param toReplace - Module to replace 
    --! itself with - nn.Module | oc.Chain
    if oc.type(toReplace) == myType then
      replaceWith:lhs():rewireIn(toReplace:lhs())
      replaceWith:rhs():rewireOut(toReplace:rhs())
    else
      replaceWith:lhs():rewireIn(toReplace)
      replaceWith:rhs():rewireOut(toReplace)
    end
  end

  function Chain:incoming()
    --! Chain should not have incoming
    --! Used primarily for sending the bot 
    --! through the network
    return nil
  end
  
  function Chain:outgoing()
    --! Chain should not have outgoing modules
    --! Used primarily for tubing
    return {}
  end
  
  function Chain:children()
    return {
      self._lhs
    }
  end

  function Chain:informGrad(gradOutput)
    --! Inform grad for the end nerve of the chain
    --! @param gradOutput GradOutput
    self._rhs:informGrad(gradOutput)
  end

  function Chain:probeGrad()
    --! Probe the gradient at the head of the chain
    --! @return Grad from the start of the chaing
    if self.gradOn then
      return self._lhs:probeGrad()
    else
      return nil
    end
  end

  function Chain:inform(input)
    --! Inform input for the chain.  
    --! Will update the head nerve 
    --! of the chain
    --! @param input Input to the start of the chain
    self._lhs:inform(input)
  end

  function Chain:probe()
    --! Probe the end of the chain
    --! @return output of the beginning of the chain
    return self._rhs:probe()
  end

  function Chain:stimulate(input)
    --! inform and probe output for the chain
    --! @return value returned from probing the tail nerve
    self:inform(input)
    return self:probe()
  end
  
  function Chain:accumulate()
    self._lhs:accumulate()
  end

  function Chain:stimulateGrad(gradOutput)
    --! inform and probe grad for the chain
    --! @return value returned from probing the head nerve
    self:informGrad(gradOutput)
    return self:probeGrad()
  end

  function Chain.__eq__(lhs, rhs)
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
