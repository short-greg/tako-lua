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


function octest.oc_placeholder_input()
  local nerve = oc.nerve(oc.input.x)
  octester:eq(
    oc.type(nerve), 'oc.InputRef',
    'The placeholder should become type InputRef'
  )
end


function octest.oc_placeholder_input_concat()
  local strand = oc.input.x .. oc.my.x
  octester:eq(
    oc.type(strand:lhs()), 'oc.InputRef',
    'The lhs placeholder should become type InputRef'
  )

  octester:eq(
    oc.type(strand:rhs()), 'oc.MyRef',
    'The rhs placeholder should become type MyRef'
  )
end


function octest.oc_placeholder_input_with_call()
  local nerve = oc.nerve(oc.input.x('hi').y.z('bye'))

  octester:eq(
    oc.type(nerve), 'oc.InputRef',
    'The placeholder should become type InputRef'
  )
end


function octest.oc_placeholder_convert_input_ref()
  local nerve = oc.nerve(oc.input)

  octester:eq(
    oc.type(nerve), 'oc.InputRef',
    'The placeholder should become type InputRef'
  )
end


function octest.oc_placeholder_input_with_no_indexing()
  local nerve = oc.nerve(oc.input)

  octester:eq(
    oc.type(nerve), 'oc.InputRef',
    'The placeholder should become type InputRef'
  )
end

function octest.oc_placeholder_val()
  local nerve = oc.nerve(oc.ref{1})

  octester:eq(
    oc.type(nerve), 'oc.ValRef',
    'The placeholder should become type ValRef'
  )
end


function octest.oc_placeholder_my()
  local nerve = oc.nerve(oc.my.x)

  octester:eq(
    oc.type(nerve), 'oc.MyRef',
    'The placeholder should become type MyRef'
  )
end


function octest.oc_placeholder_convert_my_with_no_indexing()
  local nerve = oc.nerve(oc.my)

  octester:eq(
    oc.type(nerve), 'oc.MyRef',
    'The placeholder should become type MyRef'
  )
end


function octest.oc_placeholder_super()
  local nerve = oc.nerve(oc.super.x)

  octester:eq(
    oc.type(nerve), 'oc.SuperRef',
    'The placeholder should become type SuperRef'
  )
end
