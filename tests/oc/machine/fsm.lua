require 'oc.machine.fsm'

function octest.machine_fsm_construct()
  oc.machine.FSM(
    1,
    {
      {{2}, 3, 'pause'}, 
      {{1, 3}, 2, 'play'},
      {{2, 3}, 1, 'stop'}
    }
  )
end

function octest.machine_fsm_construct_with_actionMap()
  oc.machine.FSM(
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
end

function octest.machine_fsm_signal()
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
  local result = machine:signal('play')()
  octester:eq(
    result, 'playing',
    'Result should equal playing'
  )
end

function octest.machine_fsm_signal_inaction()
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
  local result = machine:signal('stop')
  octester:eq(
    result, nil,
    'Result should be nil'
  )
end


function octest.machine_fsm_removeStates()
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
end


function octest.machine_fsm_disconnectState()
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
  )
end
