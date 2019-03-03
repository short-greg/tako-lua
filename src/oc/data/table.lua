require 'oc.data.accessor'
require 'oc.data.storage'


do
  local TableAccessor, parent = oc.class(
    'oc.data.accessor.Table', 
    oc.data.accessor.Base
  )
  oc.data.accessor.Table = TableAccessor

  function TableAccessor:__init(sequence)
    self._sequence = sequence
  end

  --- TODO: need to fix this
  function TableAccessor:get(indexWith)
    return indexWith:indexOn(
      self._sequence
    )
  end
  
  function TableAccessor:put(indices, data)
    indices:indexUpdate(self._sequence, data)
  end
  
  function TableAccessor:__len__()
    return #self._sequence
  end

  --- storage defines a 
  -- data structure to 
  -- store data on back propagation
  function TableAccessor:data()
    return self._sequence
  end

  --- storage defines a 
  -- data structure to 
  -- store data on back propagation
  function TableAccessor:storage()
    return oc.data.TableStorage(self._table)
  end
end


do
  local TableStorage, parent = oc.class(
    'oc.data.TableStorage'
  )
  oc.data.TableStorage = TableStorage
  
  function TableStorage:__init()
    rawset(self, '_data', {})
    rawset(self, '_length', #self._data)
  end

  function TableStorage:__len__()
    return table.maxn(self._data)
  end

  --- Empty out the data being stored
  -- 
  -- @post - The data should be reset to the initial state
  function TableStorage:empty()
    self._data = {}
  end
  
  function TableStorage:setData(index, val)
    index:indexUpdate(self._data, val)
  end

  --- ensure that only data up
  -- is included
  function TableStorage:data()
    return table.pack(
      table.unpack(self._data, 1, #self)
    )
  end
end
