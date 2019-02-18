require 'oc.nerve'
require 'oc.undefined.init'
require 'ocnn.module'


function octest.test_arg_with_linear()
  local t = nn.Linear:d(2, oc.arg.t)
  t:updateArgs{t=2}
  local result = t:stimulate(torch.rand(2))
end
