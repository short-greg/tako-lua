require 'oc.bot.pkg'
require 'oc.bot.nano'
require 'oc.class'


--- Bots used to retrieve information
-- from the nerves it passes through.

oc.bot.get = {}

do
  --- Retrieve all of the trainable 
  -- parameters associated
  -- with a particular process tree.
  -- This is used by Optim.
  --
  -- y = nn.Linear(2, 2) ..
  --       nn.Linear(2, 2) ..
  --       nn.Sigmoid()
  --
  -- params = oc.bot.get.Param:reportFor(y)
  local Param, parent = oc.class(
    'oc.bot.get.Param', oc.bot.Nano
  )
  oc.bot.get.Param = Param
  
  function Param:__init(...)
    parent.__init(self, ...)
    self:reset()
  end
  
  function Param:reset()
    parent.reset(self)
    self._seq = nn.Sequential()
  end

  --- Retrieve the parameters for the process
  -- stream
  function Param:report()
    local x, dx = self._seq:getParameters()
    return {x=x, dx=dx}
  end

  function Param:visit(nerve)
    self._seq:add(nerve)
    return nerve
  end
end


do
  --- Retrieves all the nerves that
  -- the bot passes through.
  --
  -- y = nn.Linear(2, 2) ..
  --       nn.Linear(2, 2) ..
  --       nn.Sigmoid()
  --
  -- nerves = oc.bot.get.Nerve:reportFor(y)
  local Nerve, parent = oc.class(
    'oc.bot.get.Nerve', oc.bot.Nano
  )
  oc.bot.get.Nerve = Nerve
  
  function Nerve:__init(...)
    parent.__init(self, ...)
    self._modules = {}
  end
  
  function Nerve:reset()
    modget.parent.reset(self)
    self._modules = {}
  end
  
  --- @return Nerves in the process tree - {nerve}
  function Nerve:report()
    return self._modules
  end
  
  function Nerve:visit(nerve)
    table.insert(self._modules, nerve)
    return nerve
  end
end


do
  --- Retrieves all the leaf nodes that
  -- the bot passes through.
  --
  -- y = nn.Linear(2, 2) ..
  --       nn.Linear(2, 2) ..
  --       nn.Sigmoid()
  --
  -- leaves = oc.bot.get.Leaf:reportFor(y)
  local Leaf, parent = oc.class(
    'oc.bot.get.Leaf', oc.bot.get.Nerve
  )
  oc.bot.get.Leaf = Leaf

  --- Only add leaf nodes to the
  -- list of nerves
  function Leaf:toVisit(nerve)
    if nerve:isLeaf() then
      return parent.toVisit(self, nerve)
    end
    return false
  end
end
