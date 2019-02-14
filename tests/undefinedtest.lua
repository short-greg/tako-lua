
do
  require 'oc.init'
  local t = nn.Linear:d(2, oc.arg.t)
  t:updateArgs{t=2}
  local result = t:stimulate(torch.rand(2))
end
