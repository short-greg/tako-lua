require 'oc.machine.pkg'
require 'oc.class'


do
  local State = oc.class(
    'oc.machine.State'
  )
  --!	State
  --!
  oc.machine.State = State

  function State:__init(initialState, states)
    self._initialState = initialState
    self._curState = initialState
    self._states = states
  end

  function State:setInitialState(initialState)
    self.initialState = initialState
  end

  function State:signal(signalType)
    return
  end

  function State:relax()
    self.curState = initialState
  end
end
