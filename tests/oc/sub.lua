require 'oc.emission'
require 'oc.var'
require 'oc.sub'
  
function octest.nerve_sub_with_one_probe_second()
  local input = oc.Emission(
  	torch.randn(2, 2),
  	torch.randn(2, 2),
  	torch.randn(2, 2)
  )
  local net = oc.Noop()
  net:inform(input)
  local net2 = oc.Noop()
  local _ = net[{2}] .. net2
  
  octester:eq(
    net2:probe(), input[2],
    'Net2 should equal the second input'
  )
end

function octest.nerve_sub_with_two_probe_second()
  local input = oc.Emission(
  	torch.randn(2, 2),
  	torch.randn(2, 2),
  	torch.randn(2, 2)
  )
  local net = oc.Noop()
  net:inform(input)
  local net2 = oc.Noop()
  local _ = net[{3, 2}] .. net2
  
  octester:eq(
    net2:probe(), oc.Emission(input[3], input[2]),
    'Net2 should equal the second input'
  )
end

function octest.nerve_sub_with_one_probeGrad_second()
  local input = oc.Emission(
  	torch.randn(2, 2),
  	torch.randn(2, 2),
  	torch.randn(2, 2)
  )
  local gradOutput = torch.randn(2, 2)
  
  local net = oc.Noop()
  net:inform(input)
  local net2 = oc.Noop()
  local _ = net[{2}] .. net2
  net2:probe()
  net2:informGrad(gradOutput)
  octester:eq(
    net:probeGrad(), oc.Emission(nil, gradOutput),
    'Net grad should equal'
  )
end

function octest.nerve_sub_with_two_probeGrad_second()
  local input = oc.Emission(
  	torch.randn(2, 2),
  	torch.randn(2, 2),
  	torch.randn(2, 2)
  )
  local gradOutput = oc.Emission(
  	torch.randn(2, 2),
  	torch.randn(2, 2)
  )
  local net = oc.Noop()
  net:inform(input)
  local net2 = oc.Noop()
  local _ = net[{3, 2}] .. net2
  net2:probe()
  net2:informGrad(gradOutput)
  
  octester:eq(
    net:probeGrad(), oc.Emission(nil, gradOutput[2], gradOutput[1]),
    'Net grad should equal'
  )
end