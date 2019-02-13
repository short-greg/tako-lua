require 'oc.machine.pkg'
require 'oc.machine.state'
require 'oc.class'


do
  local Factor = oc.class(
    'oc.machine.Factor'
  )
  --! 
  --!	Factor is a factorial state machine 
  --! (i.e. it allows for multiple state
  --! machines)
  --! 
  oc.machine.Factor = Factor

  Factor.DEFAULT_SM = 'default'

  function Factor:__init(machines)
    self._machines = machines or {}
  end

  local multiaction = function(actions)
    --! @param actions
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

  function Factor:signal(signal)
    --! Send a signal to the Factor
    --!	@param	signal - string
    --!	@return action - {function}
    local actions = {}
    for i=1, #self._machines do
      local curAction = self._machines[i]:signal(signal)
      if curAction ~= nil then
        table.insert(actions, curAction)
      end
    end
    return multiaction(actions)
  end

  function Factor:getCurState()
    --!	@return state - {}
    local curState = {}
    for i, machine in ipairs(self._machines) do
      curState[i] = machine:getCurState()
    end
    return curState
  end

  function Factor:retrieveMachine(label)
    --! @param label - the name of the machine
    return self._machines[label]
  end

  function Factor:factorize(label, machine)
    --!	Add a state machine to the Factor
    --!	@param label - name of the machine - string
    --! @param machine - the machine to add - oc.machine.Factor
    self._machines[label] = machine
  end
end
