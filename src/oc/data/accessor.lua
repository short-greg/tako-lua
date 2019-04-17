require 'oc.class'
require 'oc.strand'
require 'oc.nerve'
require 'oc.data.pkg'
require 'oc.data.storage'
require 'oc.iter'
require 'oc.undefined'

oc.data.accessor = oc.data.accessor or {}


do
  local AccessorNerve, parent = oc.class(
    'oc.data.accessor.Nerve', oc.Nerve
  )
  oc.data.accessor.Nerve = AccessorNerve
  
  function AccessorNerve:__init(accessor)
    parent.__init(self)
    self._accessor = accessor
  end
  
  function AccessorNerve:out(input)
    return self._accessor
  end
  
  function AccessorNerve:grad(input, gradOutput)
    --! 
    return gradOutput:data()
  end
end


do
  local MetaAccessorNerve, parent = oc.class(
    'oc.data.accessor.MetaNerve', 
    oc.data.accessor.Nerve
  )
  oc.data.accessor.MetaNerve = MetaAccessorNerve
  
  function MetaAccessorNerve:out(input)
    self._accessor:setMeta(input)
    return parent.out(self)
  end
  
  function MetaAccessorNerve:grad(
      input, gradOutput
  )
    return gradOutput():meta()
  end
end


do
  local Accessor, parent = oc.class(
    'oc.data.accessor.Base'
  )
  oc.data.accessor.Base = Accessor

  --- Get data from the source
  -- @param indices - the indices to set - oc.DataIndex
  -- @return the data that being accessed
  function Accessor:get(indexWith)
    error(
      'Method get() is not implemented in the '.. 
      'base accessor class.'
    )
  end
  
  --- Set data in the source
  -- @param indices - the indices to set the source - oc.DataIndex
  -- @param data - the data to set to 
  function Accessor:put(indices, data)
    error(
      'Method put() is not implemented in the '.. 
      'base accessor class.'
    )
  end
  
  --- @return number of elements to iterator over - int
  function Accessor:__len__()
    error(
      'Method __len__() is not implemented in the '.. 
      'base accessor class.'
    )
  end

  --- @return oc.data.accessor.Nerve
  function Accessor:__nerve__()
    return oc.data.accessor.Nerve(self)
  end

  --- @param gradOn - whether the gradient is on for the iterator
  -- @return oc.Iterator
  function Accessor:toIter(gradOn)
    local grad
    if gradOn then
      grad = oc.BackwardIterator(self:storage())
    else
      grad = nil
    end
    
    return {
      out=oc.ForwardIterator(self),
      grad=grad
    }
  end

  --- @return the source data
  function Accessor:data()
    error(
      'Method data() not '..
      'defined for base class.'
    ) 
  end

  --- storage defines a data structure to 
  -- store data on back propagation
  function Accessor:storage()
    error(
      'Method storage() not '..
      'defined for base class.'
    )
  end
  
  --- Allow nerve declartions for accessor as well
  -- @param cls
  -- @param args - Args for construction
  -- @return oc.Nerve (will create an 
  -- AccessorNerve on definition)
  Accessor.d = oc.declaration
  
  Accessor.__concat__ = oc.concat
end


do
  local MetaAccessor, parent = oc.class(
    'oc.data.accessor.Meta',
    oc.data.accessor.Base
  )
  oc.data.accessor.Meta = MetaAccessor

  --- @param accessor - Accessor or nil
  function MetaAccessor:__init(accessor)
    self._meta = accessor
  end

  --- @param accessor - Accessor or nil
  function MetaAccessor:setMeta(accessor)
    self._meta = accessor
  end
  
  function MetaAccessor:getMeta()
    return self._meta
  end

  --- storage defines a 
  -- data structure to 
  -- store data on back propagation
  --
  -- MetaAccessor itself should
  -- not have accesss to a storage
  function MetaAccessor:storage()
    return self._meta:storage()
  end

  --- MetaAccessor itself should
  -- not have accesss to a storage
  function MetaAccessor:data()
    return self._meta:data()
  end
  
  function MetaAccessor:__len__()
    return #self._meta
  end

  function MetaAccessor:__nerve__()
    return oc.data.accessor.MetaNerve(self)
  end
end
