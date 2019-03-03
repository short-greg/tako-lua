require 'oc.class'
require 'oc.oc'
require 'oc.pkg'

-- TODO: Decide if I want to leave this

do
  ---
  -- @example 
  --
  -- @input: nil (must not input anything)
  -- @output: the value of the constant
  --
  local Emission, parent = oc.class(
    'oc.Emission'
  )
  oc.Emission = Emission
  
  function Emission:__init()
    self._vals = {}
  end
  
  function Emission:removeFrom(index)
    self._vals = table.pack(table.unpack(
      self._vals, 1, index - 1  
    ))
  end

  --- @param from - lower bound of index 
  -- range - int or nil default is 1
  -- @param to - upper bound of index 
  -- range - int or nil default is maxn
  -- @return {vals}
  function Emission:getRange(from, to)
    from = from or 1
    to = to or table.maxn(self._vals)
    
    return table.pack(table.unpack(
      self._vals, from, to  
    ))
  end
  
  function Emission:reset()
    self._vals = {}
  end

  function Emission:__index__(self, index)
    if self._vals[index] then
      return self._vals[index]
    end
  end

  function Emission:__newindex__(self, index, val)
    assert(
      type(index) == 'number' or not oc.isInstance(self),
      'New index must be of type number'
    )
    assert(
      not (not oc.isInstance(self) and type(index) == 'number'),
      'Cannot add a numberical index to class of type Emission.'
    )
    if tonumber(index) then
      self._vals[index] = val
    end
  end
end
