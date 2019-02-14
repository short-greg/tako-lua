
do
  require 'ocnn.data.set'
  require 'ocnn.data.index'
  
  local y = torch.rand(3, 2)
  local z = torch.rand(3, 2)
  local ind_ = torch.LongTensor{2, 1}
  
  local dataTable = ocnn.data.Table(
    {
      y=y,
      z=z
    }
  )
  
  local index = ocnn.data.index.Indices(
    ind_
  )
  
  local result = dataTable:index(index)
  
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
  
  local y = torch.rand(3, 2)
  local z = torch.rand(3, 2)
  local ind_ = torch.LongTensor{2, 1}
  
  local dataTable = ocnn.data.Table(
    {
      y=y,
      z=z
    }
  )
  local result = {}
  for k, column in dataTable:iter() do
    result[k] = column
  end
  
  assert(
    result['y'] == y,
    '' 
    
  )
  assert(
    result['z'] == z,
    '' 
    
  )
end
