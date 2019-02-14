
do
  require 'oc.init'
  
  local stem = oc.Arm:stem(
    nn.Linear:d(2, oc.arg.t) .. nn.Linear:d(oc.arg.t, 4)
  )
  local arm = stem{t=4}
  local result = arm:stimulate(torch.rand(2))
  assert(
    result:size(1) == 4 and
    result:dim() == 1,
    'The result should be of size 4'
  )
end

do
  require 'oc.init'
  
  local stem = oc.Arm:stem(
    oc.arg.t .. nn.Linear:d(2, 4)
  )
  local arm = stem{t=nn.Linear(2, 2)}
  print(arm, arm._modules.root, arm._modules.leaf)
  local result = arm:stimulate(torch.rand(2))
  assert(
    result:size(1) == 4 and
    result:dim() == 1,
    'The result should be of size 4'
  )
end

do
  require 'oc.init'
  local target = 2
  local Subclass = oc.Arm:subclass('',{
    t=target,
    open=function (self)
      return self.t
    end
  })
  local arm = Subclass(nn.Linear(2, 2))
  assert(
    arm:open() == target
  )
end


do
  require 'oc.init'
  local stem = oc.Arm:stem(
    oc.arg.t .. nn.Linear:d(2, 4)
  )
  local arm = stem{t=nn.Linear(2, 2)}
  local result = arm:stimulate(
    torch.randn(2)
  )
  assert(
    result:dim() == 1
  )
end


do
  require 'oc.init'
  local stem = nn.Linear:stem(oc.arg.t, 4)
  local arm = stem{t=2}
  local result = arm:stimulate(
    torch.randn(2)
  )
  assert(
    result:dim() == 1
  )
end
