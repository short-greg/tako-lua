require 'oc.pkg'
require 'oc.class'
require 'oc.nerve'


--- converts all the members to nerves
local nerveMembers

do
  --- An interface to define nerves which
  -- to inform and nerves to probe.  This is useful
  -- when there are nerves merged (using Merge) 
  -- into others using
  -- and you want to inform both nerves with the same
  -- call.
  -- 
  -- @usage: y = nn.Linear(2, 2) .. oc.flow.Onto(x) .. 
  --           ocnn.Concat(1)
  --           x = nn.Linear(2, 2)
  --           adapter = oc.Adapter({x, y}, y)
  -- adapter:stimulate({torch.rand(2), torch.rand(2))
  -- 
  -- This will inform x and y then probe y
  --
  -- @input: {inputs} - inputs to each of the 
  -- inform nerves which are clamped.
  -- @output: {outputs} - outputs from each 
  -- of the probe nerves which are clamped.
  --
  -- TODO: Change this so we don't need if
  -- statements.  Just use a different
  -- out and grad function depending
  -- on whether a table is passed into
  -- the constructor.
  local Adapter, parent = oc.class(
    'oc.Adapter', oc.Nerve
  )
  oc.Adapter = Adapter

  --- @constructor
  -- @param informMembers {nervables to inform}
  -- @param probeMembers {nervables to probe}
  function Adapter:__init(
      informMembers, probeMembers
  )
    parent.__init(self)
    self._modules = {}
    informMembers = nerveMembers(informMembers)
    probeMembers = nerveMembers(probeMembers)
    self._modules.inform = informMembers
    self._modules.probe = probeMembers
    local informChildren = {}
    local probeChildren = {}
    
    if oc.type(informMembers) == 'table' then
      informChildren = informMembers
      self._informEmission = true
    else 
      informChildren = {informMembers}
      self._informEmission = false
    end
    if oc.type(probeMembers) == 'table' then
      probeChildren = probeMembers
      self._internals = {
        table.unpack(informMembers)
      }
      self._probeEmission = true
    else 
      probeChildren = {probeMembers}
      self._probeEmission = false
    end
    self._internals = {table.unpack(informChildren)}
    for i=1, #probeChildren do
      table.insert(self._internals, probeChildren[i])
    end
  end
  
  function Adapter:internals()
    return self._internals
  end
  
  function Adapter:out(input)
    local output

    if self._informEmission then
      for i=1, #self._modules.inform do
        self._modules.inform[i]:inform(input[i])
      end
    else
      self._modules.inform:inform(input)
    end
    
    if self._probeEmission then
      output = {}
      for i=1, #self._modules.probe do
        table.insert(
          output, i, self._modules.probe[i]:probe()
        )
      end
    else
      output = self._modules.probe:probe()

    end
    return output
  end
  
  --- Inform all of the nerves to inform and
  -- probe all of them to probe
  function Adapter:grad(input, gradOutput)
    self:updateOutput(input)
    gradOutput = gradOutput or {}
    local gradInput
      
    if self._probeEmission then
      for i=1, #self._modules.probe do
        self._modules.probe[i]:stimulateGrad(
          gradOutput[i]
        )
      end
    else
      self._modules.probe:stimulateGrad(
        gradOutput
      )
    end
      
    if self._informEmission then
      gradInput = {}
      for i=1, #self._modules.inform do
        table.insert(
          gradInput, i, self._modules.inform[i]:probeGrad()
        )
      end
    else 
      gradInput = self._modules.inform[i]:probe()
    end
    return gradInput
  end
  
  function Adapter:accGradParameters(
      input, gradOutput
  )
    if self._informEmission then
      for i=1, #self._modules.inform do
        self._modules.inform[i]:accumulate()
      end
    else
      self._modules.inform:accumulate()
    end
  end

  function Adapter:getNerves()
    local members = {{}, {}}
    for i=1, #self._modules.inform do
      table.insert(
        members[1], self._modules.inform[i]
      ) 
    end
      
    for i=1, #self._probeMembers do
      table.insert(
        members[1], self._modules.probe[i]
      ) 
    end
    return members
  end
end

--- Convert all the members 
-- in a list to nerves
-- @param members - Table of nervables - {nervable}
-- @return Table of modules - {oc.Nerve}
nerveMembers = function (members)
  if oc.type(members) == 'table' then
    local modded = {}
    for i=1, #members do
      table.insert(modded, oc.nerve(members[i]))
    end
    return modded
  else
    return oc.nerve(members)
  end
end
