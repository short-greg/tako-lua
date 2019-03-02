require 'oc.arm'
require 'oc.placeholder'
require 'oc.ref'
require 'oc.noop'
require 'oc.oc'


function octest.ref_my_update_output()
  local t = {m=2}
  local y = oc.nerve(oc.my)
  y:setOwner(t)
  
  octester:eq(
    y:updateOutput(), t,
    'The output of y should be the owner t'
  )
end


function octest.ref_my_update_output_with_indexing()
  t = {m=2}
  y = oc.nerve(oc.my.m)
  y:setOwner(t)
  
  octester:eq(
    y:updateOutput(), t.m,
    'The output of y should be value m of t'
  )
end


function octest.ref_my_update_output_with_concat()
  local t = {m=2}
  local y = oc.nerve(oc.my.m) .. oc.nerve(oc.input)
  y[1]:setOwner(t)
  y = oc.nerve(y)
  
  octester:eq(
    y:updateOutput(), t.m,
    'The output of y should be the owner t'
  )
end


function octest.ref_input_update_output_with_concat()
  local t = {m=2}
  local y = oc.nerve(oc.my) .. oc.nerve(oc.input.m)
  y[1]:setOwner(t)
  y = oc.nerve(y)
  octester:eq(
    y:updateOutput(), t.m,
    'The output of y should be the owner t'
  )
end


function octest.ref_call_my_with_input()
  local t = {m=function (input_) return input_ * 2 end}
  local y = oc.nerve(oc.my.m(oc.input))
  y:setOwner(t)
  octester:eq(
    y:updateOutput(2), 4,
    'The output of y should be the owner t'
  )
end

function octest.ref_call_super_function_with_input()
  local t = {m=function (input_) return input_ * 2 end}
  local y = oc.nerve(oc.super.m(oc.input))
  y:setSuper(t)
  octester:eq(
    y:updateOutput(2), 4,
    'The output of y should be the owner t'
  )
end


function octest.ref_call_my_function_with_two_inputs()
  local val1, val2 = 3, 4
  local t = {
    m=function (val1, val2) return val1 * val2 end
  }
  local y = oc.nerve(oc.my.m(oc.input, val2))
  y:setOwner(t)
  octester:eq(
    y:updateOutput(val1), val1 * val2,
    'The output of y should be the owner t'
  )
end


function octest.ref_call_nested_function_with_input()
  local val1 = 3
  local t = {
    m=function () return {
      f=function(val) return val * 2 end
    } end
  }
  local y = oc.nerve(oc.my.m().f(oc.input))
  y:setOwner(t)
  octester:eq(
    y:updateOutput(val1), val1 * 2,
    'The output of y should be the owner t'
  )
end


function octest.ref_test_member_after_call()
  -- test retrieve value after function call
  local val = 3
  local t = {
    m=function () return {
      f=3
    } end
  }
  local y = oc.nerve(oc.my.m().f)
  y:setOwner(t)
  octester:eq(
    y:updateOutput(), 3,
    'The output of y should be the owner t'
  )
end


function octest.ref_test_self_call()
  local val = 3
  local t = {
    t=2,
    m=function (self) return self.t end
  }
  local y = oc.nerve(oc.my:m())
  y:setOwner(t)
  octester:eq(
    y:updateOutput(), t.t,
    'The output of y should be the owner t'
  )
end

--[[
function octest.nerve_my()
  local owner = {
    nn2=nn.Linear(2, 2),
    _strand=nn.Linear(2, 2) .. oc.My('nn2') .. nn.Linear(2, 2),
    get=
      function (self, val)
        return self.members[val]
      end
  }
  local my = owner._strand[2]
  my:setOwner(owner)
  local strand = owner._strand
  octester:eq(
    torch.pointer(my:getNerve()), torch.pointer(owner.nn2),
    'My was not replaced.'
  )
  octester:eq(
    torch.pointer(owner._strand[2]), torch.pointer(owner.nn2),
    'My was not replaced.'
  )
end

function octest.nerve_my_updateoutput()
  local owner = {
    nn2=nn.Linear(2, 2),
    _strand=nn.Linear(2, 2) .. oc.My('nn2') .. nn.Linear(2, 2),
    get=
      function (self, val)
        return self.members[val]
      end
  }
  local my = owner._strand[2]
  if pcall(owner._strand.updateOutput, torch.randn(2, 2)) then
    error('Should not be able to update output for my.')
  end
end

function octest.nerve_my_updategradInput()
  local owner = {
    nn2=nn.Linear(2, 2),
    _strand=nn.Linear(2, 2) .. oc.My('nn2') .. nn.Linear(2, 2),
    get=
      function (self, val)
        return self.members[val]
      end
  }
  local my = owner._strand[2]
  if pcall(owner._strand.updateGradInput, torch.randn(2, 2), torch.randn(2, 2)) then
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

function octest.nerve_mystrand()
  local owner = {
    nn2=oc.Arm(nn.Linear(2, 2) .. nn.Linear(2, 2)),
    _strand=nn.Linear(2, 2) .. oc.MyStrand('nn2') .. nn.Linear(2, 2),
    get=
      function (self, val)
        return self.members[val]
      end
  }
  local my = owner._strand[2]
  my:setOwner(owner)
  local strand = owner._strand
  octester:eq(
    torch.pointer(owner._strand[2]), torch.pointer(owner.nn2:strand()[1]),
    'My was not replaced.'
  )
  
  octester:eq(
    torch.pointer(owner._strand[3]), torch.pointer(owner.nn2:strand()[2]),
    'My was not replaced.'
  )
end

require 'oc.strand'
require 'oc.wrap'

function octest.nerve_wrap()
  local owner = {
    nn2=nn.Linear(2, 2),
    _strand=nn.Linear(2, 2) .. oc.Wrap('nn2') .. nn.Linear(2, 2),
    get=
      function (self, val)
        return self.members[val]
      end
  }
  local wrap = owner._strand[2]
  wrap:setOwner(owner)
  local strand = owner._strand
  local wrapPost = strand[2]
  octester:eq(
    torch.pointer(wrap), torch.pointer(wrapPost),
    'The pre and post values should be equal.'
  )
  octester:eq(
    torch.pointer(owner._strand[2]:getNerve()), torch.pointer(owner.nn2),
    'Wrap was not replaced.'
  )
  
  owner._strand[1]:inform(torch.randn(2, 2))
  local output = owner._strand[3]:probe()
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
    _strand=nn.Linear(2, 2) .. oc.Super('nn2') .. nn.Linear(2, 2)
  }
  local superNerve = owner._strand[2]
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
    _strand=nn.Linear(2, 2) .. oc.Super('nn2') .. nn.Linear(2, 2)
  }
  local superNerve = owner._strand[2]
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
    _strand=nn.Linear(2, 2) .. oc.Super('nn2') .. nn.Linear(2, 2)
  }
  local superNerve = owner._strand[2]
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
  local strand = mod .. oc.Noop()
  mod:setOwner(owner)
  
  local result = strand:probe()
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
  local strand = mod .. oc.Noop()
  mod:setOwner(owner)
  
  strand:inform(addTogether)
  local result = strand:probe()
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

function octest.oc_placeholder_nerve_reference_mystrand()
  local ref = oc.mystrand.x
  
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
  local strand = oc.wrap.x .. oc.Noop()
  octester:eq(
    torch.type(strand[1]), 'oc.Wrap',
    'Type should be a wrap module'
  )
end

function octest.oc_placeholder_nerve_reference_my_init_concat()
  local strand = oc.my.x .. oc.Noop()
  octester:eq(
    torch.type(strand[1]), 'oc.My',
    'Type should be a My module'
  )
end

function octest.oc_placeholder_nerve_reference_mystrand_concat()
  local strand = oc.mystrand.x .. oc.Noop()
  
  octester:eq(
    torch.type(strand[1]), 'oc.MyStrand',
    'Type should be a MyStrand Module'
  )
end

function octest.oc_placeholder_nerve_reference_super_concat()
  local strand = oc.super.x .. oc.Noop()
  
  octester:eq(
    torch.type(strand[1]), 'oc.Super',
    'Type should be a Super module'
  )
end

--]]