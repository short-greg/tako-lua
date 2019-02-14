require 'oc.my'
require 'oc.arm'
require 'oc.placeholder'

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

