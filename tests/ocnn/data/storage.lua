require 'oc.data.storage'
require 'ocnn.data.storage'
require 'ocnn.data.index'
  

function octest.data_null_storage()
  -- Test null storage
  local storage = oc.data.NullStorage()
  
  octester:assert(
    #storage == 0,
    'Length of null storage should be 0.'
  )
end


function octest.data_null_storage_with_trying_to_set()
  -- Test null storage
  local storage = oc.data.NullStorage()
  
  storage:setData(oc.data.index.Index(1), 2)
  
  octester:assert(
    #storage == 0,
    'Length of null storage should always be 0.'
  )
  octester:assert(
    storage:data() == nil,
    'Storage data should be nil.'
  )
end


function octest.data_table_storage_set()
  -- Test table storage data storage
  local storage = oc.data.TableStorage()
  
  storage:setData(oc.data.index.Index(1), 2)
  octester:assert(
    storage:data()[1] == 2 and 
    #storage == 1,
    'Storage data should only have one value and it should be 2.'
  )

  octester:assert(
    #storage == 1,
    'Storage data should only have one value.'
  )
end


function octest.data_storage_without_set()
  -- Test table storage data storage
  local storage = oc.data.TableStorage()
  
  octester:assert(
    #storage == 0,
    'Storage data should only have no data in it.'
  )
end


function octest.data_storage_with_setting_two_values()
  -- Test table storage data storage
  local storage = oc.data.TableStorage()
  
  storage:setData(oc.data.index.Index(1), 2)
  storage:setData(oc.data.index.Index(3), 3)
  octester:assert(
    #storage == 3,
    'Storage data should have length three.'
  )
end


function octest.data_storage_empty()
  -- Test table storage data storage
  local storage = oc.data.TableStorage()
  
  storage:setData(oc.data.index.Index(1), 2)
  storage:empty()
  octester:assert(
    #storage == 0,
    'Storage data should be empty.'
  )
end


function octest.data_storage_set_with_data_index()
  -- Test table storage data storage
  local storage = ocnn.data.TensorStorage(torch.randn(4, 4))
  
  local target = torch.randn(1, 4)
  storage:setData(oc.data.index.Index(2), target)
  octester:eq(
    storage:data():narrow(1, 2, 1), target,
    'Data does not equal target value.'
  )
end


function octest.data_tensor_storage_with_set()
  -- Test tensor storage data storage
  local storage = ocnn.data.TensorStorage(torch.randn(4, 4))
  local target = torch.randn(1, 4)
  octester:assert(
    #storage == 4,
    'Length of storage should be 4.'
  )
end
