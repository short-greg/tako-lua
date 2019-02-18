require 'oc.math.arithmetic'
require 'oc.coalesce'

--[[

function octest.math_arithmetic_add_forward()
  local name = 'nn1'
  local input = torch.zeros(1, 2)
  local input2 = torch.ones(1, 2)
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var + var2
  local output = nn1:probe()
  octester:eq(
    output, input + input2,
    'Output of adding operation should be equal to its inputs added together'
  )
end

function octest.math_arithmetic_add_backward()
  local name = 'nn1'
  local input = torch.zeros(1, 2)
  local input2 = torch.ones(1, 2) * 0.5
  local gradOutput = torch.ones(1, 2)
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var + var2
  local output = nn1:probe()
  nn1:informGrad(gradOutput)
  local grad = nn1:probeGrad()
  octester:eq(
    grad[1], gradOutput,
    'Output of adding operation should be equal to its inputs added together'
  )
  octester:eq(
    grad[2], gradOutput,
    'Output of adding operation should be equal to its inputs added together'
  )
end

function octest.math_arithmetic_sub_forward()
  local name = 'nn1'
  local input = torch.zeros(1, 2)
  local input2 = torch.ones(1, 2)
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var - var2
  local output = nn1:probe()
  octester:eq(
    output, input - input2,
    'Output of subraction operation should be equal to its inputs subtracted'
  )
end

function octest.math_arithmetic_sub_backward()
  local name = 'nn1'
  local input = torch.zeros(1, 2)
  local input2 = torch.ones(1, 2) * 0.5
  local gradOutput = torch.ones(1, 2)
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var - var2
  local output = nn1:probe()
  nn1:informGrad(gradOutput)
  local grad = nn1:probeGrad()
  octester:eq(
    grad[1], gradOutput,
    'GradInput of subtraction operation should be equal to its gradOutput'
  )
  octester:eq(
    grad[2], -gradOutput,
    'GradInput of subtaction should be equal to the negative of its gradOutput'
  )
end

function octest.math_arithmetic_mul_forward()
  local name = 'nn1'
  local input = torch.zeros(1, 2)
  local input2 = torch.ones(1, 2)
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var * var2
  local output = nn1:probe()
  octester:eq(
    output, torch.cmul(input, input2),
    'Output of subraction operation should be equal to its inputs subtracted'
  )
end

function octest.math_arithmetic_mul_backward()
  local name = 'nn1'
  local input = torch.zeros(1, 2)
  local input2 = torch.ones(1, 2) * 0.5
  local gradOutput = torch.ones(1, 2)
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var * var2
  local output = nn1:probe()
  nn1:informGrad(gradOutput)
  local grad = nn1:probeGrad()
  octester:eq(
    grad, torch.cmul(input2, gradOutput),
    'GradInput of multiplication operation should be equal rhs*gradOutput'
  )
  octester:eq(
    var2:probeGrad(), torch.cmul(input, gradOutput),
    'GradInput of multiplication should be equal to lhs*gradOutput'
  )
end

function octest.math_arithmetic_div_forward()
  local name = 'nn1'
  local input = torch.zeros(1, 2)
  local input2 = torch.ones(1, 2)
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var / var2
  local output = nn1:probe()
  octester:eq(
    output, torch.cmul(input, input2),
    'Output of subraction operation should be equal to its inputs subtracted'
  )
end

function octest.math_arithmetic_div_backward()
  local name = 'nn1'
  local input = torch.ones(1, 2) * 0.25
  local input2 = torch.ones(1, 2) * 0.5
  local gradOutput = torch.ones(1, 2)
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var / var2
  local output = nn1:probe()
  nn1:informGrad(gradOutput)
  local grad = nn1:probeGrad()
  octester:eq(
    grad, torch.cmul(gradOutput, torch.pow(input2, -1)),
    'GradInput of division is incorrect'
  )
  octester:eq(
    var2:probeGrad(), torch.cdiv(torch.log(torch.cmul(input2, input)), gradOutput),
    'GradInput of division is incorrect'
  )
end

function octest.math_arithmetic_add_two_streams_forward()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name)
  local nn2 = (nn1 .. nn.Linear(2, 2):lab('nn2')):rhs()
  local nn3 = (nn1 .. nn.Linear(2, 2):lab('nn4')):rhs()
  local input = torch.zeros(1, 2)
  local nn4 = nn2 + nn3
  local var = oc.Var(input)
  nn1 = (var .. nn1):rhs()
  local output = nn4:probe()
  octester:eq(
    output, nn3:probe() + nn2:probe(),
    'Output of adding operation should be equal to its inputs added together'
  )
end

function octest.math_arithmetic_add_two_streams_backward()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name)
  local nn2 = (nn1 .. nn.Linear(2, 2):lab('nn2')):rhs()
  local nn3 = (nn1 .. nn.Linear(2, 2):lab('nn4')):rhs()
  local input = torch.zeros(1, 2)
  local var = oc.Var(input)
  nn1 = (var .. nn1):rhs()
  local gradOutput = torch.randn(1, 2)
  local nn4 = nn2 + nn3
  local output = nn4:probe()
  nn4:informGrad(gradOutput)
  octester:eq(
    nn1:probeGrad():size(), input:size(),
    'GradInput of adding operation should be equal '
  )
end

function octest.math_arithmetic_subtract_two_streams_forward()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name)
  local nn2 = (nn1 .. nn.Linear(2, 2):lab('nn2')):rhs()
  local nn3 = (nn1 .. nn.Linear(2, 2):lab('nn4')):rhs()
  local input = torch.zeros(1, 2)
  local nn4 = nn2 - nn3
  local input = torch.ones(1, 2)
  
  local var = oc.Var(input)
  nn1 = (var .. nn1):rhs()
  local output = nn4:probe()
  octester:eq(
    output, nn2:probe() - nn3:probe(),
    'Output of adding operation should be equal to its inputs added together'
  )
end

function octest.math_arithmetic_sub_two_streams_backward()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name)
  local nn2 = (nn1 .. nn.Linear(2, 2):lab('nn2')):rhs()
  local nn3 = (nn1 .. nn.Linear(2, 2):lab('nn4')):rhs()
  local input = torch.zeros(1, 2)
  local var = oc.Var(input)
  nn1 = (var .. nn1):rhs()
  local gradOutput = torch.randn(1, 2)
  local nn4 = nn2 - nn3
  local output = nn4:probe()
  nn4:informGrad(gradOutput)
  octester:eq(
    nn1:probeGrad():size(), input:size(),
    'GradInput of adding operation should be equal '
  )
end

function octest.math_arithmetic_multiply_two_streams_forward()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name)
  local nn2 = (nn1 .. nn.Linear(2, 2):lab('nn2')):rhs()
  local nn3 = (nn1 .. nn.Linear(2, 2):lab('nn4')):rhs()
  local input = torch.zeros(1, 2)
  local nn4 = nn2 * nn3
  local input = torch.ones(1, 2)
  local var = oc.Var(input)
  nn1 = (var .. nn1):rhs()
  local output = nn4:probe()
  octester:eq(
    output, torch.cmul(nn3:probe(), nn2:probe()),
    'Output of adding operation should be equal to its inputs added together'
  )
end

function octest.math_arithmetic_multiply_two_streams_backward()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name)
  local nn2 = (nn1 .. nn.Linear(2, 2):lab('nn2')):rhs()
  local nn3 = (nn1 .. nn.Linear(2, 2):lab('nn4')):rhs()
  local input = torch.zeros(1, 2)
  local var = oc.Var(input)
  nn1 = (var .. nn1):rhs()
  local gradOutput = torch.randn(1, 2)
  local nn4 = nn2 * nn3
  local output = nn4:probe()
  nn4:informGrad(gradOutput)
  octester:eq(
    nn1:probeGrad():size(), input:size(),
    'GradInput of adding operation should be equal '
  )
end

function octest.math_arithmetic_divide_two_streams_forward()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name)
  local nn2 = (nn1 .. nn.Linear(2, 2):lab('nn2')):rhs()
  local nn3 = (nn1 .. nn.Linear(2, 2):lab('nn4')):rhs()
  local nn4 = nn2 / nn3
  local input = torch.ones(1, 2)
  local var = oc.Var(input)
  nn1 = (var .. nn1):rhs()
  local output = nn4:probe()
  octester:eq(
    output, torch.cdiv(nn2:probe(), nn3:probe()),
    'Output of dividing operation should be equal to its inputs added together'
  )
end

function octest.math_arithmetic_divide_two_streams_backward()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name)
  local nn2 = (nn1 .. nn.Linear(2, 2):lab('nn2')):rhs()
  local nn3 = (nn1 .. nn.Linear(2, 2):lab('nn4')):rhs()
  local input = torch.zeros(1, 2)
  local var = oc.Var(input)
  nn1 = (var .. nn1):rhs()
  local gradOutput = torch.randn(1, 2)
  local nn4 = nn2 / nn3
  local output = nn4:probe()
  nn4:informGrad(gradOutput)
  octester:eq(
    nn1:probeGrad():size(), input:size(),
    'GradInput of adding operation should be equal '
  )
end
--]]
