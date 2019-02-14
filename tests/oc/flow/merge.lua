require 'oc.flow.merge'
require 'oc.emission'
require 'oc.var'
  
function octest.control_merge_onto_two_items_probe()
  local x = nn.Linear(2, 2):lab('x')
  local y = nn.Linear(2,2):lab('y')
  x:inform(torch.randn(1, 2))
  y:inform(torch.randn(1, 2))
  local merged = (x..oc.flow.Onto(y)):rhs()
  local output = merged:probe()
  local xOutput = x:probe()
  local yOutput = y:probe()

  octester:assertTensorEq(
    xOutput, output[1],
    'The first emission should be the same as the merged nerve'
  )
  octester:assertTensorEq(
    yOutput, output[2],
    'The first emission should be the same as the merged nerve'
  )
end

function octest.control_merge__ontotwo_items_probeGrad()
  local x = nn.Linear(2, 2):lab('x');
  local y = nn.Linear(2, 2):lab('y');
  local input1 = (oc.Noop() .. x):lhs()
  local input2 = (oc.Noop() .. y):lhs()
  input1:inform(torch.randn(1, 2));
  input2:inform(torch.randn(1, 2));
  local merged = oc.flow.Onto(y);
  x = (x .. merged):lhs()
  local output = merged:probe();
  local xOutput = x:probe()
  local yOutput = y:probe()
  local gradOutput = oc.Emission(
    torch.Tensor{{1.0, 2.0}},
    torch.Tensor{{1.0, 0.5}}
  )
  merged:informGrad(gradOutput)
  local xGrad = x:probeGrad()
  local yGrad = y:probeGrad()
  local mergedGrad = merged:probeGrad()
  octester:eq(
    mergedGrad, torch.Tensor{{1.0, 2.0}},
    'The gradient should be equal to the first item in the emission'
  )
end

function octest.control_merge_prepend_two_items_probe()
  local x = nn.Linear(2, 2):lab('x')
  local y = nn.Linear(2,2):lab('y')
  x:inform(torch.randn(1, 2))
  y:inform(torch.randn(1, 2))
  local merged = (x..oc.flow.Prepend(y)):rhs()
  y:probe()
  local output = merged:probe()
  local xOutput = x:probe()
  local yOutput = y:probe()

  octester:assertTensorEq(
    xOutput, output[2],
    'The first emission should be the same as the merged nerve'
  )
  octester:assertTensorEq(
    yOutput, output[1],
    'The first emission should be the same as the merged nerve'
  )
end

function octest.control_merge__prepend_two_items_probeGrad()
  local x = nn.Linear(2, 2):lab('x');
  local y = nn.Linear(2, 2):lab('y');
  local input1 = (oc.Noop() .. x):lhs()
  local input2 = (oc.Noop() .. y):lhs()
  input1:inform(torch.randn(1, 2));
  input2:inform(torch.randn(1, 2));
  local merged = oc.flow.Prepend(y);
  x = (x .. merged):lhs()
  y:probe()
  local output = merged:probe();
  local xOutput = x:probe()
  local yOutput = y:probe()
  local gradOutput = oc.Emission(
    torch.Tensor{{1.0, 2.0}},
    torch.Tensor{{1.0, 0.5}}
  )
  merged:informGrad(gradOutput)
  local xGrad = x:probeGrad()
  local yGrad = y:probeGrad()
  local mergedGrad = merged:probeGrad()
  octester:eq(
    mergedGrad, torch.Tensor{{1.0, 0.5}},
    'The gradient should be equal to the first item in the emission'
  )
end

function octest.control_merge_append_two_items_probe()
  local x = nn.Linear(2, 2):lab('x')
  local y = nn.Linear(2,2):lab('y')
  x:inform(torch.randn(1, 2))
  y:inform(torch.randn(1, 2))
  local merged = (x..oc.flow.Append(y)):rhs()
  local xOutput = x:probe()
  local yOutput = y:probe()
  local output = merged:probe()

  octester:assertTensorEq(
    xOutput, output[1],
    'The first emission should be the same as the merged nerve'
  )
  octester:assertTensorEq(
    yOutput, output[2],
    'The first emission should be the same as the merged nerve'
  )
end

function octest.control_merge__append_two_items_probeGrad()
  local x = nn.Linear(2, 2):lab('x');
  local y = nn.Linear(2, 2):lab('y');
  local input1 = (oc.Noop() .. x):lhs()
  local input2 = (oc.Noop() .. y):lhs()
  input1:inform(torch.randn(1, 2));
  input2:inform(torch.randn(1, 2));
  local merged = oc.flow.Append(y);
  x = (x .. merged):lhs()
  local yOutput = y:probe()
  local output = merged:probe();
  local xOutput = x:probe()
  local gradOutput = oc.Emission(
    torch.Tensor{{1.0, 2.0}},
    torch.Tensor{{1.0, 0.5}}
  )
  merged:informGrad(gradOutput)
  local xGrad = x:probeGrad()
  local yGrad = y:probeGrad()
  local mergedGrad = merged:probeGrad()
  octester:eq(
    mergedGrad, torch.Tensor{{1.0, 2.0}},
    'The gradient should be equal to the first item in the emission'
  )
end


function octest.control_merge_prepend_two_items_probe_no_yprobe()
  local x = nn.Linear(2, 2):lab('x')
  local y = nn.Linear(2,2):lab('y')
  local target = y.output
  x:inform(torch.randn(1, 2))
  y:inform(torch.randn(1, 2))
  local merged = (x..oc.flow.Prepend(y)):rhs()
  local output = merged:probe()
  local xOutput = x:probe()
  
  octester:eq(
    xOutput, output[2],
    'The first emission should be the same as the merged nerve'
  )
  octester:eq(
    target, output[1],
    'The first emission should be the same as the merged nerve'
  )
end
