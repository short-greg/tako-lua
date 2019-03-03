require 'oc.bot.pkg'
require 'oc.class'


do
  --- The base class for Nanobots.  Nanobots are objects that 
  -- get passed through a process graph and perform 
  -- some operation on some or all of the nerves 
  -- in the process graph. 
  local Nano, parent = oc.class(
    'oc.bot.Nano'
  )
  oc.bot.Nano = Nano

  --- @param shallow - Whether the bot should dive
  -- below the current layer (i.e. act on modules that
  -- are members of the current module) - boolean
  function Nano:__init(shallow)
    self:reset()
    self._deepDive = shallow ~= true
  end

  --- Reset the state of the bot
  -- @post  All of the nerves are set 
  -- to as being not visited
  function Nano:reset()
    self:resetVisited()
  end

  --- @return Whether a particular nerve has been been
  --         visited by the bot - True or False
  function Nano:hasVisited(nerve)
    return self._visited[nerve] == true
  end

  --- Report on the results of the
  -- nerves that have been visited
  function Nano:report()
    --
  end

  function Nano:resetVisited()
    self._visited = {}
    return self
  end
  
  function Nano:toVisit(nerve)
    return not oc.isTypeOf(nerve, 'oc.Strand')
  end

  --! @param nerve - 'Visit' a particular nerve
  function Nano:__call__(nerve, deep)
    if self._visited[nerve] == true then
      return false
    end
    self._visited[nerve] = true

    if deep == nil then
      deep = true
    end

    local isNerve = oc.isTypeOf(nerve, 'oc.Nerve')
    local isStrand = oc.isTypeOf(nerve, 'oc.Strand')

    if deep and isNerve then
      for name, child in pairs(
        nerve:internals()
      ) do
        self:forward(child, deep)
      end
    elseif isStrand then
      self:forward(nerve:lhs())
    end

    if self:toVisit(nerve) then
      if isNerve then
        self:visit(nerve)
      else
        error(
          string.format(
            'Trying to visit item that '..
            'is not a strand or nerve.  Type %s',
            oc.type(nerve)
          )
        )
      end
    end
    return true
  end
  
  function Nano:visit(nerve)
    error(
      'Visit function not defined '.. 
      'for base class Nanobot.'
    )
  end

  --- Convenience function to visit the nerve 
  -- and all of the nerves downstream and report
  -- @param Nerve to call the bot on
  function Nano:exec(nerve)
    self:forward(nerve)
    return self:report()
  end

  --- Convenience function to visit the a 
  -- set of nervesnerve 
  -- and all of the nerves downstream and report
  -- @param Nerves to call the bot on - {<key>=<nerve>}
  function Nano:execBatch(nerves)
    for i=1, #nerves do
      self:forward(nerves[i])
    end
    return self:report()
  end

  --- Report for a particular module by passing the bot
  -- specified for the module through cls
  -- @param mod - The module to report for - oc.Nerve
  -- @return report from the module - {} 
  function Nano.reportFor(cls, mod)
    return cls():exec(mod)
  end

  --- @return Whether the bot should dive deep
  function Nano:isDeepDiver()
    return self._deepDive
  end

  --- Set the bot to dive deep
  function Nano:deepDiver()
    self._deepDive = true
  end

  --- Set the bot to dive shallow
  function Nano:shallowDiver()
    self._deepDive = false
  end
  
  Nano.clearState = Nano.reset
  
  --- Send the bot forward through a stream starting
  -- with nerve
  -- @param nerve - The nerve to send the bot through
  function Nano:forward(nerve, deep)
    local visited = false
    visited = self(
      nerve, self._deepDive or deep
    )
    if visited then
      for name, outgoing in pairs(nerve:outgoing()) do
        self:forward(outgoing)
      end
    end
  end

  --- Send the bot backwrad through a stream starting
  -- with nerve
  -- @param nerve - The nerve to send the bot through
  function Nano:backward(nerve, deep)
    local visited = self(
      nerve, self._deepDiver or deep
    )
    
    if visited then
      local incoming = nerve:incoming()
      if incoming ~= nil then
        self:backward(incoming)
      end
    end
  end
end
