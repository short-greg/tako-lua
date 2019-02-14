require 'oc.class'
require 'oc.data.storage'
require 'ocnn.data.pkg'
require 'ocnn.data.set'


do
  local TensorStorage, parent = oc.class(
    'ocnn.data.TensorStorage', 
    oc.data.Storage
  )
  --! Accesses a tensor for iteration
  --! 
  ocnn.data.TensorStorage = TensorStorage
  
  function TensorStorage:__init(tensor)
    self._tensor = tensor:clone():zero()
    self._length = tensor:size(1)
  end
  
  function TensorStorage:__len__()
    return self._length
  end

  function TensorStorage:setData(indices, val)
    --! need to update datatable storage
    indices:indexOnTensor(
      self._tensor
    ):zero():add(val)
  end
  
  function TensorStorage:data()
    return self._tensor
  end
end


--[[
do
  local DataTableStorage, parent = oc.class(
    'ocnn.data.DataTableStorage'
  )
  ocnn.data.DataTableStorage = DataTableStorage
  
  function DataTableStorage:__init(datatable)
    local length
    local storageData = {}
    
    for k, v in pairs(datatable.data) do
      storageData[k] = torch.Tensor():typeAs(v):resizeAs(v):zero()
    end
    
    self._data = ocnn.data.DataTable(storageData)
  end
  
  function DataTableStorage:setData(indices, val)
    --! need to update datatable storage
    
  end

  function DataTableStorage:__len__()
    return #self._data
  end
end


do
  local DatasetStorage, parent = oc.class(
    'ocnn.data.DatasetStorage'
  )
  ocnn.data.DatasetStorage = DatasetStorage
  
  function DatasetStorage:__init(dataset)
    self._dataTables = {}
    self._length = #dataset
    for i=1, #length do
      self._dataTables[i] = ocnn.data.DataTableStorage(
        dataset[i]
      )
    end
  end
  
  function DatasetStorage:__len__()
    return self._length
  end
end
--]]
