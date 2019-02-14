require 'torch'
require 'nn'
require 'oc.flow.loop'
require 'oc.var'

function octest.flow_loop_output()
  local x = oc.Var(2)
  local y = oc.Var(2)
  local input = torch.rand(2, 2)
  local mod1 = nn.Linear(2, 2):lab('1')
  local mod2 = nn.Linear(2, 2):lab('2')
  local loop = oc.flow.Loop(
  	mod1 .. mod2,
  	torch.randn(2, 2),
  	mod1
  )
  loop:inform(input)
  octester:eq(
    loop:probe(), mod1:probe(),
    'The output of the module does not equal the target'
  )
end

function octest.flow_loop_output_no_out()
  local x = oc.Var(2)
  local y = oc.Var(2)
  local input = torch.rand(2, 2)
  local mod1 = nn.Linear(2, 2):lab('1')
  local mod2 = nn.Linear(2, 2):lab('2')
  local loop = oc.flow.Loop(
  	mod1 .. mod2,
  	torch.randn(2, 2)
  )
  loop:inform(input)
  octester:eq(
    loop:probe(), nil,
    'The output of the module does not equal the target'
  )
end

function octest.flow_loop_gradInput()
  local x = oc.Var(2)
  local y = oc.Var(2)
  local input = torch.rand(2, 2)
  local mod1 = nn.Linear(2, 2):lab('1')
  local mod2 = nn.Linear(2, 2):lab('2')
  local loop = oc.flow.Loop(
  	mod1 .. mod2,
  	torch.randn(2, 2),
  	mod1
  )
  loop:inform(input)
  local output = loop:probe()
  loop:informGrad(output)
  loop:probeGrad()
  octester:eq(
    loop:probeGrad(), nil,
    'The gradInput of the module should be nil'
  )
  
  octester:ne(
    mod1:probeGrad(), nil,
    'The gradInput of the module should be nil'
  )
end


