require 'oc.bot.pkg'
require 'oc.bot.nano'
require 'oc.class'
require 'oc.oc'
require 'oc.nerve'

---
-- Nanobots that alter the state of the
-- nerves or alter the nerve itself that they
-- visit

oc.bot.store = {}
require 'oc.bot.nano'

do
  --- Stores emissions from each nerve
  -- it is passed through.
  local Storer, parent = oc.class(
    'oc.bot.store.Storer', oc.bot.Nano
  )
  oc.bot.store.Storer = Storer

  function Storer:__init(...)
    parent.__init(self, ...)
    self._execFunc = nil
    self._nerveFunc = nil
    self:reset()
  end
  
  function Storer:report()
    return
  end
  
  function Storer:reset()
    parent.reset(self)
    self:probe()
    self:out()
    self._gradInputs = {}
    self._outputs = {}
    self._inputs = {}
    self._gradOutputs = {}
  end

  function Storer:getOutputs()
    return self._outputs
  end
  
  function Storer:getGradInputs()
    return self._gradInputs
  end
  
  function Storer:getGradOutputs()
    return self._gradOutputs
  end
  
  function Storer:getInputs()
    return self._inputs
  end
  
  function Storer:setNerveOut(nerve, output)
    self._outputs[nerve] = output
  end
  
  function Storer:setNerveInput(nerve, input_)
    self._outputs[nerve] = input_
  end
  
  function Storer:setNerveGradInput(nerve, gradInput)
    self._gradInputs[nerve] = output
  end

  function Storer:setNerveGradOut(nerve, gradOutput)
    self._gradOutputs[nerve] = gradOutput
  end

  function Storer:acc()
    self:resetVisited()
    self._informFunc = self._informForAcc
    self._probeFunc = self._probeForAcc
    return self
  end
  
  function Storer:out()
    self:resetVisited()
    self._informFunc = self._informForOut
    self._probeFunc = self._probeForOut
    return self
  end
  
  function Storer:grad()
    self:resetVisited()
    self._informFunc = self._informForGrad
    self._probeFunc = self._probeForGrad
    return self
  end
  
  function Storer:inform()
    --! 
    self:resetVisited()
    self._execFunc = self._posInform
    return self
  end

  function Storer:probe()
    --! @summary - Set state to probe
    --! @return - self
    self:resetVisited()
    self._execFunc = self._posProbe
    return self
  end
  
  function Storer:_informForOut(nerve)
    -- Do Nothing
  end
  
  function Storer:_informForGrad(nerve)
    nerve:setOutput(self._outputs[nerve])
    if self._inputs[nerve] then
      nerve.input = self._inputs[nerve]
    end
  end
  
  function Storer:_informForAcc(nerve)
    nerve:setOutput(self._outputs[nerve])
    nerve:setGradInput(self._gradInputs[nerve])
    if self._gradOutputs[nerve] then
      nerve.gradOutput = self._gradOutputs[nerve]
    end
    if self._inputs[nerve] then
      nerve.input = self._inputs[nerve]
    end
  end

  function Storer:_posInform(nerve)
    --! @summary Position is inform 
    --! @param nerve - nerve to inform - oc.Nerve
    self:_informFunc(nerve)
  end

  function Storer:_probeForOut(nerve)
    self._outputs[nerve] = nerve.output
    
    if nerve.input then
      self._inputs[nerve] = nerve.input
    else
      self._inputs[nerve] = nil
    end
  end
  
  function Storer:_probeForGrad(nerve)
    self._gradInputs[nerve] = nerve.gradInput
    
    if nerve.gradOutput then
      self._gradOutputs[nerve] = nerve.gradOutput
    else
      self._gradOutputs[nerve] = nil
    end
  end
  
  function Storer:_probeForAcc(nerve)
    -- Do Nothing
  end

  function Storer:_posProbe(nerve)
    --! @summary Position is probe
    --! @param nerve - Nerve to probe - oc.Nerve
    self:_probeFunc(nerve)
  end

  function Storer:visit(nerve)
    --! Visit the module and relax it
    --! @param nerve - Nerve to execute on - oc.Nerve
    --! @return nerve - Nerve that has been 
    --! probed or informed - 
    self:_execFunc(nerve)
    return nerve
  end  
end


do
  local NullStorer, parent = oc.class(
    'oc.bot.store.NullStorer', oc.bot.store.Storer
  )
  oc.bot.store.NullStorer = NullStorer
  
  function NullStorer:_nullFunc()
    
  end
  
  function NullStorer:acc()
    return self
  end
  
  function NullStorer:out()
    return self
  end
  
  function NullStorer:grad()
    return self
  end
  
  function NullStorer:probe()
    self._execFunc = self._nullFunc
    return self
  end
  
  function NullStorer:inform()
    self._execFunc = self._nullFunc
    return self
  end
  
  function NullStorer:forward(nerve)
    --! Does not do anything so it should be null
    --! @param nerve - Nerve to execute on - oc.Nerve
    --! @return nerve - Nerve that has been 
    --! probed or informed - 
    return nerve
  end  
end


do
  local MultiStorer, parent = oc.class(
    'oc.bot.store.MultiStorer', 
    oc.bot.store.Storer
  )

  oc.bot.store.MultiStorer = MultiStorer
  
  function MultiStorer:__init(storer, ...)
    assert(
      oc.isTypeOf(storer, oc.bot.store.Storer),
      'Argument storer must be of type '..  
      'oc.bot.store.Storer.'
    )
    self._baseStorer = storer
    self._storerArgs = table.pack(...)
    self._storer = nil
    self._storers = {}
    self._toStimulate = self.out
    self._toStimulateEnd = self.inform
    self:index(1)
  end
  
  function MultiStorer:reset()
    --! TODO: Think how I should handle this
    parent.reset(self)
    self._storers = {}
    self:index(1)
  end
  
  function MultiStorer:visit(nerve)
    --! Visit the module and relax it
    --! @param nerve - Nerve to execute on - oc.Nerve
    --! @return nerve - Nerve that has been 
    --! probed or informed - 
    self._storer:visit(nerve)
    return nerve
  end  

  function MultiStorer:acc()
    self._storer:acc()
    self._toStimulate = self.acc
    return self
  end
  
  function MultiStorer:out()
    self._storer:out()
    self._toStimulate = self.out
    return self
  end
  
  function MultiStorer:grad()
    self._storer:grad()
    self._toStimulate = self.grad
    return self
  end
  
  function MultiStorer:inform()
    self._storer:inform()
    self._toStimulateEnd = self.inform
    return self
  end

  local function getRange(
    self, nerve, funcName, lower, upper
  )
    lower = lower or 1
    upper = upper or #fromData
    
    assert(
      lower <= upper,
      'Must not set the lower bound to be greater '..
      'than the upper bound on the range.'
    )

    local result = {}
    for i=lower, i < upper do
      local curStorer = self._storers[i]
      
      table.insert(
        result, curStorer[funcName](
          curStorer
        )
      )
    end
    return result
  end
  
  function MultiStorer:getNerveOutputs(lower, upper)
    return getRange(
      self, nerve, 'getOutputs', lower, upper
    )[nerve]
  end
  
  function MultiStorer:getNerveInputs(
    nerve, lower, upper
  )
    return getRange(
      self, nerve, 'getInputs', lower, upper
    )[nerve]
  end
  
  function MultiStorer:getNerveGradInputs(
    nerve, lower, upper
  )
    return getRange(
      self, nerve, 'getGradInputs', lower, upper
    )[nerve]
  end

  function MultiStorer:getNerveGradOutputs(
    nerve, lower, upper
  )
    return getRange(
      self, nerve, 'getGradOutputs', lower, upper
    )[nerve]
  end

  function MultiStorer:setNerveOut(nerve, output)
    self._storer:setNerveOut(nerve, output)
  end
  
  function MultiStorer:setNerveInput(nerve, input_)
    self._storer:setNerveInput(nerve, input_)
  end
  
  function MultiStorer:setNerveGradInput(nerve, gradInput)
    self._storer:setNerveGradInput(nerve, gradInput)
  end

  function MultiStorer:setNerveGradOut(nerve, gradOutput)
    self._storer:setNerveGradOut(nerve, gradOutput)
  end

  function MultiStorer:probe()
    self._storer:probe()
    self._toStimulateEnd = self.probe
    return self
  end
  
  function MultiStorer:index(value)
    --! Alter the currect index of 
    --! the multi emission storer
    --! @param value - The new index - number
    --! @post  The present outputs and gradInputs 
    --! are set to the index specified by the argument.
    self._index = value
    if not self._storers[value] then
      self._storers[value] = self._baseStorer(
        table.unpack(self._storerArgs)
      )
    end
    self._storer = self._storers[value]
    
    self:_toStimulate()
    self:_toStimulateEnd()
    self._storer:resetVisited()
    
    self._gradInputs = self._storer:getGradInputs()
    self._inputs = self._storer:getInputs()
    self._outputs = self._storer:getOutputs()
    self._gradOutputs = self._storer:getGradOutputs()
  end  
end
