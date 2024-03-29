require 'oc.machine.pkg'
require 'oc.class'


do
  ---	Finite State Machine
  -- A standard finite state machine class 
  -- in which state transitions occur
  -- due to signals.  Each state can also 
  -- emit an action.
  local FSM = oc.class(
    'oc.machine.FSM'
  )
  oc.machine.FSM = FSM

  --- 
  -- @param initialState - 
  -- @param stateMap - 
  -- @param actionMap -
  function FSM:__init(
    initialState, stateMap, actionMap
  )
    self._stateMap = {}
    self._actionMap = actionMap or {}
    
    for i=1, #stateMap do
      self:connectStates(table.unpack(stateMap[i]))
    end
    self._curState = initialState
    self._initialState = initialState
  end

  ---	Assert that the state passed is valid
  -- @param state - a state to test if 
  -- in the state machine (hopefully)
  function FSM:_assertState(state)

    assert(
      self._stateMap[state],
      string.format(
        'State %s is an invalid state', state
      )
    )
  end

  --- Send a signal to the state machine
  -- @return {function}
  function FSM:signal(signal)
    if self._stateMap[self._curState][signal] then
      self._curState = 
        self._stateMap[self._curState][signal]
      return self._actionMap[self._curState]
    end
    
    -- TODO: THROW ERROR??
    -- How to deal with invalid signals
  end

  --- Add a mapping between states
  -- @param mapping  {{fromStates}, toState, signal}
  function FSM:connectStates(
    fromStates, toState, signal
  )
    for i=1, #fromStates do      
      local curState = fromStates[i]
      self._stateMap[curState] = 
        self._stateMap[curState] or {}
      self._stateMap[curState][signal] = toState
    end
  end

  function FSM:removeState(state)
    self._stateMap[state] = nil
    self._actionMap[state] = nil
    -- remove all transitions
    for k, action in pairs(self._stateMap) do
      for l, toState in pairs(action) do
        if toState == state then
          self._stateMap[k][l] = nil
        end
      end
    end
  end

  --- Disconnect states from one another
  -- @param fromStates - States of the tail 
  -- of the edge to disconnect - [state]
  -- @param toState - state at the head of the 
  -- edge to disconnect - state
  function FSM:disconnectState(fromState, toState)
    self:_assertState(toState)
    self:_assertState(fromState)
    for signal, state in pairs(self._stateMap[fromState]) do
      if state == toState then
        self._stateMap[fromState][signal] = nil
      end
    end
  end

  function FSM:getCurState()
    return self._curState
  end
end
