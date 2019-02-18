require 'ocnn.data.set'
require 'ocnn.data.index'
require 'oc.data.accessor'
require 'ocnn.data.accessor'

  
function octest.oc_data_accessor_table_get()
  local y = torch.rand(3, 2)
  local z = torch.rand(3, 2)
  local ind_ = torch.LongTensor{2, 1}
  
  local dataTable = ocnn.data.Table(
    {y=y, z=z}
  )
  
  local index = ocnn.data.index.Indices(
    ind_
  )
  local accessor = ocnn.data.accessor.Table(dataTable)
  local result = accessor:get(index)
  octester:assert(
    y:index(1, ind_):eq(result.data['y']),
    '' 
    
  )
  octester:assert(
    z:index(1, ind_):eq(result.data['z']),
    '' 
    
  )
end


function octest.oc_data_accessor_table_size()
  
  local y = torch.rand(3, 2)
  local z = torch.rand(3, 2)
  
  local dataTable = ocnn.data.Table(
    {y=y, z=z}
  )
  local accessor = oc.data.accessor.Table(dataTable)
  octester:assert(
    #accessor == 3,
    '' 
  )
end


function octest.oc_data_accessor_reverse_size()
  
  local y = torch.rand(3, 2)
  local z = torch.rand(3, 2)
  
  local dataTable = ocnn.data.Table(
    {y=y, z=z}
  )
  local accessor = ocnn.data.accessor.Reverse(
    ocnn.data.accessor.Table(dataTable)
  )
  octester:assert(
    #accessor == 3,
    '' 
  )
end


function octest.oc_data_accessor_batch_index()
  
  local y = torch.rand(3, 2)
  
  local dataTable = ocnn.data.Table(
    {y=y}
  )
  local accessor = ocnn.data.accessor.Batch(
    2, ocnn.data.accessor.Table(dataTable)
  )
  
  local index = oc.data.index.Index(1)
  local index2 = ocnn.data.index.Indices(
    torch.LongTensor{1, 2}
  )
  local target = dataTable:index(index2).data['y']
  local result = accessor:get(index).data['y']
  
  octester:assert(
    target:eq(result),
    ''
  )
end


function octest.oc_data_accessor_batch_size()
  local y = torch.rand(5, 2)
  
  local dataTable = ocnn.data.Table(
    {y=y}
  )
  local accessor = ocnn.data.accessor.Batch(
    2, ocnn.data.accessor.Table(dataTable)
  )
  octester:assert(
    #accessor == 2,
    ''
  )
end


function octest.oc_data_accessor_column_set()
  
  local y = torch.rand(3, 2)
  local z = torch.rand(3, 2)
  
  local dataTable = ocnn.data.Table(
    {y=y, z=z}
  )
  local accessor = ocnn.data.accessor.Column(
    {'y'}, ocnn.data.accessor.Set(dataTable)
  )
  local index = ocnn.data.index.Indices(
    torch.LongTensor{1, 2, 3}
  )
  local result = accessor:get(index)
  
  octester:assert(
    result.data['z'] == nil,
    '' 
  )
  octester:assert(
    result.data['y']:eq(y),
    '' 
  )
end


function octest.oc_data_accessor_relabel_get()
  local y = torch.rand(3, 2)
  local z = torch.rand(3, 2)
  local dataTable = ocnn.data.Table(
    {y=y, z=z}
  )
  local accessor = ocnn.data.accessor.Relabel(
    {y='t'}, ocnn.data.accessor.Set(dataTable)
  )
  local index = ocnn.data.index.Indices(
    torch.LongTensor{1, 2, 3}
  )
  local result = accessor:get(index)
  octester:assert(
    result.data['y'] == nil,
    '' 
  )
  octester:assert(
    result.data['t']:eq(y),
    '' 
  )
end


function octest.oc_data_accessor_random_get()
  
  local y = torch.rand(3, 2)
  local randTensor = torch.DoubleTensor{1, 3, 2}
  local dataTable = ocnn.data.Table(
    {y=y}
  )
  local accessor = ocnn.data.accessor.Random(
    ocnn.data.accessor.Set(dataTable)
  )
  local index = ocnn.data.index.Indices(
    torch.LongTensor{1, 2, 3}
  )
  local result = accessor:get(index)
  
  local randperm = torch.randperm
  torch.randperm = function (...)
    return randTensor
  end
  
  local target = y:index(
    1, randTensor:long()
  )
  octester:assert(
    result.data['y']:eq(target),
    ''
  )
  
  torch.randperm = randperm
end
