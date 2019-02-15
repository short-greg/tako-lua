require 'oc.machine.factor'
require 'oc.machine.fsm'
require 'oc.ops.table'

function octest.machine_factorsm_construct()
  local machine1 = oc.machine.FSM(
    1,
    {
      {{2}, 3, 'pause'}, 
      {{1, 3}, 2, 'play'},
      {{2, 3}, 1, 'stop'}
    }
  )
  local machine2 = oc.machine.FSM(
    1,
    {
      {{1}, 2, 'open'}, 
      {{2}, 1, 'close'}
    }
  )
  oc.machine.Factor({machine1, machine2})
end

function octest.machine_factorsm_construct_with_actionMap()
  local machine1 = oc.machine.FSM(
    1,
    {
      {{2}, 3, 'pause'}, 
      {{1, 3}, 2, 'play'},
      {{2, 3}, 1, 'stop'}
    },
    {
      [1]=function () return 'stopped' end,
      [2]=function () return 'playing' end,
      [3]=function () return 'paused' end,
    }
  )
  local machine2 = oc.machine.FSM(
    1,
    {
      {{1}, 2, 'open'}, 
      {{2}, 1, 'close'}
    },
    {
      [1]=function () return 'opened' end,
      [2]=function () return 'closed' end
    }
  )
  oc.machine.Factor({machine1, machine2})
end

function octest.machine_factorsm_signal()
  local machine1 = oc.machine.FSM(
    1,
    {
      {{2}, 3, 'pause'}, 
      {{1, 3}, 2, 'play'},
      {{2, 3}, 1, 'stop'}
    },
    {
      [1]=function () return 'stopped' end,
      [2]=function () return 'playing' end,
      [3]=function () return 'paused' end,
    }
  )
  local machine2 = oc.machine.FSM(
    1,
    {
      {{1}, 2, 'open'}, 
      {{2}, 1, 'close'}
    },
    {
      [1]=function () return 'opened' end,
      [2]=function () return 'closed' end
    }
  )
  local machine = oc.machine.Factor({machine1, machine2})
  local result = machine:signal('play')()
  
  octester:eq(
    result[1], 'playing',
    'Result should equal playing'
  )
end

function octest.machine_factorsm_signal_inaction()
  local machine1 = oc.machine.FSM(
    1,
    {
      {{2}, 3, 'pause'}, 
      {{1, 3}, 2, 'play'},
      {{2, 3}, 1, 'stop'}
    },
    {
      [1]=function () return 'stopped' end,
      [2]=function () return 'playing' end,
      [3]=function () return 'paused' end,
    }
  )
  local machine2 = oc.machine.FSM(
    1,
    {
      {{1}, 2, 'open'}, 
      {{2}, 1, 'close'}
    },
    {
      [1]=function () return 'opened' end,
      [2]=function () return 'closed' end
    }
  )
  local machine = oc.machine.Factor({machine1, machine2})
  local result = machine:signal('stop')()
  octester:eq(
    result, nil,
    'Result should be nil'
  )
end

function octest.machine_factorsm_getCurrentState()
  local machine1 = oc.machine.FSM(
    1,
    {
      {{2}, 3, 'pause'}, 
      {{1, 3}, 2, 'play'},
      {{2, 3}, 1, 'stop'}
    },
    {
      [1]=function () return 'stopped' end,
      [2]=function () return 'playing' end,
      [3]=function () return 'paused' end,
    }
  )
  local machine2 = oc.machine.FSM(
    1,
    {
      {{1}, 2, 'open'}, 
      {{2}, 1, 'close'}
    },
    {
      [1]=function () return 'opened' end,
      [2]=function () return 'closed' end
    }
  )
  local machine = oc.machine.Factor({machine1, machine2})
  local result = machine:signal('play')()
  local result2 = machine:signal('open')()
  local curState = machine:getCurState()
  octester:eq(
    oc.ops.table.contains(curState, 2), true,
    'Should be opened'
  )
  octester:eq(
    oc.ops.table.contains(curState, 2), true,
    'Should be playing'
  )
end



function octest.machine_factorsm_removeStates()
  --[[
  local machine = oc.machine.FSM(
    1,
    {
      {{2}, 3, 'pause'}, 
      {{1, 3}, 2, 'play'},
      {{2, 3}, 1, 'stop'}
    },
    {
      [1]=function () return 'stopped' end,
      [2]=function () return 'playing' end,
      [3]=function () return 'paused' end,
    }
  )
  machine:signal('play')
  octester:eq(
    result, nil,
    'Result should be nil'
  )
  --]]
end


function octest.machine_factorsm_disconnectState()
  --[[
  local machine = oc.machine.FSM(
    1,
    {
      {{2}, 3, 'pause'}, 
      {{1, 3}, 2, 'play'},
      {{2, 3}, 1, 'stop'}
    },
    {
      [1]=function () return 'stopped' end,
      [2]=function () return 'playing' end,
      [3]=function () return 'paused' end,
    }
  )
  machine:disconnectState(1, 2)
  local result = machine:signal('play')
  octester:eq(
    result, nil,
    'Result should be nil'
  )--]]
end
