require 'torch'
require 'oc.nerve'
require 'oc.strand'
require 'oc.flow.router'
require 'oc.const'
require 'oc.coalesce'
require 'oc.noop'


function octest.flow_switch_output()
  local input_ = {1}
  local routingFunc = oc.Noop()
  local mod1 = oc.Coalesce(1)
  local mod2 = oc.Coalesce(2)
  local target = {1, 1}
  local mod = oc.Switch(
    routingFunc, {mod1, mod2}
  )
  octester:eq(
    mod:stimulate(input_), target,
    'The output of the module does not equal the target'
  )
end

function octest.flow_switch_output_2()
  local input_ = {2}
  local routingFunc = oc.Noop()
  local mod1 = oc.Coalesce(1)
  local mod2 = oc.Coalesce(2)
  local target = {2, 2}
  local mod = oc.Switch(
    routingFunc, {mod1, mod2}
  )
  octester:eq(
    mod:stimulate(input_), target,
    'The output of the module does not equal the target'
  )
end

function octest.flow_switch_output_default()
  local input_ = {}
  local routingFunc = oc.Noop()
  local mod1 = oc.Coalesce(1)
  local mod2 = oc.Coalesce(2)
  local target = {nil, 2}
  local mod = oc.Switch(
    routingFunc, {mod1, default=mod2}
  )
  octester:eq(
    mod:stimulate(input_), target,
    'The output of the module does not equal the target'
  )
end


function octest.flow_switch_grad_input_default()
  local input_ = {}
  local routingFunc = oc.Noop()
  local mod1 = oc.Coalesce(1)
  local mod2 = oc.Coalesce(2)
  local target = {}
  local mod = oc.Switch(
    routingFunc, {mod1, default=mod2}
  )
  local output = mod:stimulate(input_)
  octester:eq(
    mod:stimulateGrad(output), target,
    'The output of the module does not equal the target'
  )
end


function octest.flow_case_output()
  local routingFunc = oc.Noop()
  local mod1 = oc.Coalesce({true, 1})
  local mod2 = oc.Coalesce({false, 2})
  local target = {1, 1}
  local mod = oc.Case{
    mod1, mod2
  }
  octester:eq(
    mod:stimulate(nil), target,
    'The output of the module does not equal the target'
  )
end

function octest.flow_case_output_second()
  local routingFunc = oc.Noop()
  local mod1 = oc.Coalesce({false, 1})
  local mod2 = oc.Coalesce({true, 2})
  local target = {2, 2}
  local mod = oc.Case{
    mod1, mod2
  }
  octester:eq(
    mod:stimulate(nil), target,
    'The output of the module does not equal the target'
  )
end

function octest.flow_case_output_default()
  local routingFunc = oc.Noop()
  local mod1 = oc.Coalesce({false, 1})
  local mod2 = oc.Coalesce(2)
  local target = {'default', 2}
  local mod = oc.Case{
    mod1, default=mod2
  }
  octester:eq(
    mod:stimulate(nil), target,
    'The output of the module does not equal the target'
  )
end


function octest.flow_case_grad_input()
  local mod1 = oc.Coalesce({false, 1})
  local mod2 = oc.Coalesce({true, 2})
  local target = nil
  local mod = oc.Case{
    mod1, mod2
  }
  local output = mod:stimulate(nil)
  octester:eq(
    mod:stimulateGrad(output), target,
    'The output of the module does not equal the target'
  )
end
