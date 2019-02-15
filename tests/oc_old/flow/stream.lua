require 'torch'
require 'nn'
require 'oc.nerve'
require 'ocnn.module'
require 'oc.flow.stream'
require 'oc.data.iter'
require 'oc.flow.repeat'
require 'data.mnist'
require 'oc.data.set'
require 'oc.flow.stream'
require 'trans.type'
require 'oc.ops.ops'

--[[
function octest.flow_repeat_output_with_processing_grad()
  --local dataset = oc.data.set.TestSet(cols, training, testing)
  local toRepeat = oc.flow.Multi{
    nn.Linear(2, 2),
    nn.Linear(2, 2):gradOff()
  } .. ocnn.Criterion(nn.MSECriterion())

  local mod = oc.flow.Repeat(
    toRepeat .. oc.flow.Onto(oc.Var(false)) .. 
      oc.Sub(2), true
  )
  octester:eq(
    mod:stimulate(torch.rand(2)), nil
  )

end
--]]

function octest.flow_stream_out_nostore()
  local lin = nn.Linear(2, 2)
  local lin2 = lin:clone()
  local data = torch.randn(3, 2)
  local dataset = oc.data.set.BatchTensor(data)
  local stream = oc.data.iter.IndexBatch(false, true, 1) ..
    oc.flow.Stream(
      lin,
      false
    )
  local output = stream:stimulate(dataset)
  local outputs2 = {}
  for i=1, #dataset do
    local curData = data[i]:view(1, 2)
    table.insert(outputs2, oc.ops.clone(lin2:forward(curData)))
  end
  
  octester:eq(
    outputs2[2], output[2],
    'Outputs are not equal'
  )
  octester:eq(
    outputs2[1], output[1],
    'Outputs are not equal'
  )
  octester:eq(
    outputs2[3], output[3],
    'Outputs are not equal'
  )
end

function octest.flow_stream_grad_nostore()
  local lin = nn.Linear(2, 2)
  local lin2 = lin:clone()
  local data = torch.randn(3, 2)
  local gradOut = {}
  for i=1, data:size(1) do
    table.insert(gradOut, torch.rand(1, 2))
  end
  local dataset = oc.data.set.BatchTensor(data)
  local stream = oc.data.iter.IndexBatch(false, true, 1) ..
    oc.flow.Stream(
      lin,
      false
    )
  local output = stream:stimulate(dataset)
  local gradInput = stream:stimulateGrad(gradOut)
  local gradInputs = {}
  local outputs2 = {}
  for i=1, #dataset do
    local curData = data[i]:view(1, 2)
    table.insert(outputs2, oc.ops.clone(
        lin2:forward(curData))
    )
    table.insert(gradInputs, oc.ops.clone(
        lin2:backward(curData, gradOut[i]))
    )
  end
  octester:eq(
    gradInputs[2], gradInput[2]:view(1, 2),
    'Outputs are not equal'
  )
  octester:eq(
    gradInputs[1], gradInput[1]:view(1, 2),
    'Outputs are not equal'
  )
  octester:eq(
    gradInputs[3], gradInput[3]:view(1, 2),
    'Outputs are not equal'
  )
  
end

function octest.flow_stream_acc_nostore()
  local lin = nn.Linear(2, 2)
  local lin2 = lin:clone()
  local data = torch.randn(3, 2)
  local gradOut = {}
  for i=1, data:size(1) do
    table.insert(gradOut, torch.rand(1, 2))
  end
  local dataset = oc.data.set.BatchTensor(data)
  local stream = oc.data.iter.IndexBatch(false, true, 1) ..
    oc.flow.Stream(
      lin,
      false
    )
  local output = stream:stimulate(dataset)
  local gradInput = stream:stimulateGrad(gradOut)
  stream:accumulate()
  local gradInputs = {}
  local outputs2 = {}
  for i=1, #dataset do
    local curData = data[i]:view(1, 2)
    table.insert(outputs2, oc.ops.clone(
        lin2:forward(curData))
    )
    table.insert(gradInputs, oc.ops.clone(
        lin2:backward(curData, gradOut[i]))
    )
  end
  octester:eq(
    lin2.weight, lin.weight,
    'Outputs are not equal'
  )
  
end

function octest.flow_stream_out_store()
  local lin = nn.Linear(2, 2)
  local lin2 = lin:clone()
  local data = torch.randn(3, 2)
  local dataset = oc.data.set.BatchTensor(data)
  local stream = oc.data.iter.IndexBatch(false, true, 1) ..
    oc.flow.Stream(
      lin,
      true
    )
  local output = stream:stimulate(dataset)
  local outputs2 = {}
  for i=1, #dataset do
    local curData = data[i]:view(1, 2)
    table.insert(outputs2, oc.ops.clone(lin2:forward(curData)))
  end
  
  octester:eq(
    outputs2[2], output[2],
    'Outputs are not equal'
  )
  octester:eq(
    outputs2[1], output[1],
    'Outputs are not equal'
  )
  octester:eq(
    outputs2[3], output[3],
    'Outputs are not equal'
  )
  
end

function octest.flow_stream_grad_store()
  local lin = nn.Linear(2, 2)
  local lin2 = lin:clone()
  local data = torch.randn(3, 2)
  local gradOut = {}
  for i=1, data:size(1) do
    table.insert(gradOut, torch.rand(1, 2))
  end
  local dataset = oc.data.set.BatchTensor(data)
  local stream = oc.data.iter.IndexBatch(false, true, 1) ..
    oc.flow.Stream(
      lin,
      true
    )
  local output = stream:stimulate(dataset)
  local gradInput = stream:stimulateGrad(gradOut)
  local gradInputs = {}
  local outputs2 = {}
  for i=1, #dataset do
    local curData = data[i]:view(1, 2)
    table.insert(outputs2, oc.ops.clone(
        lin2:forward(curData))
    )
    table.insert(gradInputs, oc.ops.clone(
        lin2:backward(curData, gradOut[i]))
    )
  end
  octester:eq(
    gradInputs[2], gradInput[2]:view(1, 2),
    'Outputs are not equal'
  )
  octester:eq(
    gradInputs[1], gradInput[1]:view(1, 2),
    'Outputs are not equal'
  )
  octester:eq(
    gradInputs[3], gradInput[3]:view(1, 2),
    'Outputs are not equal'
  )
end

function octest.flow_stream_acc_store()
    local lin = nn.Linear(2, 2)
  local lin2 = lin:clone()
  local data = torch.randn(3, 2)
  local gradOut = {}
  for i=1, data:size(1) do
    table.insert(gradOut, torch.rand(1, 2))
  end
  local dataset = oc.data.set.BatchTensor(data)
  local stream = oc.data.iter.IndexBatch(false, true, 1) ..
    oc.flow.Stream(
      lin,
      true
    )
  local output = stream:stimulate(dataset)
  local gradInput = stream:stimulateGrad(gradOut)
  stream:accumulate()
  local gradInputs = {}
  local outputs2 = {}
  for i=1, #dataset do
    local curData = data[i]:view(1, 2)
    table.insert(outputs2, oc.ops.clone(
        lin2:forward(curData))
    )
    table.insert(gradInputs, oc.ops.clone(
        lin2:backward(curData, gradOut[i]))
    )
  end
  octester:eq(
    lin2.weight, lin.weight,
    'Outputs are not equal'
  )
end

function octest.flow_stream_no_module()
  local data = torch.randn(3, 2)
  local dataset = oc.data.set.BatchTensor(data)
  local stream = oc.data.iter.IndexBatch(false, true, 1) ..
    oc.flow.Stream(
      lin,
      false
    )
  local output = stream:stimulate(dataset)
  octester:eq(
    data[2]:view(1, 2), output[2],
    'Outputs are not equal'
  )
  octester:eq(
    data[1]:view(1, 2), output[1],
    'Outputs are not equal'
  )
  octester:eq(
    data[3]:view(1, 2), output[3],
    'Outputs are not equal'
  )
end
