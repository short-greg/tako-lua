require 'oc.nerve'
require 'oc.flow.gate'
require 'oc.noop'
require 'ocnn.module'
require 'oc.math.init'
require 'oc.strand'
require 'oc.arm'

-- TODO Gate should reflect the changes made to this module

function octest.flow_gate_output()
  local x = oc.Noop()
  local y = oc.Noop()
  local input = {true, 1}
  local mod = oc.Gate(
  	oc.Noop(),
  	oc.Noop()
  )
  
  octester:eq(
    mod:stimulate(input), {true, 1},
    'The output of the module does not equal the target'
  )
end

function octest.flow_gate_output_with_locked()
  local x = oc.Noop()
  local y = oc.Noop()
  local input = {false, 1}
  local target = {false, nil}
  local mod = oc.Gate(
  	oc.Noop(),
  	oc.Noop()
  )
  
  octester:eq(
    mod:stimulate(input), target,
    'The output of the module does not equal the target'
  )
end


function octest.flow_gate_gradInput()
  local x = oc.Noop()
  local y = oc.Noop()
  local input = {true, 1}
  local target = {nil, 1}
  local mod = oc.Gate(
  	oc.Noop(),
  	oc.Noop()
  )
  local output = mod:stimulate(input)
  
  octester:eq(
    mod:stimulateGrad(output), target,
    'The output of the module does not equal the target'
  )
end
