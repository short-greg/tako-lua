require 'oc.data.storage'
require 'oc.data.table'


function octest.oc_null_storage_size()
  -- Test null storage
  local storage = oc.data.NullStorage()
  
  octester:assert(
    #storage == 0,
    'Length of null storage should be 0.'
  )
end


function octest.oc_null_storage_size_after_set()
  local storage = oc.data.NullStorage()
  
  storage:setData(oc.data.index.Index(1), 2)
  
  octester:assert(
    #storage == 0,
    'Length of null storage should always be 0.'
  )
end


function octest.oc_null_storage_data_after_set()
  -- Test null storage
  
  local storage = oc.data.NullStorage()
  
  storage:setData(oc.data.index.Index(1), 2)
  
  octester:assert(
    storage:data() == nil,
    'Storage data should be nil.'
  )
end


function octest.oc_table_storage_data_after_set()
  -- Test table storage data storage
  
  local storage = oc.data.TableStorage()
  
  storage:setData(oc.data.index.Index(1), 2)

  octester:assert(
    storage:data()[1] == 2 and #storage:data() == 1,
    'Storage data should only have one value and it should be 2.'
  )
end


function octest.oc_table_storage_size_after_set()
  -- Test table storage data storage
  
  local storage = oc.data.TableStorage()
  
  storage:setData(oc.data.index.Index(1), 2)
  octester:assert(
    #storage == 1,
    'Storage data should only have one value.'
  )
end


function octest.oc_table_storage_size_no_set()
  -- Test table storage data storage
  local storage = oc.data.TableStorage()

  octester:assert(
    #storage == 0,
    'Storage data should only have no data in it.'
  )
end


function octest.oc_table_storage_size_after_two_sets()
  -- Test table storage data storage
  local storage = oc.data.TableStorage()
  
  storage:setData(oc.data.index.Index(1), 2)
  storage:setData(oc.data.index.Index(3), 3)
  octester:assert(
    #storage == 3,
    'Storage data should have length three.'
  )
end


function octest.oc_table_storage_size_after_empty()
  -- Test table storage data storage
  local storage = oc.data.TableStorage()
  
  storage:setData(oc.data.index.Index(1), 2)
  storage:empty()
  octester:assert(
    #storage == 0,
    'Storage data should be empty.'
  )
end
