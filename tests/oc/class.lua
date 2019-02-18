require 'oc.class'


function octest.oc_class_no_base_class()
  local T = oc.class('T')
  function T:__init(size)
    self._size = size
  end
  
  function T:size()
    return self._size
  end
  local x = T(2)

  octester:asserteq(
    x:size(), 2, 'X should be of size 2'
  )
end


function octest.oc_class_with_base_class()
  local T = oc.class('T')
  function T:__init(size)
    self._size = size
  end
  
  function T:size()
    return self._size
  end
  
  local T2 = oc.class('T2', T)
  
  local x = T2(2)
  
  octester:asserteq(
    x:size(), 2, 'X should be of size 2'
  )
end


function octest.oc_class_member_variable()
  local T = oc.class('T')
  function T:__init(size)
    self._size = size
  end
  
  T.size = 2
  
  local T2 = oc.class('T2', T)
  
  local x = T2(2)
  
  octester:asserteq(
    x.size, 2, 'X should be of size 2'
  )
end

--[[

TODO:
1. if __index__ returns self._size rather
than rawget(self, '_size') it results in an
infinite loop
2. __newindex__ should check all of the base
classes prior to setting a new index?? I am not
sure. how I want this

Anyway, need more testing to check for infinite loops
and get a tighter system.

--]]

function octest.oc_class_member_variable_in_base()
  -- test_index
  local T = oc.class('T')
  function T:__init(size)
    self._size = size
  end
  
  T.__index__ = function (self, index)
    return rawget(self, '_size')
  end
  
  local T2 = oc.class('T2', T)
  
  local x = T2(2)
  
  octester:asserteq(
    x.val, 2, 'Index for base class should return size'
  )
end


function octest.oc_class_index_metamethod()
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
  octester:asserteq(
    values.size, 2, 'Size of values should be 2'
  )
end


function octest.oc_class_call_metamethod()
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
  octester:asserteq(
    x(1), 2, 'Size of values should be 2'
  )
end


function octest.oc_class_tostring_metamethod()
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
  octester:asserteq(
    tostring(x), str2..str1, 
    'The output of tostring is not correct'
  )
end


function octest.oc_class_tostring_metamethod_with_base_class()
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

  octester:asserteq(
    tostring(x), str2..str1, 
    'The output of tostring is not correct'
  )
end
