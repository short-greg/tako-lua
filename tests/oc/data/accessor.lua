do
  require 'ocnn.data.set'
  require 'ocnn.data.index'
  require 'oc.data.accessor'
  require 'ocnn.data.accessor'
  
  local y = torch.rand(3, 2)
  local z = torch.rand(3, 2)
  local ind_ = torch.LongTensor{2, 1}
  
  local dataTable = ocnn.data.Table(
    {y=y, z=z}
  )
  
  local index = ocnn.data.index.Indices(
    ind_
  )
  local accessor = ocnn.data.accessor.Set(dataTable)
  local result = accessor:get(index)
  assert(
    y:index(1, ind_):eq(result.data['y']),
    '' 
    
  )
  assert(
    z:index(1, ind_):eq(result.data['z']),
    '' 
    
  )
end


do
  require 'ocnn.data.set'
  require 'ocnn.data.index'
  require 'ocnn.data.accessor'
  
  local y = torch.rand(3, 2)
  local z = torch.rand(3, 2)
  
  local dataTable = ocnn.data.Table(
    {y=y, z=z}
  )
  local accessor = ocnn.data.accessor.Set(dataTable)
  print(#accessor)
  assert(
    #accessor == 3,
    '' 
  )
end


do
  require 'ocnn.data.set'
  require 'ocnn.data.index'
  require 'ocnn.data.accessor'
  
  local y = torch.rand(3, 2)
  local z = torch.rand(3, 2)
  
  local dataTable = ocnn.data.Table(
    {y=y, z=z}
  )
  local accessor = ocnn.data.accessor.Reverse(
    ocnn.data.accessor.Set(dataTable)
  )
  print(#accessor)
  assert(
    #accessor == 3,
    '' 
  )
end


do
  require 'ocnn.data.set'
  require 'ocnn.data.index'
  require 'ocnn.data.accessor'
  
  local y = torch.rand(3, 2)
  
  local dataTable = ocnn.data.Table(
    {y=y}
  )
  local accessor = ocnn.data.accessor.Batch(
    2, ocnn.data.accessor.Set(dataTable)
  )
  
  local index = oc.data.index.Index(1)
  local index2 = ocnn.data.index.Indices(
    torch.LongTensor{1, 2}
  )
  local target = dataTable:index(index2).data['y']
  local result = accessor:get(index).data['y']
  
  assert(
    target:eq(result),
    ''
  )
end


do
  require 'ocnn.data.set'
  require 'ocnn.data.index'
  require 'ocnn.data.accessor'
  
  local y = torch.rand(5, 2)
  
  local dataTable = ocnn.data.Table(
    {y=y}
  )
  local accessor = ocnn.data.accessor.Batch(
    2, ocnn.data.accessor.Set(dataTable)
  )
  assert(
    #accessor == 2,
    ''
  )
end


do
  require 'ocnn.data.set'
  require 'ocnn.data.index'
  require 'ocnn.data.accessor'
  
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
  
  assert(
    result.data['z'] == nil,
    '' 
  )
  assert(
    result.data['y']:eq(y),
    '' 
  )
end


do
  require 'ocnn.data.set'
  require 'ocnn.data.index'
  require 'ocnn.data.accessor'
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
  assert(
    result.data['y'] == nil,
    '' 
  )
  assert(
    result.data['t']:eq(y),
    '' 
  )
end


do
  require 'ocnn.data.set'
  require 'ocnn.data.index'
  require 'ocnn.data.accessor'
  
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
  assert(
    result.data['y']:eq(target),
    ''
  )
  
  torch.randperm = randperm
end
