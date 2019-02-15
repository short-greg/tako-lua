require 'oc.data.index'

do
  require 'oc.data.index'
  local index = oc.data.index.Index(1)
  local expanded = index:expand(2)
  assert(
    expanded._startingVal == 1,
    ''
  )
  assert(
    expanded._frameSize == 2,
    ''
  )
end


do
  require 'oc.data.index'
  local index = oc.data.index.Index(2)
  local expanded = index:expand(3)
  assert(
    expanded._frameSize == 3,
    ''
  )
  assert(
    expanded._startingVal == 4,
    ''
  )
end


do
  require 'oc.data.index'
  local index = oc.data.index.Index(3)
  index:incr()
  assert(
    index._index == 4,
    ''
  )
end


do
  require 'oc.data.index'
  local index = oc.data.index.Index(1)
  local rev = index:rev(4)
  
  assert(
    rev._index == 4,
    ''
  )
end

do
  require 'oc.data.index'
  local index = oc.data.index.Index(1)
  index:incr()
  assert(
    index[1] == 2,
    ''
  )
end

do
  require 'oc.data.index'
  local index = oc.data.index.Index(1)
  index:decr()
  assert(
    index[1] == 0,
    ''
  )
end
