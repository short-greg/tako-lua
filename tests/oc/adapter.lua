require 'oc.init'


function octest.oc_adapter_stimulate()
  local nn2 = oc.Noop()
  local nn1 = oc.Noop() .. oc.Onto(nn2) ..
    oc.Noop()
  
  local adapter = oc.Adapter({nn1, nn2}, nn1)
  local result = adapter:stimulate({1, 2})
  print('output: ', nn1[2].output)
  octester:assert(
    result[1] == 1 and result[2] == 2
  )
end


function octest.oc_adapter_stimulateGrad()
  local nn2 = oc.Noop()
  local nn1 = oc.Noop() .. oc.Onto(nn2) ..
    oc.Noop()
  
  local adapter = oc.Adapter({nn1, nn2}, nn1)
  adapter:stimulate({1, 2})
  local result = adapter:stimulate({1, 2})
  
  octester:assert(
    result[1] == 1 and result[2] == 2
  )
end
