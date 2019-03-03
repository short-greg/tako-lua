require 'oc.init'
require 'ocnn.data.index'


do
  --- for storing tables of Tensors
  local DataTable, parent = oc.class(
    'ocnn.data.Table'
  )
  ocnn.data.Table = DataTable
  
  function DataTable:__init(data)
    self.data = data
    
    local length
    for k, v in pairs(data) do
      if length == nil then
        length = v:size(1)
      else
        assert(
          length == v:size(1),
          string.format(
            'The length of %s must be the same size '..
            'as other elements of the table.', k
          )
        )
      end
    end
    self._length = length
  end
  
  function DataTable:index(index)
    local subData = {}
    if type(index) == 'number' then
      index = oc.data.index.Index(index)
    end

    for k, column in self:iter() do
      subData[k] = index:indexOnTensor(column)
    end
    return DataTable(subData)
  end
  
  function DataTable:iter()
    return pairs(self.data)
  end
  
  function DataTable:__len__()
    return self._length
  end
  
  function DataTable:__index__(index)
    return self.data[index]
    --[[
    if oc.type(index) == 'ocnn.data.index.Base' then
      return self:index(index)
    end
    --]]
  end
  
  function DataTable:apply(func, columns)
    for i=1, #columns do
      self.data[columns[i]] = func(
        self.data[columns[i]]
      )
    end
  end
end


do
  local ToTable, parent = oc.class(
    'ocnn.data.ToTable', oc.Nerve
  )
  ocnn.data.ToTable = ToTable
  
  function ToTable:out(input)
    return input.data
  end
  
  function ToTable:grad(input, gradOutput)
    return ocnn.data.Table(gradOutput)
  end
end


do
  local Dataset, parent = oc.class(
    'ocnn.data.Set'
  )
  ocnn.data.Set = Dataset
  
  function Dataset:__init(tables)
    self._tables = tables or {}
  end
  
  function Dataset:apply(func, columns)
    for k, dataTable in pairs(self._tables) do
      dataTable:apply(func, columns)
    end
  end
end
