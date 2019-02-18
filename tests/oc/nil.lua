require 'oc.nil'


function octest.oc_nil_with_inform()
  local toNil = oc.ToNil()

  octester:asserteq(
    toNil:stimulate(1), nil, 
    'Output of toNil should be nil'
  )
end
