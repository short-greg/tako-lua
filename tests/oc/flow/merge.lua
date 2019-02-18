require 'oc.flow.merge'
require 'oc.ref'
require 'oc.placeholder'
require 'oc.noop'
require 'oc.coalesce'


function octest.control_merge_onto_one_item_probe()
  local x = oc.Noop()
  local y = oc.Noop()
  
  local z = x .. oc.Onto(y)
  y:inform(1)
  local output = z:stimulate(3)
  local target = {3, 1}
  octester:eq(
    output, target,
    'The output and the target are not equal.'
  )
end

function octest.control_merge_onto_two_items_probeGrad()
  local x = oc.Noop()
  local y = oc.Noop()
  
  local z = x .. oc.Onto(y)
  y:inform(1)
  local output = z:stimulate(3)
  z:informGrad({3, 1})
  local gradX = x:probeGrad()
  local gradY = y:probeGrad()
  octester:eq(
    gradX, 3,
    'The gradient and the target for x are not equal.'
  )
  octester:eq(
    gradY, 1,
    'The gradient and the target for y are not equal.'
  )
end


function octest.control_merge_under_one_item_probe()
  local x = oc.Noop()
  local y = oc.Noop()
  
  local z = x .. oc.Under(y)
  y:inform(1)
  local output = z:stimulate(3)
  local target = {1, 3}
  octester:eq(
    output, target,
    'The output and the target are not equal.'
  )
end

function octest.control_merge_under_two_items_probeGrad()
  local x = oc.Noop()
  local y = oc.Noop()
  
  local z = x .. oc.Under(y)
  y:inform(1)
  local output = z:stimulate(3)
  z:informGrad({1, 3})
  local gradX = x:probeGrad()
  local gradY = y:probeGrad()
  octester:eq(
    gradX, 3,
    'The gradient and the target for x are not equal.'
  )
  octester:eq(
    gradY, 1,
    'The gradient and the target for y are not equal.'
  )
end


function octest.control_merge_under_with_exec_grad_input()
  local x = oc.Noop()
  local y = oc.Coalesce(1)
  
  local z = x .. oc.Under(oc.Exec(y))
  local output = z:stimulate(3)
  z:informGrad({1, 3})
  local gradX = x:probeGrad()
  local gradY = y:probeGrad()
  octester:eq(
    gradX, 3,
    'The gradient and the target for x are not equal.'
  )
  octester:eq(
    y:getGradOutput(), 1,
    'The gradient and the target for y are not equal.'
  )
end


function octest.control_merge_under_with_exec_output()
  local x = oc.Noop()
  local y = oc.Coalesce(1)
  
  local z = x .. oc.Under(oc.Exec(y))
  local output = z:stimulate(3)
  local target = {1, 3}
  octester:eq(
    output, target,
    'The output and the target are not equal.'
  )
end


function octest.control_merge_under_with_get__grad_input()
  local x = oc.Noop()
  local y = oc.Coalesce(1)
  
  local z = x .. oc.Under(oc.Get(y))
  local output = z:stimulate(3)
  z:informGrad({1, 3})
  local gradX = x:probeGrad()
  local gradY = y:probeGrad()
  octester:eq(
    gradX, 3,
    'The gradient and the target for x are not equal.'
  )
  octester:eq(
    y:getGradOutput(), 1,
    'The gradient and the target for y are not equal.'
  )
end


function octest.control_merge_under_with_get__output()
  local x = oc.Noop()
  local y = oc.Noop(1)
  -- Should just get the output (i.e. no probing)
  y.output = 2
  y:inform(1)
  local z = x .. oc.Under(oc.Get(y))
  local output = z:stimulate(3)
  local target = {2, 3}
  octester:eq(
    output, target,
    'The output and the target are not equal.'
  )
end


function octest.control_merge_under_with_ref__output()
  local x = oc.Noop()
  local y = oc.nerve(oc.my.x)
  local t = {x=2}
  y:setOwner(t)
  -- Should just get the output (i.e. no probing)
  local z = x .. oc.Under(y)
  local output = z:stimulate(3)
  local target = {2, 3}
  octester:eq(
    output, target,
    'The output and the target are not equal.'
  )
end


function octest.control_merge_under_with_nerve_ref__output()
  local x = oc.Noop()
  local y = oc.r(oc.my.x)
  local t = {x=oc.Coalesce(2)}
  y:setOwner(t)
  -- Should just get the output (i.e. no probing)
  local z = x .. oc.Under(y)
  local output = z:stimulate(3)
  local target = {2, 3}
  octester:eq(
    output, target,
    'The output and the target are not equal.'
  )
end
