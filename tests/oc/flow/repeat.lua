require 'torch'
require 'nn'
require 'oc.nerve'
require 'oc.flow.repeat'
require 'oc.data.iter'
require 'oc.var'
require 'oc.emission'
require 'oc.math.arithmetic'
require 'oc.flow.merge'
require 'testsupport.testdata'
require 'oc.sub'
require 'oc.arm'
require 'ocnn.criterion'

--[[
local cols = {'input', 'target'}
local training = {
  oc.Emission(table.unpack(torch.range(1, 4):totable())),
  oc.Emission(table.unpack(torch.range(1, 4):totable()))
}

local testing = {
  oc.Emission(table.unpack(torch.range(1, 4):totable())),
  oc.Emission(table.unpack(torch.range(1, 4):totable()))
}--]]

function octest.flow_repeat_output_no_processing()
  local mod = oc.flow.Repeat(
    oc.Var(false)
  )
  octester:eq(
    mod:updateOutput(), nil
  )
end

function octest.flow_repeat_with_processing_nograd()
  --local dataset = oc.data.set.TestSet(cols, training, testing)
  local mod = oc.flow.Repeat(
    nn.Linear(2, 2) .. oc.flow.Onto(oc.Var(false)) .. 
      oc.Sub(2), false
  )
  octester:eq(
    mod:stimulate(torch.rand(2)), nil
  )
end

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
  
  --[[
  local dataset = oc.data.set.TestSet(cols, training, testing)
  local x = oc.Noop() .. oc.flow.Repeat(
    oc.data.iter.IndexBatch(false, false, 1)
  )
  x:inform(dataset)
  local target = oc.Emission(
    oc.Emission(oc.Emission(1), oc.Emission(1)),
    oc.Emission(oc.Emission(2), oc.Emission(2)),
    oc.Emission(oc.Emission(3), oc.Emission(3)),
    oc.Emission(oc.Emission(4), oc.Emission(4))
  )
  local out = x:probe()
  octester:eq(
    out, target,
    'The output and the targets do not equal'
  )--]]
