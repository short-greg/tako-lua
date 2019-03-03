require 'oc.pkg'
require 'oc.class'
require 'oc.oc'
require 'oc.bot.call'

require 'oc.ops.math'
local mathops = oc.ops.math

---	Base nerve modules
-- 
-- oc.Nerve - Nerve forms the basis of all arms.
-- It is essentially nn.Module
-- however it removes all of the
-- methods related to torch classes and
-- adds in connectivity between nerves
-- oc.Axon - Axon connects two nerves together.


local function rethrowErrors(self, methodName, output)
  local outStr = string.format(
    'Error in %s for module ', methodName
  )
  if self.name ~= nil then
    outStr = outStr ..' '..tostring(self.name)
  end

  error(
    outStr ..' of type '..
    oc.type(self)..' in position ' ..
    self:getLength() .. '\n'.. output
  )
end

local Axon


do
  --- Very similar to nn.Module in 
  -- torch to allow for modules to be 
  -- concatenated into procress streams 
  -- and to be bound to a  tentacle.  
  --
  -- 
  -- A module can have one 
  -- incoming stream and multiple outgoing 
  -- streams. In addition there is other 
  -- functionality such as being able to
  -- label the module. oc.Nerve should be used 
  -- for as the parent for all modules which
  -- are not guaranteed to have a tensor 
  -- output (i.e. most modules in the oc namespace)
  --
  -- nerve:inform(input) <- Tells the nerve what
  -- its input is
  --
  -- nerve:probe() <- Asks the nerve what
  -- its output is.  If the nerve has
  -- been informed and not updated it will call
  -- updateOutput
  -- 
  -- probeGrad() and informGrad() work the same
  --   but for backpropagations
  -- 
  -- nerve:relax() <- Tells the nerve that it needs
  -- to update its output.
  --
  -- nerve:stimulate(input) <- Convenience function
  -- that executes inform(input) and probe(input)
  -- for that nerve
  --
  -- nerve:accumulate() - Calls accGradParameters
  -- with the current input and gradOutput
  -- and accumulates gradient on all outgoing
  -- nerves (I may want to remove this part)

  local Nerve = oc.class('oc.Nerve')
  oc.Nerve = Nerve


  --- Initialize the module
  -- @param  name - label to assign the module - string
  function Nerve.__init(self)
    self._inAxon = nil
    self._outAxons = {}
    self._relaxed = true
    self._relaxedGrad = true
    self.name = nil
    self.gradOutput = nil
    self._grad = true
    self._acc = true
    self._owner = nil
    self._super = nil
  end

  function Nerve:getDefaultOutput()
    return nil
  end

  function Nerve:getDefaultGradInput()
    return nil
  end

  ---	Convenience function to set 
  -- label when declaring a process stream
  --	@param	name	- New name of the module - string
  -- @return self
  function Nerve:label(name)
    rawset(self, 'name', name)
    return self
  end

  --- Relax the nerve (set input, gradOutput to nil)
  -- @post input/gradOuput = nil, module ready to probe
  function Nerve:relax()
    self._relaxed = true
    self._relaxedGrad = true
    self.input = nil
    self.gradOutput = nil
  end

  --- Reset the emissions (gradInput, output) of the module
  function Nerve:clearState()
    self:relax()
    self.gradInput = self:getDefaultGradInput()
    self.output = self:getDefaultOutput()
  end

  --- Check whether or not module is relaxed 
  -- (i.e. output is not defined)
  function Nerve:relaxed()
    return self._relaxed
  end
  
  function Nerve:out(input)
    
  end
  
  function Nerve:grad(input, gradOutput)
    
  end

  function Nerve:updateOutput(input)
    self.output = self:out(input)
    return self.output
  end

  function Nerve:updateGradInput(input, gradOutput)
    self.gradInput = self:grad(input, gradOutput)
    return self.gradInput
  end

  --- Update the gradients of any local parameters 
  -- that influence the output
  function Nerve:accGradParameters(input, gradOutput)

  end

  --- Check whether or not the gradient is ]
  -- relaxed (defined)
  -- @return boolean
  function Nerve:relaxedGrad()
    return self._relaxedGrad
  end

  --- Set a gradFunc to process the 
  -- gradient outputs
  -- @param gradFunc - Function to compute the
  -- gradient based on the gradOutputs
  function Nerve:gradFunc(gradFunc)
    self._gradFunc = gradFunc
  end

  --- Relax self and all dependent nerves
  function Nerve:relaxStream(deep)
    local bot = oc.bot.call:relax()
    if not deep then
      bot:shallowDiver()
    end
    bot:forward(self)
  end

  --- Convenience function to do inform and probe 
  -- in one call.
  -- @param input - Input to the module
  -- @param toForce - whether to force updating
  -- @return output - by probing the module
  function Nerve:stimulate(input, deepRelax)
    self:inform(input, deepRelax)
    return self:probe()
  end

  --- Convenience function to do informGrad 
  -- and probe Grad in one call.
  -- @param gradOuput - gradOutput of outer module
  -- @return gradInput
  function Nerve:stimulateGrad(gradOutput)
    self:informGrad(gradOutput)
    local gradInput = self:probeGrad()
    return gradInput
  end

  ---	Inform the module of the new input
  --	@param	input - The value to set the 
  -- input to the nerve
  function Nerve:inform(input, deepRelax)
    self:relaxStream(deepRelax)
    rawset(self, 'input', input)
  end

  --- Set the gradInput of the module.
  function Nerve:setGradInput(gradInput)
    rawset(self, 'gradInput', gradInput)
    self._relaxedGrad = false
  end

  --- Set the output of the module. 
  -- I am not sure if this is being used still. 
  function Nerve:setOutput(output)
    rawset(self, 'output', output)
    self._relaxed = false
  end

  --- Inform the module what the gradOutput is
  -- @param gradOutput - value of the output gradient
  function Nerve:informGrad(gradOutput)
    self._relaxed = false
    self.gradOutput = gradOutput
  end

  --- Get the input into the module
  -- @return  Input to the module
  function Nerve:getInput()
    local input
    if self.input ~= nil then
      input = self.input
    elseif self._inAxon ~= nil then
      input = self._inAxon:probe()
    end
    return input
  end

  --- Get the gradient of the outgoing nodes
  -- If a gradFunction has been supplied use that
  -- @return gradOutput
  function Nerve:getGradOutput()
    local gradOutput = self.gradOutput
    if gradOutput == nil then
      local gradOutputs = {}
      for i=1, #self._outAxons do
        local gradOut = self._outAxons[i]:probeGrad()
        table.insert(gradOutputs, gradOut)
      end
      if self._gradFunc then
        gradOutputs = self._gradFunc(gradOutputs)
      end
      gradOutput = mathops.sumIfNotNil(gradOutputs)
      self.gradOutput = gradOutput
    end
    return gradOutput
  end

  ---	Probe output of the module if not 
  -- defined will update it
  -- @retrun output
  function Nerve:probe()
    local output
    if self._relaxed == true then
      local input_ = self:getInput()
      local status
      status, output = pcall(
        self.updateOutput, self, input_
      )
      if status == false then
        rethrowErrors(self, 'probe()', output)
      end
      self._relaxed = false
    else
      output = self.output
    end
    return output
  end

  --- Retrieve the gradient of this 
  -- module.  If not defined will update it
  -- @return gradient
  function Nerve:probeGrad()
    local gradInput = self.gradInput
    -- self._relaxedGrad and 
    -- (not self._relaxed or self.gradOutput)
    if self._relaxedGrad == true then
      self._relaxedGrad = false
      local status
      local input_ = self:getInput()
      local gradOutput = self:getGradOutput()
      if self._grad then
        status, gradInput = pcall(
          self.updateGradInput, self, input_, gradOutput
        )
        if status == false then
          rethrowErrors(self, 'probeGrad()', gradInput)
        end
        return gradInput
      else
        return nil
      end
    else
      return gradInput
    end
  end

  --- Accumulate gradients on this module and 
  -- all outgoing modules if accumulation
  -- of gradients and backpropagation of 
  -- gradients is turned on
  function Nerve:accumulate()
    if self._acc then
      local input_ = self:getInput()
      local gradOutput = self:getGradOutput()
      local status, output = pcall(
        self.accGradParameters, self, input_, gradOutput
      )
      if status == false then
        rethrowErrors(self, 'accumulate()', output)
      end
    end
    for i=1, #self._outAxons do
      self._outAxons[i]:accumulate()
    end
  end
  
  --- Nerve state related functions
  -- Turn the gradient back propagation off 
  -- (returns nil) 
  -- @return self (to use in a strand)
  function Nerve:gradOn(state)
    state = state or true
    assert(
      type(state) == 'boolean',
      'Grad state must be of type boolean.'
    )
    self._grad = state
    return self
  end

  --- Turn the accumulation of the gradient 
  -- off (returns nil) 
  -- @return self (to use in a strand)
  function Nerve:accOn(state)
    state = state or true
    assert(
      type(state) == 'boolean',
      'Grad state must be of type boolean.'
    )
    self._acc = state
    return self
  end

  --- Turn the accumulation of the gradient 
  -- off (returns nil) 
  -- @return self (to use in a strand)
  function Nerve:backOn(state)
    state = state or true
    self:gradOn(state)
    self:accOn(state)
    return self
  end

  --- Connection related functions
  -- 
  -- Retrieve the incoming nerve
  function Nerve:incoming()
    if self._inAxon then
      return self._inAxon:incoming()
    end
  end


  --- @return Nerve if not the root - {Nerve}
  function Nerve:outgoing()
    local outgoing = {}
    for i=1, #self._outAxons do
      table.insert(
          outgoing, self._outAxons[i]:outgoing()
      )
    end
    return outgoing
  end

  ---	Replace an nn.Module in an arm with another 
  -- module
  -- @param replaceWith - Module to replace 
  -- self with - nn.Module
  -- @param toReplace - Module to replace 
  -- itself with - nn.Module
  function Nerve.rewire(replaceWith, toReplace) 
    replaceWith:rewireIn(toReplace)
    replaceWith:rewireOut(toReplace)
  end

  --- Rewire the outoing nerves
  -- @param replaceWith - the Nerve to wire into the spot
  -- @param toReplace - the Nerve to replace
  function Nerve.rewireOut(replaceWith, toReplace)
    for i=1, #toReplace._outAxons do
      toReplace._outAxons[i]:replaceIn(replaceWith)
    end
    for i=1, #toReplace._outAxons do
      table.insert(
        replaceWith._outAxons, 
        toReplace._outAxons[i]
      )
    end
    toReplace._outAxons = {}
  end

  --- Rewire the incoming nerve
  -- @param replaceWith - the Nerve to wire into the spot
  -- @param toReplace - the Nerve to replace
  function Nerve.rewireIn(replaceWith, toReplace)
    if toReplace._inAxon then
      assert(
        replaceWith._inAxon == nil,
        'The nerve being inserted into the '.. 
        'stream already has an input.'
      )
      toReplace._inAxon:replaceOut(replaceWith)
      replaceWith._inAxon = toReplace._inAxon
      toReplace._inAxon = nil
    end
  end

  --- Disconnect all out modules from this module
  function Nerve:disconnectOut()
    for i=1, #self._outAxons do
      self._outAxons[i]:disconnectIn()
    end
    self._outAxons = {}
  end

  --- Disconnect the incoming module 
  -- from this module
  function Nerve:disconnectIn(lhs)
    self._inAxon:disconnect()
    self._inAxon = nil
  end

  --- Connect two nerves together to form a strand
  -- @param from - nn.Module
  -- @param to - nn.Module
  -- @return oc.Strand
  function Nerve.connect(from, to)
    assert(
      not rawget(to, '_inAxon'),
      'A node cannot have more than one '.. 
      'nerve feeding into it'
    )
    local axon = Axon(from, to)
    table.insert(from._outAxons, axon)
    to:connectInAxon(axon)
    
    return oc.Strand(from, to)
  end

  --- Connect the axon leading into this module
  -- @param axon
  function Nerve:connectInAxon(axon)
    self._inAxon = axon
  end

  --- TODO: USE ITERATOR TO LOOP OVER INTERNALS
  -- Also, the base oc.Nerve should not retrieve anything
  -- Retrieve all of the child nerves for the 
  -- nerve.  Child nerves should be in either
  -- self.modules, self._modules or self._module
  -- @return  {oc.Nerve}
  function Nerve:internals()
    if self._modules then
      return self._modules
    elseif self.modules then
      return self.modules
    elseif self._module then
      return {self._module}
    end
    return {}
  end
  
  --- Get a sequence of modules to a particular 
  -- module from another module
  -- @param to - The end of the sequence - oc.Nerve
  -- @param from - The beginning of the sequence - oc.Nerve
  -- TODO: Change getSeq in strand to use this (probably
  function Nerve.getSeq(to, from)
    local modules
    local found
    if to == from or
       (to:incoming() == nil and from == nil) then
      modules = {to}
      found = true
    elseif to:incoming() == nil and to ~= from then
      modules = {}
      found = false
    else
      modules, found = to:incoming():getSeq(from)
      if found then
        table.insert(modules, to)
      end
    end
    return modules, found
  end

  --- @return Whether or not there is an incoming nerve - boolean
  -- TODO USED BY connectsTo <- so remove
  function Nerve:connectedIn()
    return self._inAxon ~= nil
  end
  
  --- See if the nerve connects out to another nerve.
  -- @param nerve - oc.Nerve
  -- @return boolean
  -- TODO: USE BOT
  function Nerve.connected(nerve1, nerve2)
    return nerve2:incoming() == nerve1
  end

  --- @param to - The end of the sequence - oc.Nerve
  -- @param from - The beginning of the sequence - oc.Nerve
  -- @return - Get the length of a sequence
  -- Todo: use bot (set stopping criteria to 'to'
  function Nerve.getLength(to, from)
    if to == from or (not to._inAxon and from == nil) then
      return 1
    elseif not to._inAxon then
      error('Not a valid sequence between from and to')
    else
      return 1 + to._inAxon:incoming():getLength(from)
    end
  end

  --- Just returns self since it is already a module
  -- And no processing is needed
  function Nerve:__nerve__()
    return self
  end
end


do
  oc.ops = oc.ops or {}
  oc.ops.nerve = oc.ops.nerve or {}

  function oc.ops.nerve.getLength(to, from)
    if to == from or 
       (not to._inAxon and from == nil) then
      return 1
    elseif not to._inAxon then
      error('Not a valid sequence between from and to')
    else
      return 1 + to._inAxon:incoming():getLength(from)
    end
  end

  --- TODO: Don't use this
  -- add functions outgoing, incoming
  function oc.ops.nerve.isRoot(nerve)
    return nerve:incoming() == nil
  end

  function oc.ops.nerve.isLeaf(nerve)
    return #nerve:outgoing() == 0
  end
end

do
  --- Object connecting two nerves
  Axon = oc.class(
    'oc.Axon', oc.Object
  )
  oc.Axon = Axon

  function Axon:__init(incoming, outgoing)
    self._incoming = incoming
    self._outgoing = outgoing
  end

  function Axon:getIncomingOutput()
    return self._incoming.output
  end

  function Axon:getOutgoingGradOutput()
    return self._outgoing.gradInput
  end

  function Axon:probe()
    return self._incoming:probe()
  end

  function Axon:probeGrad()
    return self._outgoing:probeGrad()
  end

  function Axon:replaceIn(incoming)
    self._incoming = incoming
  end

  function Axon:replaceOut(outgoing)
    self._outgoing = outgoing
  end

  --- Remove an out axon from this model
  -- @param axon - 
  local function disconnectOutAxon(nerve, axon)
    for i=1, #nerve._outAxons do
      if nerve._outAxons[i] == axon then
        table.remove(nerve._outAxons, i)
        return
      end
    end
    error('The axon passed in does not exist')
  end

  --- Remove the incoming axon from this module
  local function disconnectInAxon(nerve)
    nerve._inAxon = nil
  end

  function Axon:disconnect()
    disconnectInAxon(self._incoming, self)
    disconnectOutAxon(self._outgoing, self)
    self._incoming = nil
    self._outgoing = nil
  end

  --- @return true if incoming is relazed, false if not
  -- nil if no incoming - bool or nil
  function Axon:inRelaxed()
    if self._incoming then
      return self._incoming:relaxed()
    end
  end

  --- @return incoming nerve - nerve
  function Axon:incoming()
    return self._incoming
  end

  --- @return outgoing nerves - {nerve}
  function Axon:outgoing()
    return self._outgoing
  end

  function Axon:accumulate()
    self._outgoing:accumulate()
  end
end
