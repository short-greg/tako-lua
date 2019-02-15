require 'oc.my'
require 'oc.arm'
require 'oc.placeholder'


require 'oc.ref'
require 'oc.placeholder'

do
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  local t = {m=2}
  local y = oc.nerve(oc.my)
  y:setOwner(t)
  
  assert(
    y:updateOutput() == t,
    'The output of y should be the owner t'
  )
end


do
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  t = {m=2}
  y = oc.nerve(oc.my.m)
  y:setOwner(t)
  
  assert(
    y:updateOutput() == t.m,
    'The output of y should be the owner t'
  )
end


do
  -- test oc.input
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  local t = {m=2}
  local y = oc.nerve(oc.my.m) .. oc.nerve(oc.input)
  y[1]:setOwner(t)
  y = oc.nerve(y)
  
  assert(
    y:updateOutput() == t.m,
    'The output of y should be the owner t'
  )
end


do
  -- test oc.input
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  local t = {m=2}
  local y = oc.nerve(oc.my) .. oc.nerve(oc.input.m)
  y[1]:setOwner(t)
  y = oc.nerve(y)
  assert(
    y:updateOutput() == t.m,
    'The output of y should be the owner t'
  )
end


do
  -- test oc.input
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  local t = {m=function (input_) return input_ * 2 end}
  local y = oc.nerve(oc.my.m(oc.input))
  y:setOwner(t)
  assert(
    y:updateOutput(2) == 4,
    'The output of y should be the owner t'
  )
end

do
  -- test oc.input
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  
  local t = {m=function (input_) return input_ * 2 end}
  local y = oc.nerve(oc.super.m(oc.input))
  y:setSuper(t)
  assert(
    y:updateOutput(2) == 4,
    'The output of y should be the owner t'
  )
end


do
  -- test oc.input
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  local val1, val2 = 3, 4
  local t = {
    m=function (val1, val2) return val1 * val2 end
  }
  local y = oc.nerve(oc.my.m(oc.input, val2))
  y:setOwner(t)
  assert(
    y:updateOutput(val1) == val1 * val2,
    'The output of y should be the owner t'
  )
end


do
  -- test two function calls
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  local val1 = 3
  local t = {
    m=function () return {
      f=function(val) return val * 2 end
    } end
  }
  local y = oc.nerve(oc.my.m().f(oc.input))
  y:setOwner(t)
  assert(
    y:updateOutput(val1) == val1 * 2,
    'The output of y should be the owner t'
  )
end


do
  -- test retrieve vlaue after function call
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  local val = 3
  local t = {
    m=function () return {
      f=3
    } end
  }
  local y = oc.nerve(oc.my.m().f)
  y:setOwner(t)
  assert(
    y:updateOutput() == 3,
    'The output of y should be the owner t'
  )
end


do
  -- test retrieve vlaue after function call
  require 'oc.init'
  require 'oc.ref'
  require 'oc.placeholder'
  local val = 3
  local t = {
    t=2,
    m=function (self) return self.t end
  }
  local y = oc.nerve(oc.my:m())
  y:setOwner(t)
  assert(
    y:updateOutput() == t.t,
    'The output of y should be the owner t'
  )
end


function octest.nerve_my()
  local owner = {
    nn2=nn.Linear(2, 2),
    _chain=nn.Linear(2, 2) .. oc.My('nn2') .. nn.Linear(2, 2),
    get=
      function (self, val)
        return self.members[val]
      end
  }
  local my = owner._chain[2]
  my:setOwner(owner)
  local chain = owner._chain
  octester:eq(
    torch.pointer(my:getNerve()), torch.pointer(owner.nn2),
    'My was not replaced.'
  )
  octester:eq(
    torch.pointer(owner._chain[2]), torch.pointer(owner.nn2),
    'My was not replaced.'
  )
end

function octest.nerve_my_updateoutput()
  local owner = {
    nn2=nn.Linear(2, 2),
    _chain=nn.Linear(2, 2) .. oc.My('nn2') .. nn.Linear(2, 2),
    get=
      function (self, val)
        return self.members[val]
      end
  }
  local my = owner._chain[2]
  if pcall(owner._chain.updateOutput, torch.randn(2, 2)) then
    error('Should not be able to update output for my.')
  end
end

function octest.nerve_my_updategradInput()
  local owner = {
    nn2=nn.Linear(2, 2),
    _chain=nn.Linear(2, 2) .. oc.My('nn2') .. nn.Linear(2, 2),
    get=
      function (self, val)
        return self.members[val]
      end
  }
  local my = owner._chain[2]
  if pcall(owner._chain.updateGradInput, torch.randn(2, 2), torch.randn(2, 2)) then
    error('Should not be able to update gradInput for my.')
  end
end

function octest.oc_wrap_check_dependenciesRelaxed()
  local x = {
    t=nn.Linear(2, 2),
    g=oc.nerve(oc.wrap.t .. nn.Linear(2, 2))
  }
  x.g[1]:setOwner(x)
  x.g:stimulate(torch.DoubleTensor{2, 2})
  x.t:inform(torch.DoubleTensor{2, 2})
  octester:eq(
    x.g:relaxed(), true,
    'Module should be relaxed'
  )
end

function octest.nerve_mychain()
  local owner = {
    nn2=oc.Arm(nn.Linear(2, 2) .. nn.Linear(2, 2)),
    _chain=nn.Linear(2, 2) .. oc.MyChain('nn2') .. nn.Linear(2, 2),
    get=
      function (self, val)
        return self.members[val]
      end
  }
  local my = owner._chain[2]
  my:setOwner(owner)
  local chain = owner._chain
  octester:eq(
    torch.pointer(owner._chain[2]), torch.pointer(owner.nn2:chain()[1]),
    'My was not replaced.'
  )
  
  octester:eq(
    torch.pointer(owner._chain[3]), torch.pointer(owner.nn2:chain()[2]),
    'My was not replaced.'
  )
end

require 'oc.chain'
require 'oc.wrap'

function octest.nerve_wrap()
  local owner = {
    nn2=nn.Linear(2, 2),
    _chain=nn.Linear(2, 2) .. oc.Wrap('nn2') .. nn.Linear(2, 2),
    get=
      function (self, val)
        return self.members[val]
      end
  }
  local wrap = owner._chain[2]
  wrap:setOwner(owner)
  local chain = owner._chain
  local wrapPost = chain[2]
  octester:eq(
    torch.pointer(wrap), torch.pointer(wrapPost),
    'The pre and post values should be equal.'
  )
  octester:eq(
    torch.pointer(owner._chain[2]:getNerve()), torch.pointer(owner.nn2),
    'Wrap was not replaced.'
  )
  
  owner._chain[1]:inform(torch.randn(2, 2))
  local output = owner._chain[3]:probe()
  octester:eq(
    output:dim(), 2,
    'The output should have a dimensionality of two.'
  )
end

require 'oc.super'

function octest.nerve_super()
  local super = {
    nn2=nn.Linear(2, 2)
  }
  local owner = {
    _chain=nn.Linear(2, 2) .. oc.Super('nn2') .. nn.Linear(2, 2)
  }
  local superNerve = owner._chain[2]
  superNerve:setSuper(super)
  local superPost = super.nn2
  octester:eq(
    torch.isequal(superNerve:getModule(), super.nn2), true,
    'Super nerve\'s module should equal nn2'
  )
end

function octest.nerve_super_updateOutput()
  local super = {
    nn2=nn.Linear(2, 2)
  }
  local owner = {
    _chain=nn.Linear(2, 2) .. oc.Super('nn2') .. nn.Linear(2, 2)
  }
  local superNerve = owner._chain[2]
  superNerve:setSuper(super)
  
  local input_ = torch.rand(2, 2)
  local output = superNerve:updateOutput(input_)
  local output2 = super.nn2:updateOutput(input_)
  
  octester:eq(
    output, output2,
    'The outputs should be equal'
  )
end

function octest.nerve_super_updateGradInput()
  local super = {
    nn2=nn.Linear(2, 2)
  }
  local owner = {
    _chain=nn.Linear(2, 2) .. oc.Super('nn2') .. nn.Linear(2, 2)
  }
  local superNerve = owner._chain[2]
  superNerve:setSuper(super)
  
  local input_ = torch.rand(2, 2)
  local gradOutput_ = torch.rand(2, 2)
  superNerve:stimulate(input_)
  local gradInput = superNerve:updateGradInput(
    input_, gradOutput_
  )
  super.nn2:stimulate(input_)
  local gradInput2 = super.nn2:updateGradInput(
    input_, gradOutput_
  )
  
  octester:eq(
    gradInput, gradInput2,
    'The gradInputs should be equal'
  )
end
