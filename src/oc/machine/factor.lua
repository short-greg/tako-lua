require 'oc.machine.pkg'
require 'oc.machine.state'
require 'oc.class'


do
  ---	Factor is a factorial state machine 
  -- (i.e. it allows for multiple state
  -- machines)
  -- 
  local Factor = oc.class(
    'oc.machine.Factor'
  )
  oc.machine.Factor = Factor

  Factor.DEFAULT_SM = 'default'

  function Factor:__init(machines)
    self._machines = machines or {}
  end

  --- @param actions
  local multiaction = function(actions)
    local execute = function (...)
      local result
      for i=1, #actions do
        local curResult = actions[i](...)
        if curResult then
          result = result or {}
          result[i] = curResult
        end
      end
      return result
    end
    return execute
  end

  --- Send a signal to the Factor
  --	@param	signal - string
  --	@return action - {function}
  function Factor:signal(signal)
    local actions = {}
    for i=1, #self._machines do
      local curAction = self._machines[i]:signal(signal)
      if curAction ~= nil then
        table.insert(actions, curAction)
      end
    end
    return multiaction(actions)
  end

  ---	@return state - {}
  function Factor:getCurState()
    local curState = {}
    for i, machine in ipairs(self._machines) do
      curState[i] = machine:getCurState()
    end
    return curState
  end

  --- @param label - the name of the machine
  function Factor:retrieveMachine(label)
    return self._machines[label]
  end

  ---	Add a state machine to the Factor
  --	@param label - name of the machine - string
  -- @param machine - the machine to add - oc.machine.Factor
  function Factor:factorize(label, machine)
    self._machines[label] = machine
  end
end
