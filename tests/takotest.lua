
require 'oc.tako'

do
  require 'oc.tako'
  require 'oc.oc'
  require 'ocnn.module'
  local Y = oc.tako('Y')
  local V = oc.tako('V', Y)
  local chain = nn.Linear(2, 2)
  local input_ = torch.randn(2, 2)
  print('Stimulating')
  local target = chain:stimulate(input_)
  Y.arm.t = chain
  
  local z = V()
  assert(
    z.t:updateOutput(input_) == target,
    'The output of z.t should be equal to the target.'
  )
  assert(
    oc.type(z.t) == 'oc.Arm',
    'Member t of z should be of type arm.'
  )
end


do
  -- Assert that it calls the child
  require 'oc.tako'
  require 'oc.oc'
  local Y = oc.tako('Y')
  local V = oc.tako('V', Y)
  local chain1 = nn.Linear(2, 2)
  local chain2 = nn.Linear(2, 2)
  local input_ = torch.randn(2, 2)
  local nonTarget = chain1:stimulate(input_)
  local target = chain2:stimulate(input_)
  Y.arm.t = chain1
  V.arm.t = chain2
  
  local z = V()
  assert(
    z.t:updateOutput(input_) == target,
    'The output of z.t should be equal to the target.'
  )
  assert(
    z.t.output ~= nonTarget,
    'The output of z.t should not be equal to the target.'
  )
  assert(
    oc.type(z.t) == 'oc.Arm',
    'Member t of z should be of type arm.'
  )
end


do
  -- Calls the instance member
  require 'oc.tako'
  require 'oc.oc'
  local Y = oc.tako('Y')
  local V = oc.tako('V', Y)
  local chain1 = nn.Linear(2, 2)
  local chain2 = nn.Linear(2, 2)
  local input_ = torch.randn(2, 2)
  local nonTarget = chain1:stimulate(input_)
  local target = chain2:stimulate(input_)
  Y.arm.t = chain1
  local z = V()
  z.arm.t = chain2
  
  assert(
    z.t:updateOutput(input_) == target,
    'The output of z.t should be equal to the target.'
  )
  assert(
    z.t.output ~= nonTarget,
    'The output of z.t should not be equal to the target.'
  )
  assert(
    oc.type(z.t) == 'oc.Arm',
    'Member t of z should be of type arm.'
  )
end


do
  local T = oc.tako('T')
  function T:__init(size)
    self._size = size
  end
  
  function T:size()
    return self._size
  end
  local x = T(2)
  
  assert(x:size() == 2, 'X should be of size 2')
end


do
  require 'oc.tako'
  local T = oc.tako('T')
  function T:__init(size)
    self._size = size
  end
  
  function T:size()
    return self._size
  end
  
  local T2 = oc.tako('T2', T)
  
  local x = T2(2)
  
  assert(x:size() == 2, 'X should be of size 2')
end


do
  require 'oc.tako'
  local T = oc.tako('T')
  function T:__init(size)
    self._size = size
  end
  
  T.size = 2
  
  local T2 = oc.tako('T2', T)
  
  local x = T2(2)
  
  assert(x.size == 2, 'X should be of size 2')
end


do
  require 'oc.tako'
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
  
  assert(x.val == 2, 'X should be of size 2')
end


do
  require 'oc.tako'
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
  assert(values.size == 2, 'Size of values should be 2')
end


do
  require 'oc.tako'
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
  assert(x(1) == 2, 'Size of values should be 2')
end


do
  require 'oc.tako'
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  local T2, parent = oc.tako('T2', T)
  
  local x = T2(2)
  assert(
    tostring(x) == str2..str1, 
    'The output of tostring is not correct'
  )
end

do
  require 'oc.tako'
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  T.name = 'T'
  
  local T2, parent = oc.tako('T2', T)
  T2.name = 'T2'
  
  local x = T2(2)
  assert(
    x.name == T2.name,
    'The name of x should be the same as T2.'
  )
end


do
  require 'oc.init'
  require 'oc.tako'
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  T.arm.linear = nn.Linear(2, 2) .. nn.Linear(2, 4)
  
  local T2, parent = oc.tako('T2', T)
  --T2.arm.linear = nn.Linear(2, 2) .. nn.Linear(2, 2)
  
  local x = T2(2)
  local result = x.linear:stimulate(torch.rand(2))
  assert(
    x.linear.output ~= nil and 
    x.linear.output:size(1) == 4 and
    oc.type(x.linear) == 'oc.Arm',
    'The output of x should be of size 4.'
  )
end


do
  require 'oc.init'
  require 'oc.tako'
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
  assert(
    x.linear.output == result and 
    oc.type(x.linear) == 'oc.SuperArm',
    'The output of x should be of size 4.'
  )
end


do
  require 'oc.init'
  require 'oc.tako'
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  T.arm.linear = nn.Linear(2, 2) .. nn.Linear(2, 4)
  T.arm.x = oc.my.arm.linear
  
  local x = T(2)
  local result = x.linear:stimulate(torch.rand(2))
  assert(
    x.linear.output == result and 
    oc.type(x.x) == 'oc.MyArm',
    'The output of x should be of size 4.'
  )
end


do
  require 'oc.init'
  require 'oc.tako'
  -- test_index
  local T = oc.tako('T')
  local values = {}
  function T:__init()
  end
  T.arm.linear = nn.Linear(2, 2) .. nn.Linear(2, 4)
  T.arm.x = oc.my.arm.linear
  
  local T2, parent = oc.tako('T2', T)
  T2.arm.x = oc.my.arm.linear
  
  local x = T2(2)
  local result = x.linear:stimulate(torch.rand(2))
  assert(
    x.linear.output == result and 
    oc.type(x.x) == 'oc.MyArm',
    'The output of x should be of size 4.'
  )
end


do
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
  
  assert(
    x.linear.output == resultB,
    'The output of linear should be the same as resultB'
  )
  assert( 
    resultA ~= resultB,
    'ResultA should not be the same as resultB.'
  )
end
  --
