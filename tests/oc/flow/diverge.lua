require 'oc.flow.merge'
require 'ocnn.module'
require 'oc.flow.diverge'


function octest.control_diverge_probe()
  local x = nn.Linear(2, 2):label('x')
  local y = nn.Linear(2,2):label('y')
  local diverge = oc.Diverge{
  	x,
  	y
  }
  
  local input = {
  	torch.randn(1, 2),
  	torch.randn(1, 2)
  }
  local output = diverge:stimulate(input)
  octester:eq(
    oc.type(output), 'table',
    'The output should be an emission'
  )
  octester:eq(
    {x:probe(), y:probe()}, output,
    'The output should be equal to an emission of x and y probe'
  )
end

function octest.control_diverge_probeGrad()
  local x = nn.Linear(2, 2):label('x')
  local y = nn.Linear(2, 2):label('y')
  local diverge = oc.Diverge{
  	x,
  	y
  }
  local input = {
  	torch.randn(1, 2),
  	torch.randn(1, 2)
  }
  local gradOutput = {
  	torch.randn(1, 2),
  	torch.randn(1, 2)
  }
  
  diverge:inform(input)
  local output = diverge:probe()
  local gradInput = diverge:stimulateGrad(gradOutput)
  octester:eq(
    oc.type(gradInput), oc.type(input),
    'The output should be an emission'
  )
  octester:eq(
    {x:probeGrad(), y:probeGrad()}, gradInput,
    'The output should be equal to an emission of x and y probe'
  )
end
