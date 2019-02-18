require 'oc.root'
require 'oc.var'

function octest.oc_root_value()
  local inp = oc.Root(1)
  octester:eq(
    inp:probe(), 1,
    'Output should be equal to 1'
  )
end

function octest.oc_root_value_in_chain()
  local inp = oc.Root(1)
  local chain = inp .. oc.Noop()
  octester:eq(
    chain:probe(), 1,
    'Output should be equal to 1'
  )
end
