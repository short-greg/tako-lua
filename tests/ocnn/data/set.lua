require 'ocnn.data.set'
require 'ocnn.data.index'


function octest.data_table_indexed_with_indices()
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
  
  octester:eq(
    y:index(1, ind_), (result.data['y']),
    '' 
    
  )
  octester:eq(
    z:index(1, ind_), (result.data['z']),
    '' 
    
  )
end


function octest.data_table_iter()
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
  
  octester:eq(
    result['y'], y,
    '' 
    
  )
  octester:eq(
    result['z'], z,
    '' 
  )
end
