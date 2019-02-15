require 'oc.mama'

function octest.nerve_reverse()
  local mod = nn.Linear(2, 4)
  local rev = oc.Reverse(mod)
  rev:setOwner()
  local result = rev:replace()
  
  octester:eq(
    result.weight:t():size(), mod.weight:size(),
    'The reversed module outputs and input sizes should equal the originals input and outputs size respectively.'
  )
end

function octest.nerve_reverse_with_placeholder()
  local mod = nn.Linear(2, 4)
  local rev = oc.Reverse(oc.ref.my.v)
  local owner = {v=mod}
  rev:setOwner(owner)
  local result = rev:replace()
  octester:eq(
    result.weight:t():size(), mod.weight:size(),
    'The reversed module outputs and input sizes should equal the originals input and outputs size respectively.'
  )
end


function octest.nerve_mama_with_value_for_out()
  local mod = nn.Linear:mama(2)
  mod:inform(torch.randn(1, 4))
  mod:probe()
  local returned = mod:replace()
  assert(
    torch.type(returned) == 'nn.Linear',
    'Type of module must be linear'
  )
  assert(
    returned.weight:size(1), 2,
    'Number of outputs must be 2.'
  )
  assert(
    returned.weight:size(2), 4,
    'Number of inputs must be 1'
  )
end

function octest.nerve_mama_with_placeholder()
  local owner = {
    out=2
  }
  local mod = nn.Linear:mama(oc.ref.my.out)
  mod:setOwner(owner)
  mod:inform(torch.randn(1, 4))
  mod:probe()
  local returned = mod:replace()
  assert(
    torch.type(returned) == 'nn.Linear',
    'Type of module must be linear'
  )
  assert(
    returned.weight:size(1), 2,
    'Number of outputs must be 2.'
  )
  assert(
    returned.weight:size(2), 4,
    'Number of inputs must be 1'
  )
end
