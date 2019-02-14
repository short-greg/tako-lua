require 'oc.pkg'
require 'oc.nerve'
require 'oc.class'


--! converts all the members to nerves
local nerveMembers

do
  local Adapter, parent = oc.class(
    'oc.Adapter', oc.Nerve
  )
  --! ##################################
  --! An interface to define nerves which
  --! to inform and nerves to probe.  This is useful
  --! when there are nerves merged (using Merge) 
  --! into others using
  --! and you want to inform both nerves with the same
  --! call.
  --! 
  --! @example: y = nn.Linear(2, 2) .. oc.flow.Onto(x) .. 
  --!           ocnn.Concat(1)
  --!           x = nn.Linear(2, 2)
  --!           adapter = oc.Adapter({x, y}, y)
  --! adapter:stimulate({torch.rand(2), torch.rand(2))
  --! 
  --! This will inform x and y then probe y
  --!
  --! @input: {inputs} - inputs to each of the 
  --! inform nerves which are clamped.
  --! @output: {outputs} - outputs from each 
  --! of the probe nerves which are clamped.
  --!
  --! TODO: Change this so we don't need if
  --! statements.  Just use a different
  --! out and grad function depending
  --! on whether a table is passed into
  --! the constructor.
  --! 
  --! ##################################
  
  oc.Adapter = Adapter

  function Adapter:__init(
      informMembers, probeMembers
  )
    --! @param informMembers {nervables to inform}
    --! @param probeMembers {nervables to probe}
    parent.__init(self)
    self._modules = {}
    self._modules.inform = nerveMembers(informMembers)
    self._modules.probe = nerveMembers(probeMembers)
    
    if torch.type(informMembers) == 'table' then
      self._informEmission = true
    else 
      self._informEmission = false
    end
    if torch.type(self._modules.probe) == 'table' then
      self._probeEmission = true
    else 
      self._probeEmission = false
    end
  end

  function Adapter:out(input)
    local output
    if self._informEmission then
      for i=1, #self._modules.inform do
        self._modules.inform[i]:stimulate(input)
      end
    else
      self._modules.inform:stimulate(input)
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
  
  function Adapter:grad(input, gradOutput)
    --! Backpropagate the gradients 
    --! for which the output was turned on
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
  
  function Adapter:getMemberName()
    return {self._modules.inform, self._modules.probe}
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

nerveMembers = function (members)
  --! Mod all the members 
  --! in a list
  --! @param members - Table of member 
  --! modables - {modules}
  --! @return Table of modules - {nn.Module}
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
