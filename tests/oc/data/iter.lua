require 'torch'
require 'ocnn.module'
require 'oc.data.accessor'
require 'oc.data.iter'
require 'oc.emission'
require 'oc.data.set'
require 'testsupport.testdata'

local cols = {'input', 'target'}
local training = {
  oc.Emission(table.unpack(torch.range(1, 11):totable())),
  oc.Emission(table.unpack(torch.rand(11):totable()))
}

local testing = {
  oc.Emission(table.unpack(torch.range(1, 9):totable())),
  oc.Emission(table.unpack(torch.rand(9):totable()))
}

function octest.data_iter_base_out()
  local windowSize = 2
  local iter = oc.data.iter.IndexBatch(false, false, windowSize)
  local dataset = oc.data.set.TestSet(cols, training, testing)
  -- gradOut = oc.Emission(torch.range(1, 5):totable())
  local target = {}
  local result = {}
  local targetVals = training[1]
  local i = 1
  for curInput in iter:out(dataset) do
    result[i] = curInput[1]
    target[i] = oc.Emission(targetVals[(i - 1)* 2 + 1], targetVals[(i - 1) * 2 + 2])
    i = i + 1
  end
  octester:eq(
    target, result,
    'The result does not equal the target'
  )
  octester:eq(
    #result, math.floor(#training[2] / windowSize), 
    'There are too many elements in the result'
  )
end

function octest.data_iter_base_rev()
  local windowSize = 2
  local iter = oc.data.iter.IndexBatch(true, false, windowSize)
  local dataset = oc.data.set.TestSet(cols, training, testing)
  local target = {}
  local result = {}
  local targetVals = training[1]
  local i = 5
  for curInput, curGrad in iter:out(dataset) do
    result[i] = curInput[1]
    target[i] = oc.Emission(targetVals[(i - 1)* 2 + 1], targetVals[(i - 1) * 2 + 2])
    i = i - 1
  end
  octester:eq(
    target, result,
    'The result does not equal the target'
  )
  octester:eq(
    #result, math.floor(#training[2] / windowSize), 
    'There are too many elements in the result'
  )
end

function octest.data_iter_base_grad()
  local windowSize = 2
  local iter = oc.data.iter.IndexBatch(false, false, windowSize)
  local dataset = oc.data.set.TestSet(cols, training, testing)
  local gradOut = oc.Emission(table.unpack(torch.range(1, 5):totable()))
  local target = {}
  local result = {}
  local resultGrad = {}
  local targetVals = training[1]
  local i = 1
  for curInput, curGrad, index in iter:grad(dataset, gradOut) do
    result[i] = curInput[1]
    target[i] = oc.Emission(targetVals[(i - 1)* 2 + 1], targetVals[(i - 1) * 2 + 2])
    resultGrad[i] = curGrad
    i = i + 1
  end
  octester:eq(
    target, result,
    'The result does not equal the target'
  )
  octester:eq(
    #result, math.floor(#training[2] / windowSize), 
    'There are too many elements in the result'
  )
  resultGrad.n = #resultGrad
  
  octester:eq(
    resultGrad, gradOut:totable(),
    'The result grad should be the same as gradOut'
  )
end

function octest.data_iter_base_rev_forward_grad()
  local windowSize = 2
  local iter = oc.data.iter.IndexBatch(true, false, windowSize)
  local dataset = oc.data.set.TestSet(cols, training, testing)
  local gradOut = oc.Emission(table.unpack(torch.range(1, 5):totable()))
  local target = {}
  local result = {}
  local resultGrad = {}
  local targetVals = training[1]
  local i = 1
  local revI = 5
  for curInput, curGrad in iter:grad(dataset, gradOut) do
    result[i] = curInput[1]
    target[i] = oc.Emission(targetVals[(i - 1)* 2 + 1], targetVals[(i - 1) * 2 + 2])
    resultGrad[revI] = curGrad
    i = i + 1
    revI = revI - 1
  end
  octester:eq(
    target, result,
    'The result does not equal the target'
  )
  octester:eq(
    #result, math.floor(#training[2] / windowSize), 
    'There are too many elements in the result'
  )
  resultGrad.n = #resultGrad
  octester:eq(
    resultGrad, gradOut:totable(),
    'The result grad should be the same as gradOut'
  )
end

function octest.data_iter_base_forward_rev_grad()
  local windowSize = 2
  local iter = oc.data.iter.IndexBatch(false, true, windowSize)
  local dataset = oc.data.set.TestSet(cols, training, testing)
  local gradOut = oc.Emission(table.unpack(torch.range(1, 5):totable()))
  local target = {}
  local result = {}
  local resultGrad = {}
  local targetVals = training[1]
  local i = 5
  local revI = 5
  for curInput, curGrad, index in iter:grad(dataset, gradOut) do
    result[i] = curInput[1]
    target[i] = oc.Emission(targetVals[(i - 1)* 2 + 1], targetVals[(i - 1) * 2 + 2])
    resultGrad[revI] = curGrad
    i = i - 1
    revI = revI - 1
  end
  octester:eq(
    target, result,
    'The result does not equal the target'
  )
  octester:eq(
    #result, math.floor(#training[2] / windowSize), 
    'There are too many elements in the result'
  )
  resultGrad.n = #resultGrad
  octester:eq(
    resultGrad, gradOut:totable(),
    'The result grad should be the same as gradOut'
  )
end

function octest.data_iter_base_rev_rev_grad()
  local windowSize = 2
  local iter = oc.data.iter.IndexBatch(true, true, windowSize)
  local dataset = oc.data.set.TestSet(cols, training, testing)
  local gradOut = oc.Emission(table.unpack(torch.range(1, 5):totable()))
  local target = {}
  local result = {}
  local resultGrad = {}
  local targetVals = training[1]
  local i = 5
  local revI = 1
  for curInput, curGrad in iter:grad(dataset, gradOut) do
    result[i] = curInput[1]
    target[i] = oc.Emission(targetVals[(i - 1)* 2 + 1], targetVals[(i - 1) * 2 + 2])
    resultGrad[revI] = curGrad
    i = i - 1
    revI = revI + 1
  end
  octester:eq(
    target, result,
    'The result does not equal the target'
  )
  octester:eq(
    #result, math.floor(#training[2] / windowSize), 
    'There are too many elements in the result'
  )
  resultGrad.n = #resultGrad
  octester:eq(
    resultGrad, gradOut:totable(),
    'The result grad should be the same as gradOut'
  )
end


-- for curInput, curGradOut in iter:out(dataset, gradOut) do print(curInput[2]:size(), gradOut) end

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
