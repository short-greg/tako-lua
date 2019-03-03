require 'oc.class'
require 'oc.nerve'
require 'oc.data.index'


--! ######################################
--!	Iter modules provide iteration over
--! data
--! 
--! oc.Iterator allow for the iteration
--! oc.ForwardIterator iterates forward over
--!   data, 
--! oc.Backward iterates backward over the
--!   data
--!
--! oc.Iterate iterates using an iterator
--!   that has been passed in
--!
--! oc.ToIter converts the data that
--!   has been passed in to an iterator.
--!
--! ######################################


do
  local Iterator, parent = oc.class(
    'oc.Iterator'
  )
  --! ######################################
  --!	The base Iterator class used for
  --! iterating over data.
  --! @abstract 
  --!
  --! ######################################
  oc.Iterator = Iterator
  
  function Iterator:__init(data)
    --! @param data - accessor to the data
    self._data = data
  end

  function Iterator:adv()
    --! 
    --! 
    error(
      'Method adv() is not defined for the '..
      'abstract class Iterator.'
    )
  end
  
  function Iterator:atEnd()
    --! @return whether or not the iterator
    --!         is at the end of the data.
    error(
      'atEnd() undefined for Iterator base class'
    )
  end

  function Iterator:get()
    --! @return the value the iterator points
    --!         to in its current position
    if self:atEnd() then
      return nil
    end
    
    return self._data:get(self._i)
  end

  function Iterator:set(data)
    --! @data the value you want to set
    --!       the current 
    assert(
      not self:atEnd(),
      'Cannot set a value for the iterator '..
      'if at the end.'
    )
    self._data:put(self._i, data)
  end
  
  function Iterator:data()
    return self._data
  end
end


do
  local ForwardIterator, parent = oc.class(
    'oc.ForwardIterator', oc.Iterator
  )
  --! ######################################
  --!	Iterator that iterates forward over
  --! the data.
  --!
  --! data = {1, 2, 3}
  --! @example y = oc.ForwardIterator(data)
  --!          y:get() -> outputs 1
  --!          y:adv() -> outputs true
  --!          y:get() -> outputs 2
  --!
  --! ######################################
  oc.ForwardIterator = ForwardIterator
  --! Iterates over an iterator
  
  function ForwardIterator:__init(data)
    --! @constructor
    --! @param - data - DataAccessor
    parent.__init(self, data)
    self._i = oc.data.index.Index(1)
  end
  
  function ForwardIterator:adv()
    --! @post iterator is incremented if 
    --!       at the end
    --! @return whether or not iteration was
    --!         successful
    if not self:atEnd() then
      self._i:incr()
      return true
    end
    return false
  end
  
  function ForwardIterator:atEnd()
    return self._i:val() == #self._data + 1
  end
end


do
  local BackwardIterator, parent = oc.class(
    'oc.BackwardIterator', oc.Iterator
  )
  --! ######################################
  --!	Iterator that does reverse iteration
  --! over the data.
  --!
  --! data = {1, 2, 3}
  --! @example y = oc.BackwardIterator(data)
  --!          y:get() -> outputs 3
  --!          y:adv() -> outputs true
  --!          y:get() -> outputs 2
  --!
  --! ######################################
  oc.BackwardIterator = BackwardIterator

  function BackwardIterator:__init(data)
    --! 
    --! @param data - 
    parent.__init(self, data)
    self._i = oc.data.index.Index(#data)
  end
  
  function BackwardIterator:atEnd()
    --! @return whether the iterator is at
    --!         the end of the data - boolean
    return self._i:val() == 0
  end
  
  function BackwardIterator:adv()
    --! @post the iterator is decremented if not at
    --!       the end
    --! @return whether the iterator advanced - boolean
    if not self:atEnd() then
      self._i:decr()
      return true
    end
    return false
  end
end

--! ##########################################
--! The following nerves allow for iteration
--!
--! <object> .. oc.ToIter() .. oc.Iter()
--! Object must have an toIter function which
--! toIter will convert to an iterator and
--! Iter will iterate over
--! 
--! The iterator must be a callable
--! like typical iterators in Lua
--! ##########################################

do
  local ToIter, parent = oc.class(
    'oc.ToIter', oc.Nerve
  )
  --! ######################################
  --!	Converts data to an iterator 
  --! the data should have an 
  --!
  --! @input data (with toIter function)
  --! @output Iterator
  --!
  --! data = {1, 2, 3, toIter=function () ... end}
  --! @example y = oc.ToIter()
  --!          y:out(data) ->  
  --!            {out=Iterator, back=Iterator}
  --!
  --! ######################################
  oc.ToIter = ToIter

  function ToIter:__init()
    --! @constructor
    parent.__init(self)
  end
  
  function ToIter:out(input)
    assert(
      input.toIter,
      string.format(
        'Input of type %s does not have '..
        'toIter function',
        oc.class(input)
      )
    )
    return input:toIter(self.gradOn)
  end
  
  function ToIter:grad(input, gradOutput)
    return gradOutput.backward:data()
  end
end


do
  local Iterate, parent = oc.class(
    'oc.Iterate', oc.Nerve
  )
  --! ######################################
  --!	Converts data to an iterator 
  --! the data should have an 
  --!
  --! @input {ForwardIterator, BackwardIterator}
  --! @output (the data that gets output by the iterator)
  --!
  --! data = {1, 2, 3, toIter=function () ... end}
  --! @example y = oc.ToIter() .. oc.Iterate()
  --!          y:stimulate(data) -> 1
  --!
  --! ######################################
  oc.Iterate = Iterate
  
  function Iterate:__init()
    --! @constructor
    parent.__init(self)
  end
  
  function Iterate:out(input)
    --! @param input {out=Iterator, back=Iterator}
    --! @return value returned by get on the iterator
    local cur = input.out:get()
    input.out:adv()
    return cur
  end
  
  function Iterate:grad(input, gradOutput)
    --! @param input 
    --! @param gradOutput A table of gradients
    input.grad:set(gradOutput)
    input.grad:adv()
    return input
  end
end
