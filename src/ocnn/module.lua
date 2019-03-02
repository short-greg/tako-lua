require 'oc.nerve'

--! ########################################
--! Extends nn.Module by making it 
--! inherit all of the methods from oc.Nerve
--! And update the constructor so that 
--! the oc.Nerve constructor will be
--! executed.
--!
--! Also provide nn.Module functionality
--! to oc.Nerve
--! 
--! ########################################

local moduleMeta = getmetatable(nn.Module)
setmetatable(moduleMeta, oc.Nerve)

local oldInit = nn.Module.__init
function nn.Module:__init(...)
  oc.Nerve.__init(self)
  oldInit(self, ...)
end

function nn.Module:__index__(key)
  --!	Module (index) <- add indexing support
  --! Index the module. Indexing is done with tables
  --! so as not to have conflict with 
  --! 'members' of the module nerve[{1}][{2}]
  local res = rawget(self, key)
  
  if res then
    return res, true
  end
  if (oc.type(key) == 'number' or 
     oc.type(key) == 'table') and
     oc.isInstance(self) then
    local stream = oc.IndexStrand(self, key)
    return stream, true
  end
  return false
end

function nn.Module:out(input)
  return self:updateOutput(input)
end

function nn.Module:grad(input, gradOutput)
  return self:updateGradInput(input, gradOutput)
end

function oc.Nerve:parameters()
  return {}, {}
end


-- TODO: Update the clone function
-- Modules clone function will copy its sub
-- nerves and incoming/outgoing nerves
-- this is not desirable

-- oc.Nerve.clearState
-- oc.Nerve.parameters ?
-- oc.Nerve.updateParameters
