require 'oc.coalesce'
require 'oc.const'

function octest.oc_const_with_nil_inform()
  local coalesce = oc.Const(1)

  octester:asserteq(
    coalesce:stimulate(), 1, 
    'Output of const should 2'
  )
end


function octest.oc_const_with_inform()
  local coalesce = oc.Const(1)
  local success = pcall(coalesce.stimulate, coalesce, 1)
  octester:asserteq(
    success, false, 
    'Should through an error if const is informed'.. 
    'with non-nil value'
  )
end
