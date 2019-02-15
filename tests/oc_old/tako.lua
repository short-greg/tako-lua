require 'oc.tako'
require 'oc.machine.fsm'
require 'oc.ops.table'
require 'oc.my'

function octest.oc_tako_init()
  tk = oc.tako.Tak{}
end

testTakoOG = {}

function octest.oc_tako_type()
  local tako = oc.tako.TakX2{__namespace='testTakoOG'}

  local instance = testTakoOG.TakX2()
  octester:asserteq(
    torch.isTypeOf(instance, 'oc.Tako'), true,
    'Type of Tak should be oc.Tako'
  )
end


function octest.oc_tako_type_invalid_parent()
  if pcall(oc.tako.Tak2.extends(oc.Object), {__namespace='testTakoOG'}) then
    error('Should be an invalid parent')
  
  end
end

function octest.oc_tako_type_with_arm()
  local tako = oc.tako.Tak3{
  	__namespace='testTakoOG',
  	__arms={
  	  encode=nn.Linear(2, 2) .. nn.Linear(2, 2)
  	}
  }

  local instance = testTakoOG.Tak3()
  
  octester:eq(
    torch.type(instance.encode), 'oc.Arm',
    'The member should be an arm'
  )

end

function octest.oc_tako_type_with_my()
  local tako = oc.tako.TakXX{
  	__namespace='testTakoOG',
  	__arms={
  	  helper=nn.Linear(2, 2),
  	  encode=oc.my.helper .. nn.Linear(2, 2)
  	}
  }
  local instance  = testTakoOG.TakXX()
  octester:eq(
    torch.type(instance.encode:root()), 'oc.Arm',
    'The member should be an arm'
  )
end

function octest.oc_tako_inheritance()
  local tako = oc.tako.Tak4{
  	__namespace='testTakoOG',
  	__arms={
  	  encode=nn.Linear(2, 2) .. nn.Linear(2, 2)
  	}
  }
  
  local tako = oc.tako.Tak5.extends(testTakoOG.Tak4){
  	__namespace='testTakoOG',
  	__arms={
  	  encode=nn.Linear(2, 2) .. nn.Linear(2, 2)
  	}
  }

  local instance = testTakoOG.Tak5()
  
  octester:eq(
    torch.isTypeOf(instance, 'testTakoOG.Tak4'), true,
    'The Tako should be of type Tak4'
  )

end

function octest.oc_tako_head()
  -- Ensure the head can be set
  
  local head = oc.machine.FSM(
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
  
  local tako = oc.tako.TakHEAD{
  	__namespace='testTakoOG',
  	__head={
  	  head
  	},
  	__arms={
  	  encode=nn.Linear(2, 2) .. nn.Linear(2, 2)
  	}
  }
end

function octest.oc_tako_signal_invalid()
  -- Ensure the head can be set
  
  local head = oc.machine.FSM(
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
  
  local tako = oc.tako.Tak10{
  	__namespace='testTakoOG',
  	__head={
  	  head
  	},
  	__arms={
  	  encode=nn.Linear(2, 2) .. nn.Linear(2, 2)
  	}
  }
  
  if pcall(oc.ops.tako.signal, oc.tako.Tak10, 'open') then
    error('The singla call should be invalid.')
  end
end

function octest.oc_tako_signal()
  -- Ensure the head can be set
  
  local head = oc.machine.FSM(
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
  
  local Tak10 = oc.tako.Tak11{
  	__namespace='testTakoOG',
  	__head={
  	  head
  	},
  	__arms={
  	  encode=nn.Linear(2, 2) .. nn.Linear(2, 2)
  	}
  }
  local instance = testTakoOG.Tak11()
  
  local result = oc.ops.tako.signal(instance, 'play')
  octester:eq(
    oc.ops.table.contains(result, 'playing'), true,
    'The emission result should contain the state playing.'
  )
  
end

function octest.oc_tako_receptor_output()
  -- Ensure the head can be set
  
  local head = oc.machine.FSM(
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
  
  local Tak = oc.tako.Tak12{
  	__namespace='testTakoOG',
  	__head={
  	  head
  	},
  	__arms={
  	  encode=nn.Linear(2, 2) .. nn.Linear(2, 2)
  	}
  }
  local instance = testTakoOG.Tak12()
  local receptor = oc.ops.tako.receptor(instance)
  local result = receptor:updateOutput('play')
    octester:eq(
    oc.ops.table.contains(result, 'playing'), true,
    'The emission result should contain the state playing.'
  )
end
