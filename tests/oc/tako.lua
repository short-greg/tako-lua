require 'oc.tako'
require 'oc.oc'


function octest.tako_define()
  local Y = oc.tako('Y')
  local V = oc.tako('V', Y)
  local strand = nn.Linear(2, 2)
  local input_ = torch.randn(2, 2)
  local target = strand:stimulate(input_)
  Y.arm.t = strand
  
  local z = V()
  octester:eq(
    z.t:updateOutput(input_), target,
    'The output of z.t should be equal to the target.'
  )
  octester:eq(
    oc.type(z.t), 'oc.Arm',
    'Member t of z should be of type arm.'
  )
end


function octest.tako_define_with_child()
  -- Assert that it calls the child
  local Y = oc.tako('Y')
  local V = oc.tako('V', Y)
  local strand1 = nn.Linear(2, 2)
  local strand2 = nn.Linear(2, 2)
  local input_ = torch.randn(2, 2)
  local nonTarget = strand1:stimulate(input_)
  local target = strand2:stimulate(input_)
  Y.arm.t = strand1
  V.arm.t = strand2
  
  local z = V()
  octester:eq(
    z.t:updateOutput(input_), target,
    'The output of z.t should be equal to the target.'
  )
  octester:ne(
    z.t.output, nonTarget,
    'The output of z.t should not be equal to the target.'
  )
  octester:eq(
    oc.type(z.t), 'oc.Arm',
    'Member t of z should be of type arm.'
  )
end


function octest.tako_calls_instance_member()
  local Y = oc.tako('Y')
  local V = oc.tako('V', Y)
  local strand1 = nn.Linear(2, 2)
  local strand2 = nn.Linear(2, 2)
  local input_ = torch.randn(2, 2)
  local nonTarget = strand1:stimulate(input_)
  local target = strand2:stimulate(input_)
  Y.arm.t = strand1
  local z = V()
  z.arm.t = strand2
  
  octester:eq(
    z.t:updateOutput(input_), target,
    'The output of z.t should be equal to the target.'
  )
  octester:ne(
    z.t.output, nonTarget,
    'The output of z.t should not be equal to the target.'
  )
  octester:eq(
    oc.type(z.t), 'oc.Arm',
    'Member t of z should be of type arm.'
  )
end


function octest.tako_calls_function()
  local T = oc.tako('T')
  function T:__init(size)
    self._size = size
  end
  
  function T:size()
    return self._size
  end
  local x = T(2)
  
  octester:eq(x:size(), 2, 'X should be of size 2')
end


function octest.tako_calls_base_class_function()
  local T = oc.tako('T')
  function T:__init(size)
    self._size = size
  end
  
  function T:size()
    return self._size
  end
  
  local T2 = oc.tako('T2', T)
  
  local x = T2(2)
  
  octester:eq(x:size(), 2, 'X should be of size 2')
end


function octest.tako_retrieves_base_class_size()
  local T = oc.tako('T')
  function T:__init(size)
    self._size = size
  end
  
  T.size = 2
  
  local T2 = oc.tako('T2', T)
  
  local x = T2(2)
  
  octester:eq(x.size, 2, 'X should be of size 2')
end


function octest.tako_ensure_index_returns_the_correct_value()
  -- test_index
  local T = oc.tako('T')
  function T:__init(size)
    self._size = size
  end
  
  T.__index__ = function (self, index)
    return self._size
  end
  
  local T2 = oc.tako('T2', T)
  
  local x = T2(2)
  
  octester:eq(x.val, 2, 'X should be of size 2')
end



function octest.tako_sets_newindex()
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init(size)
  end
  
  T.__newindex__ = function (self, index, val)
    values[index] = val
  end
  
  local T2 = oc.tako('T2', T)
  
  local x = T2(2)
  x.size = 2
  octester:eq(values.size, 2, 'Size of values should be 2')
end


function octest.tako_call_function_overloaded()
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init(size)
  end
  
  T.__call__ = function (self, val)
    return val * 2
  end
  
  local T2 = oc.tako('T2', T)
  
  local x = T2(2)
  octester:eq(x(1), 2, 'Size of values should be 2')
end


function octest.tako_concatenate_strings()
  local str = 'x'
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  function T:__tostring__()
    return str
  end
  local T2, parent = oc.tako('T2', T)
  
  local x = T2(2)
  octester:eq(
    tostring(x), str, 
    'The output of tostring is not correct'
  )
end


function octest.tako_retrieves_the_index_from_the_subclass()
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  T.name = 'T'
  
  local T2, parent = oc.tako('T2', T)
  T2.name = 'T2'
  
  local x = T2(2)
  octester:eq(
    x.name, T2.name,
    'The name of x should be the same as T2.'
  )
end


function octest.tako_arm_linear()
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  T.arm.linear = nn.Linear(2, 2) .. nn.Linear(2, 4)
  
  local T2, parent = oc.tako('T2', T)
  
  local x = T2(2)
  local result = x.linear:stimulate(torch.rand(2))
  octester:eq(
    oc.type(x.linear), 'oc.Arm',
    'The member linear should be of type Arm'
  )
  octester:eq(
    x.linear.output:size(1), 4,
    'The output of x should be of size 4.'
  )
end


function octest.tako_test_arm_from_super()
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  T.arm.linear = nn.Linear(2, 2) .. nn.Linear(2, 4)
  
  local T2, parent = oc.tako('T2', T)
  T2.arm.linear = oc.super.arm.linear
  
  local x = T2(2)
  local result = x.linear:stimulate(torch.rand(2))
  octester:eq(
    x.linear.output, result
  )
  octester:eq(
    oc.type(x.linear), 'oc.NerveRef',
    'The output of x should be of size 4.'
  )
end


function octest.tako_test_my_arm()
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  T.arm.linear = nn.Linear(2, 2) .. nn.Linear(2, 4)
  T.arm.x = oc.r(oc.my.linear)
  
  local x = T(2)
  local result = x.linear:stimulate(torch.rand(2))
  octester:eq(
    x.linear.output, result,
    'The output of the linear should be the same as the' ..
    'stimulation result.'
  )
  octester(
    oc.type(x.x), 'oc.NerveRef',
    'Arm x should be of type NerveRef.'
  )
end


function octest.tako_test_my_arm_from_super()
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  T.arm.linear = nn.Linear(2, 2) .. nn.Linear(2, 4)
  T.arm.x = oc.r(oc.my.linear)
  
  local T2, parent = oc.tako('T2', T)
  T2.arm.x = oc.r(oc.my.linear)
  
  local x = T2(2)
  local result = x.linear:stimulate(torch.rand(2))
  octester:eq(
    x.linear.output, result, 
    'The output of x should be of size 4.'
  )
  octester:eq(
    oc.type(x.x), 'oc.NerveRef',
    'x should be of type nerve ref.'
  )
end


function octest.tako_test_that_the_results_vary_with_stimulate()
  require 'oc.init'
  require 'oc.tako'
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  T.arm.linear = nn.Linear:d(2, 2) .. nn.Linear:d(2, 4)
  local T2, parent = oc.tako('T2', T)
  local x = T2(2)
  local inp1 = torch.rand(2)
  local resultA = x.linear:stimulate(inp1):clone()
  local inp2 = torch.rand(2)
  local resultB = x.linear:stimulate(inp2)
  
  octester:eq(
    x.linear.output, resultB,
    'The output of linear should be the same as resultB'
  )
  octester:ne( 
    resultA, resultB,
    'ResultA should not be the same as resultB.'
  )
end
