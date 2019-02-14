require 'oc.flow.merge'
require 'oc.emission'
require 'oc.var'
require 'oc.flow.multi'
  
function octest.control_multi_probe()
  local x = nn.Linear(2, 2):lab('x')
  local y = nn.Linear(2,2):lab('y')
  local multi = oc.flow.Multi{
  	x,
  	y
  }
  local output = multi:stimulate(torch.randn(1, 2))
  
  octester:eq(
    torch.type(output), 'oc.Emission',
    'The output should be an emission'
  )
  octester:eq(
    oc.Emission(x:probe(), y:probe()), output,
    'The output should be equal to an emission of x and y probe'
  )
end

function octest.control_multi_probeGrad()
  local x = nn.Linear(2, 2):lab('x')
  local y = nn.Linear(2,2):lab('y')
  local multi = oc.flow.Multi{
  	x,
  	y
  }
  local input_ = torch.randn(1, 2)
  local output = multi:stimulate(input_)
  local gradInput = multi:stimulateGrad(output)
  
  octester:eq(
    torch.type(gradInput), torch.type(input_),
    'The output should be an emission'
  )
  octester:eq(
    x:probeGrad() + y:probeGrad(), gradInput,
    'The output should be equal to an emission of x and y probe'
  )
end

