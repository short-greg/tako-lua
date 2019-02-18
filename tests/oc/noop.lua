require 'oc.noop'


function octest.oc_noop_with_inform_1()
  local noop = oc.Noop()

  octester:asserteq(
    noop:stimulate(1), 1, 
    'Output of noop should be the same as the input'
  )
end


function octest.oc_noop_with_inform_nil()
  local noop = oc.Noop()

  octester:asserteq(
    noop:stimulate(nil), nil, 
    'Output of noop should be the same as the input'
  )
end


function octest.oc_noop_with_informGrad_1()
  local noop = oc.Noop()

  octester:asserteq(
    noop:stimulateGrad(1), 1, 
    'GradInput of noop should be the same as the GradOutput'
  )
end
