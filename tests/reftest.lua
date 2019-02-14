require 'oc.ref'
require 'oc.placeholder'

do
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  local t = {m=2}
  local y = oc.nerve(oc.my)
  y:setOwner(t)
  
  assert(
    y:updateOutput() == t,
    'The output of y should be the owner t'
  )
end


do
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  t = {m=2}
  y = oc.nerve(oc.my.m)
  y:setOwner(t)
  
  assert(
    y:updateOutput() == t.m,
    'The output of y should be the owner t'
  )
end


do
  -- test oc.input
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  local t = {m=2}
  local y = oc.nerve(oc.my.m) .. oc.nerve(oc.input)
  y[1]:setOwner(t)
  y = oc.nerve(y)
  
  assert(
    y:updateOutput() == t.m,
    'The output of y should be the owner t'
  )
end


do
  -- test oc.input
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  local t = {m=2}
  local y = oc.nerve(oc.my) .. oc.nerve(oc.input.m)
  y[1]:setOwner(t)
  y = oc.nerve(y)
  assert(
    y:updateOutput() == t.m,
    'The output of y should be the owner t'
  )
end


do
  -- test oc.input
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  local t = {m=function (input_) return input_ * 2 end}
  local y = oc.nerve(oc.my.m(oc.input))
  y:setOwner(t)
  assert(
    y:updateOutput(2) == 4,
    'The output of y should be the owner t'
  )
end

do
  -- test oc.input
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  local t = {m=function (input_) return input_ * 2 end}
  local y = oc.nerve(oc.super.m(oc.input))
  y:setSuper(t)
  assert(
    y:updateOutput(2) == 4,
    'The output of y should be the owner t'
  )
end


do
  -- test oc.input
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  local val1, val2 = 3, 4
  local t = {
    m=function (val1, val2) return val1 * val2 end
  }
  local y = oc.nerve(oc.my.m(oc.input, val2))
  y:setOwner(t)
  assert(
    y:updateOutput(val1) == val1 * val2,
    'The output of y should be the owner t'
  )
end


do
  -- test two function calls
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  local val1 = 3
  local t = {
    m=function () return {
      f=function(val) return val * 2 end
    } end
  }
  local y = oc.nerve(oc.my.m().f(oc.input))
  y:setOwner(t)
  assert(
    y:updateOutput(val1) == val1 * 2,
    'The output of y should be the owner t'
  )
end


do
  -- test retrieve vlaue after function call
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  local val = 3
  local t = {
    m=function () return {
      f=3
    } end
  }
  local y = oc.nerve(oc.my.m().f)
  y:setOwner(t)
  assert(
    y:updateOutput() == 3,
    'The output of y should be the owner t'
  )
end


do
  -- test retrieve vlaue after function call
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  local val = 3
  local t = {
    t=2,
    m=function (self) return self.t end
  }
  local y = oc.nerve(oc.my:m())
  y:setOwner(t)
  assert(
    y:updateOutput() == t.t,
    'The output of y should be the owner t'
  )
end

