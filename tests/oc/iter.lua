require 'oc.iter'
require 'ocnn.data.accessor'
require 'ocnn.data.set'


function octest.oc_forward_iterator_on_table()
  local data = ocnn.data.Table{
    x=torch.Tensor({1, 2, 3, 4})
  }
  local accessor = ocnn.data.accessor.Table(data)
  local iterator = oc.ForwardIterator(accessor)
  octester:assert(
    iterator:atEnd() == false,
    'Should not be at the end of the sequence.'
  )
end


function octest.oc_forward_iterator_on_table_get()
  local data = ocnn.data.Table{
    x=torch.Tensor({1, 2, 3, 4})
  }
  local accessor = ocnn.data.accessor.Table(data)
  local iterator = oc.ForwardIterator(accessor)
  iterator:adv()
  octester:assert(
    iterator:get()['x'][1] == 2 and not iterator:atEnd(),
    'Should return the second item.'
  )
end


function octest.oc_forward_iterator_on_table_adv()
  local data = ocnn.data.Table{
    x=torch.Tensor({1, 2, 3, 4})
  }
  local accessor = ocnn.data.accessor.Table(data)
  local iterator = oc.ForwardIterator(accessor)
  iterator:adv()
  iterator:adv()
  iterator:adv()
  iterator:adv()
  octester:assert(
    iterator:get() == nil and iterator:atEnd(),
    'The iterator should have reached the end.'
  )
end

--[[
-- TODO: need to implement this
function octest.oc_forward_iterator_on_table_set_get()  
  local accessor = ocnn.data.accessor.Table({1, 2, 3, 4})
  local iterator = oc.ForwardIterator(accessor)
  iterator:adv()
  iterator:set(4)
  octester:assert(
    iterator:get() == 4,
    'The present value should be 4.'
  )
end
--]]

function octest.oc_forward_iterator_on_table_data()
  local data = ocnn.data.Table{
    x=torch.Tensor({1, 2, 3, 4})
  }
  local accessor = ocnn.data.accessor.Table(data)
  local iterator = oc.ForwardIterator(accessor)
  octester:assert(
    iterator:data() == accessor,
    'The data should be the accessor passed in.'
  )
end


function octest.oc_to_iter_stimulate()
  local data = ocnn.data.Table{
    x=torch.Tensor({1, 2, 3, 4})
  }
  local accessor = ocnn.data.accessor.Table(data)
  local mod = oc.ToIter()
  local iterator = mod:stimulate(accessor)
  octester:assert(
    oc.type(iterator.out) == 'oc.ForwardIterator',
    'Output should be of type iterator.'
  )
  octester:assert(
    oc.type(iterator.grad) == 'oc.BackwardIterator',
    'Output should be of type backward iterator.'
  )
  octester:asserteq(
    oc.type(iterator.grad:data()),
      'oc.data.NullStorage',
    'The storage for the iterator should be null storage.'
  )
end


function octest.oc_table_accessor_to_iter_stimulate()  
  local data = ocnn.data.Table{
    x=torch.Tensor({1, 2, 3, 4})
  }
  local accessor = ocnn.data.accessor.Table(data)
  local mod = oc.ToIter()
  local iterator = mod:stimulate(accessor)
  
  local iterate = oc.Iterate()
  for i=1, 2 do
    local result = iterate:stimulate(iterator)['x']
    --! TODO: figure out why it 
    --! should be indexed by 1
    octester:asserteq(
      result[1], data:index(i)['x'][1],
      'The data does not correspond to the output.'
    )
  end
end
