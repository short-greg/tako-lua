require 'oc.arm'
require 'oc.stem'
require 'ocnn.module'
require 'oc.undefined.init'


function octest.stem_with_linear()
  local stem = oc.Arm:stem(
    nn.Linear:d(2, oc.arg.t) .. nn.Linear:d(oc.arg.t, 4)
  )
  local arm = stem{t=4}
  local result = arm:stimulate(torch.rand(2))
  octester:eq(
    result:size(1), 4,
    'The result should be of size 4'
  )
  octester:eq(
    result:dim(), 1,
    'The result should be of dimension 1'
  )
end


function octest.stem_with_linear_arg()
  local stem = oc.Arm:stem(
    oc.arg.t .. nn.Linear:d(2, 4)
  )
  local arm = stem{t=nn.Linear(2, 2)}
  local result = arm:stimulate(torch.rand(2))

  octester:eq(
    result:size(1), 4,
    'The result should be of size 4'
  )
  octester:eq(
    result:dim(), 1,
    'The result should be of dimension 1'
  )
end


function octest.subclass_with_open_function()
  local target = 2
  local Subclass = oc.Arm:subclass('',{
    t=target,
    open=function (self)
      return self.t
    end
  })
  local arm = Subclass(nn.Linear(2, 2))
  octester:eq(
    arm:open(), target,
    'The open function should return the target.'
  )
end


function octest.linear_stem_with_arg()
  local stem = nn.Linear:stem(oc.arg.t, 4)
  local arm = stem{t=2}
  local result = arm:stimulate(
    torch.randn(2)
  )
  octester:eq(
    result:dim(), 1,
    'The number of dimensions should be one.'
  )
end
