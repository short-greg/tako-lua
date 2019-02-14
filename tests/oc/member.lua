require 'oc.emission'
require 'oc.var'
require 'oc.member'
  
function octest.nerve_member_get_output()
  local t = oc.Const(2)
  local v = oc.Get(t, 'output')
  local output = v:updateOutput()
  octester:eq(
    t.output, output,
    'The outputs should be equal'
  )
end

function octest.nerve_member_set_output()
  local t = oc.Var(2)
  local v = oc.Set(t, 'output')
  local output = 3
  v:updateOutput(output)
  octester:eq(
    t.output, output,
    'The outputs should be equal'
  )
end
