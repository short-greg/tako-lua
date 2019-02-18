require 'oc.class'
require 'oc.data.accessor'
require 'ocnn.data.pkg'

ocnn.data.accessor = ocnn.data.accessor or {}

--! ##########################################
--! @module ocnn.data.accessor
--! 
--! ocnn.Accessors define accessors that deal with datasets
--! used for training neural networks
--! ##########################################

do
  local TableAccessor, parent = oc.class(
    'ocnn.data.accessor.Table', 
    oc.data.accessor.Base
  )
  --! Accessor to access a dataset
  --! 
  --! Dataset accessor does not contain
  --! a storage at the moment since it merely
  --! connects to a dataset like MNIST and
  --! 
  ocnn.data.accessor.Table = TableAccessor

  function TableAccessor:__init(dataTable)
    self._dataTable = dataTable
  end

  function TableAccessor:get(indexWith)
    print(self._dataTable)
    return self._dataTable:index(indexWith)
  end
  
  function TableAccessor:put(indices, data)
    error(
      'Method put() has not been implemented in the '.. 
      'table accessor class.'
    )
  end

  function TableAccessor:__len__()
    return #self._dataTable
  end

  function TableAccessor:storage()
    --! there are 
    --! data structure to 
    --! store data on back propagation
    return oc.data.NullStorage()
  end
end


do
  local TensorAccessor, parent = oc.class(
    'ocnn.data.accessor.TensorAccessor', 
    oc.data.accessor.Base
  )
  --! Accesses a tensor for iteration
  --! 
  ocnn.data.accessor.Tensor = TensorAccessor

  function TensorAccessor:__init(tensor)
    self._tensor = tensor
  end

  function TensorAccessor:get(indexWith)
    return indexWith:indexOnTensor(self._tensor)
  end
  
  function TensorAccessor:__len__()
    return self._tensor:size(1)
  end

  function TensorAccessor:storage()
    --! there are data structure to 
    --! store data on back propagation
    return ocnn.data.storage.TensorStorage(self._tensor)
  end
end


do
  local ColumnAccessor, parent = oc.class(
    'ocnn.data.accessor.Column', 
    oc.data.accessor.Meta
  )
  ocnn.data.accessor.Column = ColumnAccessor

  function ColumnAccessor:__init(columns, accessor)
    parent.__init(self, accessor)
    self._columns = columns
  end

  function ColumnAccessor:get(indexWith)
    local baseDataTable = self._meta:get(
      indexWith
    )
    local data = {}
    for i=1, #self._columns do
      data[self._columns[i]] = baseDataTable.data[
        self._columns[i]
      ]
    end
    
    return ocnn.data.Table(
      data
    )
  end
end


do
  local RelabelAccessor, parent = oc.class(
    'ocnn.data.accessor.Relabel', 
    oc.data.accessor.Meta
  )
  ocnn.data.accessor.Relabel = RelabelAccessor

  function RelabelAccessor:__init(
      columnMap, accessor
  )
    parent.__init(self, accessor)
    self._columnMap = columnMap
  end

  function RelabelAccessor:get(indexWith)
    local newData = {}
    
    local baseDataTable = self._meta:get(indexWith)
    for k, v in baseDataTable:iter() do
      if self._columnMap[k] then
        local newColumn = self._columnMap[k]
        newData[newColumn] = v
      end
    end
    return ocnn.data.Table(newData)
  end
end


do
  local RandomAccessor, parent = oc.class(
    'ocnn.data.accessor.Random', 
    oc.data.accessor.Meta
  )
  ocnn.data.accessor.Random = RandomAccessor

  function RandomAccessor:__init(accessor)
    parent.__init(self, accessor)
    self._permutation = nil
  end
  
  function RandomAccessor:reset()
    self._permutation = nil
  end

  function RandomAccessor:get(indexWith)
    if self._permutation == nil then
      self._permutation = torch.randperm(
        #self._meta
      ):long()
    end
    -- need to map the indices
    local mapped = ocnn.data.index.Indices(
      indexWith:indexOnTensor(self._permutation)
    )
    
    return self._meta:get(mapped)
  end
end


do
  local ReverseAccessor, parent = oc.class(
    'ocnn.data.accessor.Reverse', 
    oc.data.accessor.Meta
  )
  ocnn.data.accessor.Reverse = ReverseAccessor

  function ReverseAccessor:get(indexWith)
    
    return self._meta:get(
      indexWith:rev(#self)
    )
  end
end


do
  local BatchAccessor, parent = oc.class(
    'ocnn.data.accessor.Batch', 
    oc.data.accessor.Meta
  )
  ocnn.data.accessor.Batch = BatchAccessor

  function BatchAccessor:__init(size, accessor)
    parent.__init(self, accessor)
    self._batchSize = size
  end

  function BatchAccessor:get(indexWith)
    return self._meta:get(
      indexWith:expand(self._batchSize)
    )
  end
  
  function BatchAccessor:__len__()
    return math.floor(
      #self._meta / self._batchSize
    )
  end
end
