require 'oc.class'
require 'oc.nerve'


do
  --- Creates an interface to a Tako, which allows the
  -- tako to work like a module in which information is
  -- passed to the tako through updateOutput
  -- 
  -- signalling functionality is not fully developed
  -- for Takos
  --
  -- oc.my:getSignal() .. oc.Receptor(otherTako)
  local Receptor, parent = oc.class(
    'oc.Receptor', oc.Nerve
  )  
  oc.Receptor = Receptor
  
  --- @param tako - the Tako to signal
  function Receptor:__init(tako)
    parent.__init(self) 
    self._tako = tako
  end

  function Receptor:out(input)
    local output = oc.signal(self._tako, input)
    self.output = output
    return output
  end
  
  function Receptor:grad(input, gradOutput)
    return nil
  end
  
  function Receptor:accGradParameters(
      input, gradOutput
  )
    return nil
  end
  
  function Receptor:tako()
    return self._tako
  end
end
