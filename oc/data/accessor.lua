require 'oc.class'
require 'oc.chain'
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
  
  function Accessor:get(indexWith)
    error(
      'Method get() is not implemented in the '.. 
      'base accessor class.'
    )
  end
  
  function Accessor:put(indices, data)
    error(
      'Method put() is not implemented in the '.. 
      'base accessor class.'
    )
  end
  
  function Accessor:__len__()
    error(
      'Method __len__() is not implemented in the '.. 
      'base accessor class.'
    )
  end
  
  function Accessor:__nerve__()
    return oc.data.accessor.Nerve(self)
  end
  
  function Accessor:toIter(gradOn)
    --! 
    --!
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
  
  function Accessor:data()
    error(
      'Method data() not '..
      'defined for base class.'
    ) 
  end
  
  function Accessor:storage()
    --! storage defines a 
    --! data structure to 
    --! store data on back propagation
    error(
      'Method storage() not '..
      'defined for base class.'
    )
  end
  
  --! Allow nerve declartions for accessor as well
  Accessor.d = oc.declaration
  --! @param cls
  --! @param args - Args for construction
  --! @return oc.Nerve (will create an 
  --! AccessorNerve on definition)
  
  Accessor.__concat__ = oc.concat
end


do
  local MetaAccessor, parent = oc.class(
    'oc.data.accessor.Meta',
    oc.data.accessor.Base
  )
  oc.data.accessor.Meta = MetaAccessor

  function MetaAccessor:__init(accessor)
    --! 
    --! @param accessor - Accessor or nil
    self._meta = accessor
  end

  function MetaAccessor:setMeta(accessor)
    --! 
    --! @param accessor - Accessor or nil
    self._meta = accessor
  end
  
  function MetaAccessor:getMeta()
    return self._meta
  end
  
  function MetaAccessor:storage()
    --! storage defines a 
    --! data structure to 
    --! store data on back propagation
    --!
    --! MetaAccessor itself should
    --! not have accesss to a storage
    return self._meta:storage()
  end
  
  function MetaAccessor:data()
    --!
    --! MetaAccessor itself should
    --! not have accesss to a storage
    return self._meta:data()
  end
  
  function MetaAccessor:__len__()
    return #self._meta
  end

  function MetaAccessor:__nerve__()
    return oc.data.accessor.MetaNerve(self)
  end
end
