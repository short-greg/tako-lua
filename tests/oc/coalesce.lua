require 'oc.coalesce'


function octest.oc_coalesce_with_inform()
  local coalesce = oc.Coalesce(1)

  octester:asserteq(
    coalesce:stimulate(2), 2, 
    'Output of coalesce should 2'
  )
end


function octest.oc_coalesce_with_nil_inform()
  local coalesce = oc.Coalesce(1)

  octester:asserteq(
    coalesce:stimulate(), 1, 
    'Output of coalesce should 1'
  )
end

