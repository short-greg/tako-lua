require 'oc.bot.pkg'
require 'oc.bot.nano'
require 'oc.class'


--! ################################
--!
--! Bots used to retrieve information
--! from the nerves it passes through.
--! ################################

oc.bot.get = {}

do
  local Param, parent = oc.class(
    'oc.bot.get.Param', oc.bot.Nano
  )
  --! #################################
  --!
  --! Retrieve all of the trainable 
  --! parameters associated
  --! with a particular process tree.
  --! This is used by Optim.
  --!
  --! y = nn.Linear(2, 2) ..
  --!       nn.Linear(2, 2) ..
  --!       nn.Sigmoid()
  --!
  --! params = oc.bot.get.Param:reportFor(y)
  --!
  --! #################################
  oc.bot.get.Param = Param
  
  function Param:__init(...)
    parent.__init(self, ...)
    self:reset()
  end
  
  function Param:reset()
    parent.reset(self)
    self._seq = nn.Sequential()
  end

  function Param:report()
    --! Retrieve the parameters for the process
    --! stream
    local x, dx = self._seq:getParameters()
    return {x=x, dx=dx}
  end

  function Param:visit(nerve)
    self._seq:add(nerve)
    return nerve
  end
end


do
  local Nerve, parent = oc.class(
    'oc.bot.get.Nerve', oc.bot.Nano
  )
  --! #################################
  --! Retrieves all the nerves that
  --! the bot passes through.
  --!
  --! y = nn.Linear(2, 2) ..
  --!       nn.Linear(2, 2) ..
  --!       nn.Sigmoid()
  --!
  --! nerves = oc.bot.get.Nerve:reportFor(y)
  --!
  --! #################################
  oc.bot.get.Nerve = Nerve
  
  function Nerve:__init(...)
    parent.__init(self, ...)
    self._modules = {}
  end
  
  function Nerve:reset()
    modget.parent.reset(self)
    self._modules = {}
  end
  
  function Nerve:report()
    --! @return Nerves in the process tree - {nerve}
    return self._modules
  end
  
  function Nerve:visit(nerve)
    table.insert(self._modules, nerve)
    return nerve
  end
end


do
  local Leaf, parent = oc.class(
    'oc.bot.get.Leaf', oc.bot.get.Nerve
  )
  --! #################################
  --! Retrieves all the leaf nodes that
  --! the bot passes through.
  --!
  --! y = nn.Linear(2, 2) ..
  --!       nn.Linear(2, 2) ..
  --!       nn.Sigmoid()
  --!
  --! leaves = oc.bot.get.Leaf:reportFor(y)
  --!
  --! #################################
  oc.bot.get.Leaf = Leaf
  
  function Leaf:toVisit(nerve)
    --! Only add leaf nodes to the
    --! list of nerves
    if nerve:isLeaf() then
      return parent.toVisit(self, nerve)
    end
    return false
  end
end
