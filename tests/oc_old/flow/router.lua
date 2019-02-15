require 'torch'
require 'nn'
require 'oc.flow.router'
require 'oc.var'

function octest.flow_routeinput_output()
  local input = torch.rand(2, 2)
  local mod1a = nn.Linear(2, 2):lab('1a')
  local mod1b = nn.Linear(2, 2):lab('1b')
  local mod2a = nn.Linear(2, 2):lab('2a')
  local mod2b = nn.Linear(2, 2):lab('2b')
  local mod = oc.flow.RouteInput{
  	{oc.Var(false), mod1a .. mod1b},
  	{oc.Var(true), mod2a .. mod2b} 
  }
  mod:inform(input)
  local output = mod:probe()
  local mod2bOut = mod2b:probe()
  octester:eq(
    output, mod2bOut,
    'The output of the module does not equal the target'
  )
end

function octest.flow_routeinput_output_with_default()
  local input = torch.rand(2, 2)
  local mod1a = nn.Linear(2, 2):lab('1a')
  local mod1b = nn.Linear(2, 2):lab('1b')
  local mod2a = nn.Linear(2, 2):lab('2a')
  local mod2b = nn.Linear(2, 2):lab('2b')
  local mod3a = nn.Linear(2, 2):lab('3a')
  local mod3b = nn.Linear(2, 2):lab('3b')
  local mod = oc.flow.RouteInput{
  	{oc.Var(false), mod1a .. mod1b},
  	{oc.Var(false), mod2a .. mod2b},
  	default=mod3a .. mod3b
  }
  mod:inform(input)
  local output1 = mod:probe()
  local output = mod3b:probe()
  octester:eq(
    output1, output,
    'The output of the module does not equal the target'
  )
end

function octest.flow_routeinput_gradInput()
  local input = torch.rand(2, 2)
  local mod1a = nn.Linear(2, 2):lab('1a')
  local mod1b = nn.Linear(2, 2):lab('1b')
  local mod2a = nn.Linear(2, 2):lab('2a')
  local mod2b = nn.Linear(2, 2):lab('2b')
  local mod = oc.flow.RouteInput{
  	{oc.Var(false), mod1a .. mod1b},
  	{oc.Var(true), mod2a .. mod2b} 
  }
  mod:inform(input)
  local output = mod:probe()
  mod:informGrad(output)
  local compareGrad = mod:probeGrad()
  local gradInput = mod2a:probeGrad()
  
  octester:eq(
    compareGrad, gradInput,
    'The output of the module does not equal the target'
  )
end


function octest.flow_routeoutput_output()
  local input = torch.rand(2, 2)
  local mod1a = nn.Linear(2, 2):lab('1a')
  local mod1b = nn.Linear(2, 2):lab('1b')
  local mod2a = nn.Linear(2, 2):lab('2a')
  local mod2b = nn.Linear(2, 2):lab('2b')
  local mod = oc.flow.RouteOutput{
  	{mod1a .. mod1b, oc.Var(false)},
  	{mod2a .. mod2b, oc.Var(true)} 
  }
  mod:inform(input)
  local compareOut = mod:probe()
  local output = mod2b:probe()
  octester:eq(
    compareOut, output,
    'The output of the module does not equal the target'
  )
end

function octest.flow_routeoutput_output_with_default()
  local input = torch.rand(2, 2)
  local mod1a = nn.Linear(2, 2):lab('1a')
  local mod1b = nn.Linear(2, 2):lab('1b')
  local mod2a = nn.Linear(2, 2):lab('2a')
  local mod2b = nn.Linear(2, 2):lab('2b')
  local mod3a = nn.Linear(2, 2):lab('3a')
  local mod3b = nn.Linear(2, 2):lab('3b')
  local mod = oc.flow.RouteOutput{
  	{mod1a .. mod1b, oc.Var(false)},
  	{mod2a .. mod2b, oc.Var(false)},
  	default=mod3a .. mod3b
  }
  mod:inform(input)
  mod:probe()
  local compareOutput = mod:updateOutput(input)
  local output = mod3b:probe()
  
  octester:eq(
    compareOutput, output,
    'The output of the module does not equal the target'
  )
end

--[[ Cannot figure out why these do not work.  gradOutput gets
--!  set to some weird value lu-lua.input
--!  need to look into this!!!!
function octest.flow_routeinput_gradInput_with_default()
  local input = torch.rand(2, 2)
  local mod1a = nn.Linear(2, 2):lab('1a')
  local mod1b = nn.Linear(2, 2):lab('1b')
  local mod2a = nn.Linear(2, 2):lab('2a')
  local mod2b = nn.Linear(2, 2):lab('2b')
  local mod3a = nn.Linear(2, 2):lab('3a')
  local mod3b = nn.Linear(2, 2):lab('3b')
  local mod = oc.flow.RouteInput{
  	{oc.Var(false), mod1a .. mod1b},
  	{oc.Var(false), mod2a .. mod2b},
  	default=mod3a .. mod3b
  }
  mod:inform(input)
  local output = mod:probe()
	mod:informGrad(output)
	local compareGradInput = mod:probeGrad()
  local gradInput = mod3a:probeGrad()
  octester:eq(
    compareGradInput, gradInput,
    'The output of the module does not equal the target'
  )
end

function octest.flow_routeoutput_gradInput_with_default()
  local input = torch.rand(2, 2)
  local mod1a = nn.Linear(2, 2):lab('1a')
  local mod1b = nn.Linear(2, 2):lab('1b')
  local mod2a = nn.Linear(2, 2):lab('2a')
  local mod2b = nn.Linear(2, 2):lab('2b')
  local mod3a = nn.Linear(2, 2):lab('3a')
  local mod3b = nn.Linear(2, 2):lab('3b')
  local mod = oc.flow.RouteOutput{
  	{mod1a .. mod1b, oc.Const(false)},
  	{mod2a .. mod2b, oc.Const(false)},
  	default=mod3a .. mod3b
  }
  mod:inform(input)
  local output = mod:probe()
  mod:informGrad(output)
  local compareGradInput = mod:probeGrad()
  local gradInput = mod3a:probeGrad()
  
  octester:eq(
    compareGradInput, gradInput,
    'The output of the module does not equal the target'
  )
end


function octest.flow_routeoutput_gradInput()
  local input = torch.rand(2, 2)
  local mod1a = nn.Linear(2, 2):lab('1a')
  local mod1b = nn.Linear(2, 2):lab('1b')
  local mod2a = nn.Linear(2, 2):lab('2a')
  local mod2b = nn.Linear(2, 2):lab('2b')
  local mod = oc.flow.RouteOutput{
  	{mod1a .. mod1b, oc.Const(false)},
  	{mod2a .. mod2b, oc.Const(true)} 
  }
  mod:inform(input)
  local output = mod:probe()
  mod:informGrad(output)
  local compareGradInput = mod:probeGrad()
  local gradInput = mod2a:probeGrad()
  
  octester:eq(
    compareGradInput, gradInput,
    'The output of the module does not equal the target'
  )
end
--]]
