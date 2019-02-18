require 'oc.pkg'
require 'oc.class'
require 'oc.oc'
require 'oc.ops.ops'
require 'oc.bot.call'

require 'oc.ops.math'
local mathops = oc.ops.math

--! ######################################
--!	Base nerve modules
--! 
--! oc.Nerve - Nerve forms the basis of all arms.
--!            It is essentially nn.Module
--!            however it removes all of the
--!            methods related to torch classes and
--!            adds in connectivity between nerves.
--!
--! oc.Axon - Axon connects two nerves together.
--!
--! ######################################


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
  local Nerve = oc.class('oc.Nerve')
  oc.Nerve = Nerve
  --! #########################
  --! 
  --! Very similar to nn.Module in 
  --! torch to allow for modules to be 
  --! concatenated into procress streams 
  --! and to be bound to a  tentacle.  
  --!
  --! 
  --! A module can have one 
  --! incoming stream and multiple outgoing 
  --! streams. In addition there is other 
  --! functionality such as being able to
  --! label the module. oc.Nerve should be used 
  --! for as the parent for all modules which
  --! are not guaranteed to have a tensor 
  --! output (i.e. most modules in the oc namespace)
  --!
  --! nerve:inform(input) <- Tells the nerve what
  --!     its input is
  --!
  --! nerve:probe() <- Asks the nerve what
  --!     its output is.  If the nerve has
  --!     been informed and not updated it will call
  --!     updateOutput
  --! 
  --! probeGrad() and informGrad() work the same
  --!   but for backpropagations
  --! 
  --! nerve:relax() <- Tells the nerve that it needs
  --!     to update its output.
  --!
  --! nerve:stimulate(input) <- Convenience function
  --!     that executes inform(input) and probe(input)
  --!     for that nerve
  --!
  --! nerve:accumulate() - Calls accGradParameters
  --!     with the current input and gradOutput
  --!     and accumulates gradient on all outgoing
  --!     nerves (I may want to remove this part)
  --! 
  --! ###################################

  function Nerve.__init(self)
    --! Initialize the module
    --! @param  name - label to assign the module - string
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

  function Nerve:label(name)
    --!	Convenience function to set 
    --! label when declaring a process stream
    --!	@param	name	- New name of the module - string
    --! @return self
    rawset(self, 'name', name)
    return self
  end

  function Nerve:relax()
    --! Relax the nerve (set input, gradOutput to nil)
    --! @post input/gradOuput = nil, module ready to probe
    self._relaxed = true
    self._relaxedGrad = true
    self.input = nil
    self.gradOutput = nil
    -- self.output = nil
    -- self.gradInput = nil
  end

  function Nerve:clearState()
    --! Reset the emissions (gradInput, output) of the module 
    --! TODO: Check if using this ror relax
    self:relax()
    self.gradInput = self:getDefaultGradInput()
    self.output = self:getDefaultOutput()
  end

  function Nerve:relaxed()
    --! Check whether or not module is relaxed 
    --! (i.e. output is not defined)
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
  
  function Nerve:accGradParameters(input, gradOutput)
    --! Update the gradients of any local parameters 
    --! that influence the output
  end
  
  function Nerve:relaxedGrad()
    --! Check whether or not the gradient is ]
    --! relaxed (defined)
    --! @return boolean
    return self._relaxedGrad
  end

  function Nerve:gradFunc(gradFunc)
    --! Set a gradFunc to process the 
    --! gradient outputs
    --! @param gradFunc - Function to compute the
    --! gradient based on the gradOutputs
    self._gradFunc = gradFunc
  end

  function Nerve:relaxStream(deep)
    --! Relax self and all dependent nerves
    local bot = oc.bot.call:relax()
    if not deep then
      bot:shallowDiver()
    end
    bot:forward(self)
  end

  function Nerve:stimulate(input, deepRelax)
    --! Convenience function to do inform and probe 
    --! in one call.
    --! @param input - Input to the module
    --! @param toForce - whether to force updating
    --! @return output - by probing the module
    self:inform(input, deepRelax)
    return self:probe()
  end

  function Nerve:stimulateGrad(gradOutput)
    --! Convenience function to do informGrad 
    --! and probe Grad in one call.
    --! @param gradOuput - gradOutput of outer module
    --! @return gradInput
    self:informGrad(gradOutput)
    local gradInput = self:probeGrad()
    return gradInput
  end

  function Nerve:inform(input, deepRelax)
    --!	Inform the module of the new input
    --!	@param	input - The value to set the 
    --! input to the nerve
    self:relaxStream(deepRelax)
    rawset(self, 'input', input)
  end

  function Nerve:setGradInput(gradInput)
    --! Set the gradInput of the module.
    rawset(self, 'gradInput', gradInput)
    self._relaxedGrad = false
  end

  function Nerve:setOutput(output)
    --! Set the output of the module. 
    --! I am not sure if this is being used still. 
    rawset(self, 'output', output)
    self._relaxed = false
  end

  function Nerve:informGrad(gradOutput)
    --! Inform the module what the gradOutput is
    --! @param gradOutput - value of the output gradient
    self._relaxed = false
    self.gradOutput = gradOutput
  end

  function Nerve:getInput()
    --! Get the input into the module
    --! @return  Input to the module
    local input
    if self.input ~= nil then
      input = self.input
    elseif self._inAxon ~= nil then
      input = self._inAxon:probe()
    end
    return input
  end

  --! TODO: Currently being used by Diction (up i think)
  function Nerve:getGradOutput()
    --! Get the gradient of the outgoing nodes
    --! If a gradFunction has been supplied use that
    --! @return gradOutput
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

  local function toUpdateGradInput(self)
    --! Whether or not to update the grad input
    --! @return boolean
    return self._relaxedGrad
  end
  
  function Nerve:probe()
    --!	Probe output of the module if not 
    --! defined will update it
    --! @retrun output
    local output
    if self:relaxed() then
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

  function Nerve:probeGrad()
    --! Retrieve the gradient of this 
    --! module.  If not defined will update it
    --! @return gradient
    local gradInput = self.gradInput
    -- self._relaxedGrad and 
    -- (not self._relaxed or self.gradOutput)
    if toUpdateGradInput(self) then
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

  function Nerve:accumulate()
    --! Accumulate gradients on this module and 
    --! all outgoing modules if accumulation
    --! of gradients and backpropagation of 
    --! gradients is turned on
    --! TODO: Do I want to change the conditions?
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
  
  --! Nerve state related functions
  function Nerve:gradOn(state)
    --! Turn the gradient back propagation off 
    --! (returns nil) 
    --! @return self (to use in a chain)
    state = state or true
    assert(
      type(state) == 'boolean',
      'Grad state must be of type boolean.'
    )
    self._grad = state
    return self
  end

  function Nerve:accOn(state)
    --! Turn the accumulation of the gradient 
    --! off (returns nil) 
    --! @return self (to use in a chain)
    state = state or true
    assert(
      type(state) == 'boolean',
      'Grad state must be of type boolean.'
    )
    self._acc = state
    return self
  end
  
  function Nerve:backOn(state)
    --! Turn the accumulation of the gradient 
    --! off (returns nil) 
    --! @return self (to use in a chain)
    state = state or true
    self:gradOn(state)
    self:accOn(state)
    return self
  end

  function Nerve:setSuper(super)
    --! Set the super class of the 'owner' of the module
    --! @param  owner 
    if super ~= nil and not self._super then
      self._super = super
      return true
    end
    return false
  end
  
  function Nerve:super()
    --! only used by super ref
    return self._super
  end

  --! Connection related functions
  --! 
  function Nerve:incoming()
    --! Retrieve the incoming nerve
    if self._inAxon then
      return self._inAxon:incoming()
    end
  end
  
  function Nerve:outgoing()
    --! @return Nerve if not the root - {Nerve}
    local outgoing = {}
    for i=1, #self._outAxons do
      table.insert(
          outgoing, self._outAxons[i]:outgoing()
      )
    end
    return outgoing
  end

  function Nerve.rewire(replaceWith, toReplace) 
    
    --!	Replace an nn.Module in an arm with another 
    --! module
    --! @param replaceWith - Module to replace 
    --! self with - nn.Module
    --! @param toReplace - Module to replace 
    --! itself with - nn.Module
    replaceWith:rewireIn(toReplace)
    replaceWith:rewireOut(toReplace)
  end

  function Nerve.rewireOut(replaceWith, toReplace)
    --! 
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

  function Nerve:disconnectOut()
    --! Disconnect all out modules from this module
    for i=1, #self._outAxons do
      self._outAxons[i]:disconnectIn()
    end
    self._outAxons = {}
  end

  function Nerve:disconnectIn(lhs)
    --! Disconnect the incoming module 
    --! from this module
    self._inAxon:disconnect()
    self._inAxon = nil
  end
  
  function Nerve.connect(from, to)
    --! Connect two nerves together to form a chain
    --! @param from - nn.Module
    --! @param to - nn.Module
    --! @return oc.Chain
    assert(
      not rawget(to, '_inAxon'),
      'A node cannot have more than one '.. 
      'nerve feeding into it'
    )
    local axon = Axon(from, to)
    table.insert(from._outAxons, axon)
    to:connectInAxon(axon)
    
    return oc.Chain(from, to)
  end

  --! TODO: I don't think this is necessary
  function Nerve:connectInAxon(axon)
    --! Connect the axon leading into this module
    --! @param axon
    self._inAxon = axon
  end
  
  --! TODO: decide whether to use this
  --! or getChildNerves
  function Nerve:children()
    --! TODO: RENAME AND USE ITERATOR
    --! Retrieve all of the child nerves for the 
    --! nerve.  Child nerves should be in either
    --! self.modules, self._modules or self._module
    --! @return  {oc.Nerve}
    --! @protected
    if self._modules then
      return self._modules
    elseif self.modules then
      return self.modules
    elseif self._module then
      return {self._module}
    end
    return {}
  end
  
    --! TODO: Change getSeq in chain to use this (probably)
  function Nerve.getSeq(to, from)
    --! Get a sequence of modules to a particular 
    --! module from another module
    --! @param to
    --! @param from
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
  
  --! TODO USED BY connectsTo <- so remove
  function Nerve:connectedIn()
    --! Whether or not 
    --! @return boolean
    return self._inAxon ~= nil
  end
  
    --! TODO: USE BOT
  function Nerve.connected(nerve1, nerve2)
    --! See if the nerve connects out to another nerve.
    --! @param nerve - nn.Module
    --! @return boolean
    return nerve2:incoming() == nerve1
         --[[
           torch.isequal(
             nerve2:inAxon:incoming(), nerve1
          )
          --]]
  end
  
  function Nerve.getLength(to, from)
    --! Todo: use bot (set stopping criteria to 'to'
    if to == from or (not to._inAxon and from == nil) then
      return 1
    elseif not to._inAxon then
      error('Not a valid sequence between from and to')
    else
      return 1 + to._inAxon:incoming():getLength(from)
    end
  end

  function Nerve:__nerve__()
    --! Just returns self since it is already a module
    --! And no processing is needed
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
  
  function oc.ops.nerve.isRoot(nerve)
    --! TODO: Don't use this
    --! add functions outgoing, incoming
    return nerve:incoming() == nil
  end

  function oc.ops.nerve.isLeaf(nerve)
    return #nerve:outgoing() == 0
  end
end

do
  Axon = oc.class(
    'oc.Axon', oc.Object
  )
  --! #############################################
  --! Object connecting two nerves
  --! #############################################

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
  
  local function disconnectOutAxon(nerve, axon)
    --! Remove an out axon from this model
    --! @param axon - 
    for i=1, #nerve._outAxons do
      if nerve._outAxons[i] == axon then
        table.remove(nerve._outAxons, i)
        return
      end
    end
    error('The axon passed in does not exist')
  end
  
  local function disconnectInAxon(nerve)
    --! Remove the incoming axon from this module
    nerve._inAxon = nil
  end

  function Axon:disconnect()
    disconnectInAxon(self._incoming, self)
    disconnectOutAxon(self._outgoing, self)
    self._incoming = nil
    self._outgoing = nil
  end

  function Axon:inRelaxed()
    if self._incoming then
      return self._incoming:relaxed()
    end
  end

  function Axon:incoming()
    --! Retrieve the incoming nerve
    return self._incoming
  end

  function Axon:outgoing()
    --! Retrieve the outgoing nerve
    return self._outgoing
  end

  --! accumulate the gradients of all 
  --! of the outgoing modules
  function Axon:accumulate()
    self._outgoing:accumulate()
  end
end
