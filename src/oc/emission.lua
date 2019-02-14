require 'oc.class'
require 'oc.pkg'


do
  local Emission, parent = oc.class(
    'oc.Emission'
  )
  --! ######################################
  --!	
  --!
  --! @example 
  --!
  --! @input: nil (must not input anything)
  --! @output: the value of the constant
  --!
  --! ######################################
  oc.Emission = Emission
  
  function Emission:__init()
    self._vals = {}
  end
  
  function Emission:removeFrom(index)
    self._vals = table.pack(table.unpack(
      self._vals, 1, index - 1  
    ))
  end
  
  function Emission:getRange(from, to)
    --! 
    --! @param from - lower bound of index 
    --! range - int or nil default is 1
    --! @param to - upper bound of index 
    --! range - int or nil default is maxn
    --! @return {vals}
    
    from = from or 1
    to = to or table.maxn(self._vals)
    
    return table.pack(table.unpack(
      self._vals, from, to  
    ))
  end

  function Emission:index(i)
    --! @param i - the index to set the current index to
    --!            i > 0
    assert(
      i > 0,
      'Index must be nonnegative.'
    )
    self._index = i
  end
  
  function Emission:reset()
    self._vals = {}
  end
  
  function Emission:set(index, val)
    --! @param val - the value to set the current index to
    self._vals[index] = val
  end
  
  function Emission:get()
    --! @return Value at the present index - 
    return self._vals[self._index]
  end
end
