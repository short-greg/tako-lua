require 'oc.class'
require 'oc.data.pkg'

oc.data.index = oc.data.index or {}


do
  --- IndexBatch
  local IndexBase, parent = oc.class(
    'oc.data.index.IndexBase'
  )
  
  oc.data.index.IndexBase = IndexBase

  function IndexBase._expandHelper(value, expandBy)
    return (value - 1) * expandBy + 1
  end

  function IndexBase:rev(size)
    error('rev() not defined.')
  end

  function IndexBase:expand(expandBy)
    error('expand() not defined.')
  end
  
  function IndexBase:incr()
    error('incr() not defined.')
  end
  
  function IndexBase:decr()
    error('decr() not defined.')
  end

  --- @param sequence - a value that 
  -- allows for sequential access
  function IndexBase:indexOn(sequence)
    error('indexOn() not defined.')
  end
end


do
  --! Index
  --! 
  local Index, parent = oc.class(
    'oc.data.index.Index', 
    oc.data.index.IndexBase
  )
  oc.data.index.Index = Index

  --- @param index - Index to the data - number
  function Index:__init(index)
    self._index = index
  end
  
  function Index:__index__(index)
    if type(index) == 'number' then
      assert(
        index == 1,
        'Index only has one element.'
      )
      return self._index
    end
  end
  
  function Index:val()
    return self._index
  end
  
  function Index:rev(size)
    return Index(size - self._index + 1)
  end

  --
  function Index:expand(expandBy)
    return oc.data.index.IndexRange(
      self._expandHelper(self._index, expandBy),
      expandBy, 1
    )
  end
  
  function Index:incr()
    self._index = self._index + 1
  end
  
  function Index:decr()
    self._index = self._index - 1
  end
  
  function Index:indexOn(sequence)
    return sequence[self._index]
  end

  function Index:indexUpdate(sequence, val)
    sequence[self._index] = val
  end
end


do

  --- IndexRange selects a range of values
  -- from a sequential
  -- 
  local IndexRange, parent = oc.class(
    'oc.data.index.IndexRange', 
    oc.data.index.IndexBase
  )
  oc.data.index.IndexRange = IndexRange

  --- @param index - Index to the data - number
  function IndexRange:__init(startVal, frameSize, shiftSize)
    self._startingVal = startVal or 1
    self._frameSize = frameSize or 1
    self._shiftSize = shiftSize or 1
  end
  
  function IndexRange:rev(size)
    return IndexRange(
      size - (self._startingVal + self._frameSize - 1),
      self._frameSize, self._shiftSize
    )
  end
  
  function IndexRange:expand(expandBy)
    return IndexRange(
      self._startingVal * expandBy - 1,
      self._frameSize * expandBy, 
      self._shiftSize
    )
  end
  
  function IndexRange:incr()
    self._startingVal = self._startingVal +
                        self._shiftSize
  end

  function IndexRange:decr()
    self._index = self._startingVal - 
                  self._shiftSize
  end
  
  function IndexRange:__index__(index)
    if type(index) == 'number' then
      assert(
        index <= self._frameSize and index,
        string.format(
          'Index is out of bounds for the range. '..
          '1 <= index <= %d',
          self._frameSize
        )
      )
      return self._startingVal + index - 1
    end
  end
  
  function IndexRange:indexOn(sequence)
    local result = {}
    for i=1, self._frameSize do
      table.insert(
        result, sequence[i + self._startingVal - 1]
      )
    end
    return result
  end

  function IndexRange:indexUpdate(sequence, val)
    for i=1, self._frameSize do
      sequence[i + self._startingVal - 1] = val[i]
    end
  end
end
