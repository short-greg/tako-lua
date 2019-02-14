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
