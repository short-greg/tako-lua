require 'oc.root'
require 'oc.var'

function octest.oc_root_value()
  local inp = oc.Root(1)
  octester:eq(
    inp:probe(), 1,
    'Output should be equal to 1'
  )
end

function octest.oc_root_value_in_strand()
  local inp = oc.Root(1)
  local strand = inp .. oc.Noop()
  octester:eq(
    strand:probe(), 1,
    'Output should be equal to 1'
  )
end
