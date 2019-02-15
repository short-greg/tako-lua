
do
  -- Test null storage
  require 'oc.data.storage'
  
  local storage = oc.data.NullStorage()
  
  assert(
    #storage == 0,
    'Length of null storage should be 0.'
  )
end


do
  -- Test null storage
  require 'oc.data.storage'
  
  local storage = oc.data.NullStorage()
  
  storage:setData(1, 2)
  
  assert(
    #storage == 0,
    'Length of null storage should always be 0.'
  )
end


do
  -- Test null storage
  require 'oc.data.storage'
  
  local storage = oc.data.NullStorage()
  
  storage:setData(1, 2)
  
  assert(
    storage:data() == nil,
    'Storage data should be nil.'
  )
end


do
  -- Test table storage data storage
  require 'oc.data.storage'
  
  local storage = oc.data.TableStorage()
  
  storage:setData(1, 2)
  
  print(storage:data())
  assert(
    storage:data()[1] == 2 and #storage:data() == 1,
    'Storage data should only have one value and it should be 2.'
  )
end

do
  -- Test table storage data storage
  require 'oc.data.storage'
  
  local storage = oc.data.TableStorage()
  
  storage:setData(1, 2)
  assert(
    #storage == 1,
    'Storage data should only have one value.'
  )
end

do
  -- Test table storage data storage
  require 'oc.data.storage'
  
  local storage = oc.data.TableStorage()
  
  assert(
    #storage == 0,
    'Storage data should only have no data in it.'
  )
end


do
  -- Test table storage data storage
  require 'oc.data.storage'
  
  local storage = oc.data.TableStorage()
  
  storage:setData(1, 2)
  storage:setData(3, 3)
  assert(
    #storage == 3,
    'Storage data should have length three.'
  )
end


do
  -- Test table storage data storage
  require 'oc.data.storage'
  
  local storage = oc.data.TableStorage()
  
  storage:setData(1, 2)
  storage:empty()
  assert(
    #storage == 0,
    'Storage data should be empty.'
  )
end
