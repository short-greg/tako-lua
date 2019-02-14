require 'torch'

--[[
require 'dataset.array'


function octest.iter_arrayiter_adv()
  local input = {1, 2, 3, 6, 4, nil, 7}
  local target = {1, 2, 3, 6, 4}
  local result = {}
  local pos = 1
  
  local iter = oc.data.ArrayIter()
  
  for val in iter:adv(input) do
    result[pos] = val
    pos = pos + 1
  end
  
  octester:eq(
    target, result,
    'The target does not equal the result'
  )
end

function octest.iter_arrayiter_rev()
  local input = {1, 2, 3, 6, 4, nil, 7}
  local target = {7}
  local result = {}
  local pos = 1
  
  local iter = oc.data.ArrayIter()
  
  for val in iter:rev(input) do
    result[pos] = val
    pos = pos + 1
  end
  
  octester:eq(
    target, result,
    'The target does not equal the result'
  )
end
--]]
