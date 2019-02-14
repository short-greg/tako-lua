require 'oc.flow.merge'
require 'oc.emission'
require 'oc.var'
require 'oc.flow.diverge'
  
function octest.control_diverge_probe()
  local x = nn.Linear(2, 2):lab('x')
  local y = nn.Linear(2,2):lab('y')
  local diverge = oc.flow.Diverge{
  	x,
  	y
  }
  
  local input = oc.Emission(
  	torch.randn(1, 2),
  	torch.randn(1, 2)
  )
  local output = diverge:stimulate(input)
  octester:eq(
    torch.type(output), 'oc.Emission',
    'The output should be an emission'
  )
  octester:eq(
    oc.Emission(x:probe(), y:probe()), output,
    'The output should be equal to an emission of x and y probe'
  )
end

function octest.control_diverge_probeGrad()
  local x = nn.Linear(2, 2):lab('x')
  local y = nn.Linear(2, 2):lab('y')
  local diverge = oc.flow.Diverge{
  	x,
  	y
  }
  local input = oc.Emission(
  	torch.randn(1, 2),
  	torch.randn(1, 2)
  )
  local gradOutput = oc.Emission(
  	torch.randn(1, 2),
  	torch.randn(1, 2)
  )
  
  diverge:inform(input)
  local output = diverge:probe()
  local gradInput = diverge:stimulateGrad(gradOutput)
  octester:eq(
    torch.type(gradInput), torch.type(input),
    'The output should be an emission'
  )
  octester:eq(
    oc.Emission(x:probeGrad(), y:probeGrad()), gradInput,
    'The output should be equal to an emission of x and y probe'
  )
end
