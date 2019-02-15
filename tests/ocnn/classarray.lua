require 'oc.emission'
require 'oc.var'
require 'ocnn.classarray'
  
function octest.nerve_classarray_output()
  local t = ocnn.ClassArray(2, nn.Linear(2, 2))
	local input1 = torch.randn(2, 2)
	local input2 = torch.zeros(2, 2)
	input2[1]:add(input1[2])
	input2[2]:add(input1[1])
	local vv = oc.Emission(torch.Tensor{1, 2}, input1)
	local vv2 = oc.Emission(torch.Tensor{2, 1}, input2)
  t:relaxStream()
	local output = t:updateOutput(vv)
  t:relaxStream()
	local output2 = t:updateOutput(vv2)
	local output2b = torch.zeros(2, 2)
	output2b[1]:add(output2[2])
	output2b[2]:add(output2[1])
	octester:eq(
		output2b, output,
		'Outputs are not equal'
	)
end

function octest.nerve_classarray_gradInput()
  local t = ocnn.ClassArray(2, nn.Linear(2, 2))
	local input1 = torch.randn(2, 2)
	local input2 = torch.zeros(2, 2)
	input2[1]:add(input1[2])
	input2[2]:add(input1[1])
	local vv = oc.Emission(torch.Tensor{1, 2}, input1)
	local vv2 = oc.Emission(torch.Tensor{2, 1}, input2)
  t:relaxStream()
	local output = t:updateOutput(vv)
	local gradInput = t:updateGradInput(vv, output)
  t:relaxStream()
	local output2 = t:updateOutput(vv2)
	local gradInput2 = t:updateGradInput(vv2, output2)
	local gradInput2b = torch.zeros(2, 2)
	gradInput2b[1]:add(gradInput2[2][2])
	gradInput2b[2]:add(gradInput2[2][1])
	
	octester:eq(
		gradInput2b, gradInput[2],
		'Grad inputs are not equal'
	)
	
end
