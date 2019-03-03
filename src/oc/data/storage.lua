require 'oc.class'
require 'oc.oc'
require 'oc.data.pkg'

oc.data.storage = oc.data.storage or {}


do
  local Storage, parent = oc.class(
    'oc.data.Storage'
  )
  oc.data.Storage = Storage
  
  function Storage:__init()
    --
  end

  --- Empty out the data being stored
  -- 
  -- @post - The data should be reset to the initial state
  function Storage:empty()
    error(
      'Method empty() not defined for Storage.'
    )
  end
  
  function Storage:setData(index, val)
    error(
      'Method setData() not defined for Storage.'
    )
  end
  
  function Storage:__len__()
    error(
      'Length operator must be '..
      'defined for Storage.'
    )
  end
  
  function Storage:__newindex__(index, val)
    if oc.isInstance(self) and 
       type(index) == 'number' then
      assert(
        index > 0 and index <= self._length,
        'Index to table storage must be a number.'
      )   
      self:setData(val)
      return
    else
      rawset(
        self, index, val
      )
    end
  end

  function Storage:data()
    error(
      'data() not defined for base Storage class '
    )
  end
end


do
  local NullStorage, parent = oc.class(
    'oc.data.NullStorage', oc.data.Storage
  )
  oc.data.NullStorage = NullStorage
  
  function NullStorage:__init()
    --
  end

  --- Empty out the data being stored
  -- 
  -- @post - The data should be reset to the initial state
  function NullStorage:empty()
    --
  end
  
  function NullStorage:setData(index, val)
  end
  
  function NullStorage:__len__()
    return 0
  end

  function NullStorage:data()
    return nil
  end
end
