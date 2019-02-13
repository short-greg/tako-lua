require 'oc.pkg'
require 'oc.nerve'


do
  local Tube = oc.class(
    'oc.Tube', oc.Nerve
  )
  
  function Tube:__init(bot, onOut, onGrad, onAcc)
    self._onOut = onOut or true
    self._onGrad = onGrad or false
    self._onAcc = onAcc or false
    self._bot = bot
    
    assert(
      oc.isTypeOf(self._bot, 'oc.bot.Nano'),
      'Argument bot must be of type bot.Nano'
    )
    assert(
      type(self._onOut) == 'boolean', 
      'Argument onOut should be a boolean or nil'
      
    )
    assert(
      type(self._onAcc) == 'boolean', 
      'Argument onAcc should be a boolean or nil'
    )
    assert(
      type(self._onGrad) == 'boolean', 
      'Argument onGrad should be a boolean or nil'
    )
  end
  
  function Tube:tube()
    error(
      'Function tube() is not defined for abstract '..
      'class Tube.'
    )
  end
end


do
  local ForwardTube = oc.class(
    'oc.ForwardTube', oc.Tube
  )
  
  function ForwardTube:tube()
    self._bot:forward(self)
  end
end


do
  local BackwardTube = oc.class(
    'oc.BackwardTube', oc.Tube
  )
  
  function BackwardTube:tube()
    self._bot:backward(self)
  end
end
