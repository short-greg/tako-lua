require 'torch'
require 'nn'
require 'oc.flow.gate'
require 'oc.var'

function octest.flow_gate_output()
  local x = oc.Var(2)
  local y = oc.Var(2)
  local input = torch.rand(2, 2)
  local modOut = nn.Linear(2, 2):lab('out')
  local mod = oc.flow.Gate(
  	x:eq(y),
  	nn.Linear(2, 2) .. modOut
  )
  
  octester:eq(
    mod:updateOutput(input), modOut:probe(),
    'The output of the module does not equal the target'
  )
end

function octest.flow_gate_output_with_locked()
  local x = oc.Var(2)
  local y = oc.Var(3)
  local input = torch.rand(2, 2)
  local modOut = nn.Linear(2, 2):lab('out')
  local mod = oc.flow.Gate(
  	x:eq(y),
  	nn.Linear(2, 2) .. modOut
  )
  
  octester:eq(
    mod:updateOutput(input), nil,
    'The output of the module does not equal the target'
  )
end

function octest.flow_gate_gradInput()
  local x = oc.Var(2)
  local y = oc.Var(2)
  local input = torch.rand(2, 2)
  local modOut = nn.Linear(2, 2):lab('out')
  local modIn = nn.Linear(2, 2):lab('in')
  local mod = oc.flow.Gate(
  	x:eq(y),
  	modIn .. modOut
  )
  local output = mod:updateOutput(input)
  
  octester:eq(
    mod:updateGradInput(input, output), modIn:probeGrad(),
    'The output of the module does not equal the target'
  )
end
