require 'oc.feature'
require 'oc.var'

function octest.oc_feature_init_with_val()
  local val = 'x'
  local x = oc.Feature(val)
  octester:eq(
    x(), val,
    string.format('The feature should equal '..
    '%s.', val)
  )
end

function octest.oc_feature_init_with_module()
  local val = oc.Const('x')
  local x = oc.Feature(val)
  octester:eq(
    x(), val:probe(),
    string.format('The feature should equal '..
    '%s.', val:probe())
  )
end

function octest.oc_feature_add_with_val()
  local val = 2
  local addVal = 3
  local x = oc.Feature(val)
  octester:eq(
    x + addVal, val + addVal,
    string.format('The feature should equal '..
    '%d.', val + addVal)
  )
end

function octest.oc_feature_add_with_val_module()
  local val = 2
  local addVal = 3  
  local valMod = oc.Var(val)
  local x = oc.Feature(valMod)
  octester:eq(
    x + addVal, val + addVal,
    string.format('The feature should equal '..
    '%d.', val + addVal)
  )
end

function octest.oc_feature_unm()
  local val = 2
  local x = oc.Feature(val)
  octester:eq(
    -x, -val,
    string.format('The feature should equal '..
    '%d.', -val)
  )
end

function octest.oc_feature_sub()
  local val = 2
  local subVal = 3
  local x = oc.Feature(val)
  octester:eq(
    x - subVal, val - subVal,
    string.format('The feature should equal '..
    '%d.', val - subVal)
  )
end

function octest.oc_feature_sub_two_features()
  local val = 2
  local subVal = 3
  local x = oc.Feature(val)
  local x2 = oc.Feature(subVal)
  octester:eq(
    x - x2, val - subVal,
    string.format('The feature should equal '..
    '%d.', val - subVal)
  )
end

function octest.oc_feature_exp()
  local val = 2
  local expVal = 3
  local x = oc.Feature(val)
  octester:eq(
    x^expVal, val^expVal,
    string.format('The feature should equal '..
    '%d.', val ^ expVal)
  )
end

function octest.oc_feature_exp_with_right()
  local val = 2
  local expVal = 3
  local x = oc.Feature(expVal)
  octester:eq(
    val^x, val^expVal,
    string.format('The feature should equal '..
    '%d.', val ^ expVal)
  )
end

function octest.oc_feature_mul()
  local val = 2
  local mulVal = 3
  local x = oc.Feature(val)
  octester:eq(
    x*mulVal, val*mulVal,
    string.format('The feature should equal '..
    '%d.', val * mulVal)
  )
end

function octest.oc_feature_div()
  local val = 2
  local divVal = 3
  local x = oc.Feature(val)
  octester:eq(
    x / divVal, val /divVal,
    string.format('The feature should equal '..
    '%d.', val / divVal)
  )
end

function octest.oc_feature_lt()
  local val = 2
  local ltVal = 3
  local x = oc.Feature(val)
  octester:eq(
    x < ltVal, true,
    string.format('The feature should be less than %d', ltVal)
  )
end

function octest.oc_feature_le()
  local val = 2
  local ltVal = 3
  local x = oc.Feature(val)
  octester:eq(
    x < ltVal and x <= val, true,
    string.format('The feature should be less or equal'..
    ' to %d and %d', ltVal, val)
  )
end

--! Equality operator will not be called if both items do not have 
--! same metatable
function octest.oc_feature_eq()
  local val = 3
  local x = oc.Feature(val)
  local x2 = oc.Feature(val)
  octester:eq(
    x == x2 , true,
    string.format('The feature should be equal to '..
    ' to %d', tostring(x))
  )
end






