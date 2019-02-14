require 'oc.placeholder'

function octest.oc_placeholder_input()
  local inp = oc.ref.input.x
  local result = oc.ops.placeholder.eval(inp, nil, {x=1})
  octester:eq(
    result, 1,
    'Input should be equal to 1'
  )
end

function octest.oc_placeholder_input_with_three_levels()
  local inp = oc.ref.input.x.y.z
  local result = oc.ops.placeholder.eval(inp, nil, {x={y={z=1}}})
  octester:eq(
    result, 1,
    'Input should be equal to 1'
  )
end

function octest.oc_placeholder_my()
  local owner = {x=1}
  local my = oc.ref.my.x
  octester:eq(
    oc.ops.placeholder.eval(my, owner, nil), 1,
    'Input should be equal to 1'
  )
end

function octest.oc_placeholder_input_func()
  local inp = oc.ref.input.x(1)
  local tako = {x = function (y) return y + 1 end}
  local result = oc.ops.placeholder.eval(inp, nil, tako)
  octester:eq(
    result, 2,
    'Input should be equal to 2'
  )
end

function octest.oc_placeholder_mod()
  local inp = oc.ref.input.x(1)
  local mod = oc.ops.placeholder.mod(inp)
  
  octester:eq(
    torch.isTypeOf(mod, 'oc.ArgProcessor'), true,
    'Module should be an arg processor'
  )
end

function octest.oc_placeholder_nest()
  local inp = oc.ref.input.x(oc.ref.input.y)
  local result = oc.ops.placeholder.eval(
    inp, nil, {
        x=function (val) return val end,
        y=2
      }
  )
  
  octester:eq(
    result, 2,
    'Input should be equal to 2'
  )
end

function octest.oc_placeholder_eval()
  local owner = {j=2}
  local inp = oc.ref.my.j
  local mod = oc.ops.placeholder.mod(inp)
  local chain = mod .. oc.Noop()
  mod:setOwner(owner)
  
  local result = chain:probe()
  octester:eq(
    result, owner.j,
    'The result should equal the emmber j'
  )
end

function octest.oc_placeholder_eval_with_func()
  local owner = {j=2}
  local addTogether = function (val1, val2)
    return val1 + val2
  end
  local inp = oc.ref.input(oc.ref.my.j, 2)
  local mod = oc.ops.placeholder.mod(inp)
  local chain = mod .. oc.Noop()
  mod:setOwner(owner)
  
  chain:inform(addTogether)
  local result = chain:probe()
  octester:eq(
    result, owner.j + 2,
    'The result should equal the member j + 2'
  )
end

function octest.oc_declaration_module()
  local declared = nn.Linear:d(2, 2)
  local defined = declared:genNerve()
  
  octester:eq(
    torch.type(declared), oc.Declaration.__typename,
    'The module should be a declaration'
  )
  octester:eq(
    torch.type(defined), nn.Linear.__typename,
    'The module should be a linear'
  )
  
  octester:eq(
    defined.weight:size(1), 2,
    'The module\'s size is not correct'
  )
  octester:eq(
    defined.weight:size(2), 2,
    'The module\'s size is not correct'
  )
end

function octest.oc_declaration_updateOutput()
  local declared = nn.Linear:d(2, 2)
  
  if pcall(declared.updateOutput, declared) then
    error('Should not be able to update output.')
  end
end

function octest.oc_declaration_updateGradInput()
  local declared = nn.Linear:d(2, 2)
  
  if pcall(declared.updateGradInput, declared) then
    error('Should not be able to update output.')
  end
end

function octest.oc_declaration_accGradParameters()
  local declared = nn.Linear:d(2, 2)
  
  if pcall(declared.accGradParameters, declared) then
    error('Should not be able to update output.')
  end
end


function octest.oc_placeholder_nerve_reference_wrap()
  local ref = oc.wrap.x
  
  octester:eq(
    torch.type(ref), 'oc.NerveReference',
    'Type should be nerve reference'
  )
end

function octest.oc_placeholder_nerve_reference_my()
  local ref = oc.my.x
  
  octester:eq(
    torch.type(ref), 'oc.NerveReference',
    'Type should be nerve reference'
  )
end

function octest.oc_placeholder_nerve_reference_mychain()
  local ref = oc.mychain.x
  
  octester:eq(
    torch.type(ref), 'oc.NerveReference',
    'Type should be nerve reference'
  )
end

function octest.oc_placeholder_nerve_reference_super()
  local ref = oc.super.x
  
  octester:eq(
    torch.type(ref), 'oc.NerveReference',
    'Type should be nerve reference'
  )
end

function octest.oc_placeholder_nerve_reference_wrap_concat()
  local chain = oc.wrap.x .. oc.Noop()
  octester:eq(
    torch.type(chain[1]), 'oc.Wrap',
    'Type should be a wrap module'
  )
end

function octest.oc_placeholder_nerve_reference_my_init_concat()
  local chain = oc.my.x .. oc.Noop()
  octester:eq(
    torch.type(chain[1]), 'oc.My',
    'Type should be a My module'
  )
end

function octest.oc_placeholder_nerve_reference_mychain_concat()
  local chain = oc.mychain.x .. oc.Noop()
  
  octester:eq(
    torch.type(chain[1]), 'oc.MyChain',
    'Type should be a MyChain Module'
  )
end

function octest.oc_placeholder_nerve_reference_super_concat()
  local chain = oc.super.x .. oc.Noop()
  
  octester:eq(
    torch.type(chain[1]), 'oc.Super',
    'Type should be a Super module'
  )
end
