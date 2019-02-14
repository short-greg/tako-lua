require 'oc.bot.pkg'
require 'oc.class'


do
  local Nano, parent = oc.class(
    'oc.bot.Nano'
  )
  --! The base class for Nanobots.  Nanobots are objects that 
  --! get passed through a process graph and perform 
  --! some operation on some or all of the nerves 
  --! in the process graph. 
  oc.bot.Nano = Nano

  function Nano:__init(shallow)
    --! @param shallow - Whether the bot should dive
    --! below the current layer (i.e. act on modules that
    --! are members of the current module) - boolean
    self:reset()
    self._deepDive = shallow ~= true
  end

  function Nano:reset()
    --! Reset the state of the bot
    --! @post  All of the nerves are set 
    --! to as being not visited

    self:resetVisited()
  end

  --! @return Whether a particular nerve has been been
  --!         visited by the bot - True or False
  function Nano:hasVisited(nerve)
    return self._visited[nerve] == true
  end

  function Nano:report()
    --! Report on the results of the
    --! nerves that have been visited
  end

  function Nano:resetVisited()
    self._visited = {}
    return self
  end
  
  function Nano:toVisit(nerve)
    return not oc.isTypeOf(nerve, 'oc.Chain')
    --return self._visited[nerve] == nil
  end

  function Nano:__call__(nerve, deep)
    --! @param nerve - 'Visit' a particular nerve
    if self._visited[nerve] == true then
      return false
    end
    self._visited[nerve] = true

    if deep == nil then
      deep = true
    end

    local isNerve = oc.isTypeOf(nerve, 'oc.Nerve')
    local isChain = oc.isTypeOf(nerve, 'oc.Chain')

    if deep and isNerve then
      for name, child in pairs(
        nerve:children()
      ) do
        self:forward(child, deep)
      end
    elseif isChain then
      self:forward(nerve:lhs())
    end

    if self:toVisit(nerve) then
      if isNerve then
        self:visit(nerve)
      else
        error(
          string.format(
            'Trying to visit item that '..
            'is not a chain or nerve.  Type %s',
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

  function Nano:exec(nerve)
    --! Convenience function to visit the nerve 
    --! and all of the nerves downstream and report
    --! @param Nerve to call the bot on
    self:forward(nerve)
    return self:report()
  end
  
  function Nano:execBatch(nerves)
    --! Convenience function to visit the a 
    --! set of nervesnerve 
    --! and all of the nerves downstream and report
    --! @param Nerves to call the bot on - {<key>=<nerve>}
    for i=1, #nerves do
      self:forward(nerves[i])
    end
    return self:report()
  end

  function Nano.reportFor(cls, mod)
    --! Report for a particular module by passing the bot
    --! specified for the module through cls
    --! @param mod - The module to report for - oc.Nerve
    --! @return report from the module - {} 
    return cls():exec(mod)
  end

  function Nano:isDeepDiver()
    --! @return Whether the bot should dive deep
    return self._deepDive
  end

  function Nano:deepDiver()
    --! Set the bot to dive deep
    self._deepDive = true
  end

  function Nano:shallowDiver()
    --! Set the bot to dive shallow
    self._deepDive = false
  end
  
  Nano.clearState = Nano.reset
  
  function Nano:forward(nerve, deep)
    --! Send the bot forward through a stream starting
    --! with nerve
    --! @param nerve - The nerve to send the bot through
    local visited = false
    visited = self(
      nerve, self._deepDive or deep
    )
    if visited then
      for name, outgoing in nerve:outgoing() do
        outgoing:forward(child)
      end
    end
  end

  function Nano:backward(nerve, deep)
    --! Send the bot backwrad through a stream starting
    --! with nerve
    --! @param nerve - The nerve to send the bot through
    local visited = self(
      nerve, self._deepDiver or deep
    )
    
    if visited then
      local incoming = nerve:incoming()
      if incoming ~= nil then
        incoming:backward(child)
      end
    end
  end
end
