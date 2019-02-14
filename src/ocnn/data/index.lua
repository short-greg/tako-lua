require 'oc.init'
require 'ocnn.data.pkg'
require 'oc.data.index'

ocnn.data.index = {}


--!
--! Expands functionality of Index to indexOn tensors and
--! to pass in a tensor of indices to the index
--! 
--! indexOnTensor <- pass a tensor to indexOn to speed up processing
--!   on tensors
--! indices <- pass a tensor of indices to create an index.Indices
--! 
--! ocnn.data.index.Indices <- a tensor of indices to 
--!   used to index multiple values
local function getRange(startingVal, frameSize)
  return torch.range(
    startingVal, startingVal + frameSize - 1
  ):long()
end


do
  function oc.data.index.IndexBase:indices(indices)
    error('indices() not defined.')
  end

  function oc.data.index.IndexBase:indexOnTensor(sequence)
    --! @param sequence - a value that
    --!        allows for sequential access
    error('indexOnTensor() not defined.')
  end
  
  function oc.data.index.IndexBase:indexUpdate(
    sequence, val
  )
    error('indexUpdate() not defined for base class.')
  end

  function oc.data.index.IndexBase:indexUpdateTensor(
    sequence, val
  )
    error('indexUpdateTensor() not defined for base class.')
  end
end


do
  --! 
  --! 
  --! 
  function oc.data.index.Index:indexOnTensor(tensor, result)
    result = result or torch.Tensor():typeAs(tensor)
    result:set(tensor:narrow(
      1, self._index, 1
    ))
    return result
  end

  function oc.data.index.Index:tensorIndices(indices)
    --! 
    --! @param indices - Indices to the data - Indices
    assert(
      indices:dim() == 1 and indices:size(1) == 1 and
      indices[1] == 1
    )
    return ocnn.data.index.Indices(
      torch.LongTensor{self._index}
    )
  end
  
  function oc.data.index.Index:indexUpdate(
    sequence, val
  )
    sequence[self._index] = val
  end
  
  function oc.data.index.Index:indexUpdateTensor(
    tensor, val
  )
    tensor:narrow(
      1, self._index, 1
    ):copy(val)
  end
end


do
  function oc.data.index.IndexRange:indexOnTensor(
    tensor, result
  )
    result = result or torch.Tensor()
    result:set(tensor:narrow(
      1, self._startingVal, self._frameSize
    ))
    return result
  end

  function oc.data.index.IndexRange:tensorIndices(indices)
    --! 
    --! @param indices - Indices to the data - Indices
    return ocnn.data.index.Indices(
      getRange(self._startingVal, self._frameSize):index(
        1, indices
      )
    )
  end

  function oc.data.index.Index:indexUpdate(
    sequence, val
  )
    for i=1, self._frameSize do
      sequence[i + self._startingVal - 1] = val[i]
    end
  end
  
  function oc.data.index.IndexRange:indexUpdateTensor(
    sequence, val
  )
    sequence:narrow(
      1, self._startingVal, self._frameSize
    ):copy(val)
  end
end


do
  local Indices, parent = oc.class(
    'ocnn.data.index.Indices', 
    oc.data.index.IndexBase
  )
  ocnn.data.index.Indices = Indices
  --! 
  --! 
  --! 
  --! 
  
  function Indices:__init(indices)
    --! 
    --! @param indices - Indices to the
    --! data - Indices
    assert(
      oc.type(indices) == 'torch.LongTensor',
      'Indices must be of type LongTensor.'
    )
    self._indices = indices
  end
  
  function Indices:tensorIndices(indices)
    --
    return Indices(
      self._indices:index(1, indices)
    )
  end
  
  function Indices:incr()
    self._indices:add(1)
  end
  
  function Indices:decr()
    self._indices:add(-1)
  end
  
  function Indices:expand(expandBy)
    --
    local updated = torch.LongTensor()
    for i=1, self._indices:size(1) do
      local cur = self._indices[i]
      updated = torch.cat(
        updated,
        torch.range(
          self._expandHelper(cur, expandBy), 
          self._expandHelper(cur + 1, expandBy) - 1 
        ):long()
      )
    end
    
    return Indices(updated)
  end
  
  function Indices:offset(offsetBy)
    --
    return Indices(self._indices + offsetBy)
  end
  
  function Indices:rev(size)
    return Indices(
      size - self._indices + 1
    )
  end

  function Indices:indexOn(sequence)
    local result = {}
    for i=1, self._indices:size(1) do
      table.insert(
        result, sequence[self._indices[i]] 
      )
    end
    return result
  end

  function Indices:indexOnTensor(tensor, result)
    result = result or torch.Tensor():typeAs(tensor)
    result:set(tensor:index(
      1, self._indices
    ))
    return result
  end

  function Indices:tensorIndices(indices)
    --! 
    --! @param indices - Indices to the data - Indices
    return Indices(
      self._indices:index(
        1, indices
      )
    )
  end

  function Indices:indexUpdate(sequence, val)
    for i=1, #self._indices do
      sequence[self._indices[i]] = val[i]
    end
  end

  function Indices:indexUpdateTensor(sequence, val)
    sequence:indexCopy(1, self._indices, val)
  end
end
