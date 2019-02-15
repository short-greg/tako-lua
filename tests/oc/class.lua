

do
  require 'oc.class'
  local T = oc.class('T')
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
  require 'oc.class'
  local T = oc.class('T')
  function T:__init(size)
    self._size = size
  end
  
  function T:size()
    return self._size
  end
  
  local T2 = oc.class('T2', T)
  
  local x = T2(2)
  
  assert(x:size() == 2, 'X should be of size 2')
end

do
  require 'oc.class'
  local T = oc.class('T')
  function T:__init(size)
    self._size = size
  end
  
  T.size = 2
  
  local T2 = oc.class('T2', T)
  
  local x = T2(2)
  
  assert(x.size == 2, 'X should be of size 2')
end


do
  -- test_index
  local T = oc.class('T')
  function T:__init(size)
    self._size = size
  end
  
  T.__index__ = function (self, index)
    return self._size
  end
  
  local T2 = oc.class('T2', T)
  
  local x = T2(2)
  
  assert(x.val == 2, 'X should be of size 2')
end


do
  -- test_index
  local T = oc.class('T')
  local values = {}
  function T:__init(size)
  end
  
  T.__newindex__ = function (self, index, val)
    values[index] = val
  end
  
  local T2 = oc.class('T2', T)
  
  local x = T2(2)
  x.size = 2
  assert(values.size == 2, 'Size of values should be 2')
end


do
  -- test_index
  local T = oc.class('T')
  local values = {}
  function T:__init(size)
  end
  
  T.__call__ = function (self, val)
    return val * 2
  end
  
  local T2 = oc.class('T2', T)
  
  local x = T2(2)
  assert(x(1) == 2, 'Size of values should be 2')
end


do
  require 'oc.class'
  -- test_index
  local T = oc.class('T')
  local values = {}
  function T:__init()
  end
  local str1 = 'T class'
  local str2 = 'T class 2'
  T.__tostring__ = function (self)
    return str1
  end
  
  local T2, parent = oc.class('T2', T)
  T2.__tostring__ = function (self)
    return str2..parent.__tostring__(self)
  end
  
  local x = T2(2)
  assert(
    tostring(x) == str2..str1, 
    'The output of tostring is not correct'
  )
end


do
  require 'oc.class'
  -- test_index
  local T = oc.class('T')
  local values = {}
  function T:__init()
    self:x()
  end
  
  function T:x()
    self._t = 2
  end
  
  local str1 = 'T class'
  local str2 = 'T class 2'
  T.__tostring__ = function (self)
    return str1
  end
  
  
  
  local T2, parent = oc.class('T2', T)
  T2.__tostring__ = function (self)
    return str2..parent.__tostring__(self)
  end
  
  local x = T2(2)
  assert(
    tostring(x) == str2..str1, 
    'The output of tostring is not correct'
  )
end
