
do
  require 'oc.iter'
  require 'oc.data.accessor'
  require 'oc.data.table'
  
  local accessor = oc.data.accessor.Table({1, 2, 3, 4})
  local iterator = oc.ForwardIterator(accessor)
  assert(
    iterator:atEnd() == false,
    'Should not be at the end of the sequence.'
  )
end


do
  require 'oc.iter'
  require 'oc.data.accessor'
  require 'oc.data.table'
  
  local accessor = oc.data.accessor.Table({1, 2, 3, 4})
  local iterator = oc.ForwardIterator(accessor)
  iterator:adv()
  assert(
    iterator:get() == 2 and not iterator:atEnd(),
    'Should return the second item.'
  )
end

do
  require 'oc.iter'
  require 'oc.data.accessor'
  require 'oc.data.table'
  
  local accessor = oc.data.accessor.Table({1, 2, 3, 4})
  local iterator = oc.ForwardIterator(accessor)
  iterator:adv()
  iterator:adv()
  iterator:adv()
  iterator:adv()
  assert(
    iterator:get() == nil and iterator:atEnd(),
    'Should be at the end.'
  )
end


do
  require 'oc.iter'
  require 'oc.data.accessor'
  require 'oc.data.table'
  
  local accessor = oc.data.accessor.Table({1, 2, 3, 4})
  local iterator = oc.ForwardIterator(accessor)
  iterator:adv()
  iterator:set(4)
  assert(
    iterator:get() == 4,
    'The present value should be 4.'
  )
end

do
  require 'oc.iter'
  require 'oc.data.accessor'
  require 'oc.data.table'
  local data = {1, 2, 3, 4}
  local accessor = oc.data.accessor.Table(data)
  local iterator = oc.ForwardIterator(accessor)
  assert(
    iterator:data() == accessor,
    'The data should be the accessor passed in.'
  )
end


do
  require 'oc.iter'
  require 'oc.data.accessor'
  require 'oc.data.table'
  local data = {1, 2, 3, 4}
  local accessor = oc.data.accessor.Table(data)
  local mod = oc.ToIter()
  local iterator = mod:stimulate(accessor)
  assert(
    oc.type(iterator.out) == 'oc.ForwardIterator',
    'Output should be of type iterator.'
  )
  assert(
    iterator.out:data() == accessor,
    'The data should be the accessor passed in.'
  )
  
  print(oc.type(iterator.grad))
  assert(
    oc.type(iterator.grad) == 'oc.BackwardIterator',
    'Output should be of type backward iterator.'
  )
  assert(
    oc.type(iterator.grad:data()) == 
      'oc.data.TableStorage',
    'The data should be the accessor passed in.'
  )
end


do
  require 'oc.iter'
  require 'oc.data.accessor'
  require 'oc.data.table'
  local data = {1, 2, 3, 4}
  local accessor = oc.data.accessor.Table(data)
  local mod = oc.ToIter()
  local iterator = mod:stimulate(accessor)
  
  local iterate = oc.Iterate()
  for i=1, #data do
    assert(
      iterate:stimulate(iterator) == data[i],
      'The data does not correspond to the output.'
    )
  end
end
