require 'oc.arm'
require 'oc.strand'
require 'oc.noop'


function octest.oc_arm_len()
  local module = oc.Noop():label('hello')
  local arm = oc.Arm(
    oc.Strand(module)
  )
  octester:asserteq(
    #arm, 1,
    'Arm should have one module.'
  )
end

function octest.oc_arm_getByName()
  local name = 'nn1'
  local nn1 = oc.Noop():label(name) 
  local arm = oc.Arm(oc.Strand(nn1))
  local nn = arm:getByName(name)
  octester:asserteq(
    nn, nn1,
    'The modules should be the same.'
  )
end

function octest.oc_arm_get()
  local name = 'nn1'
  local nn1 = oc.Noop():label(name) 
  local nn2 = oc.Noop()
  local arm = oc.Arm(nn1 .. nn2)
  local nn = arm:get(2)
  octester:asserteq(
    nn, nn2,
    'The modules should be the same.'
  )
end

function octest.oc_arm_updateOutput()
  local name = 'nn1'
  local nn1 = oc.Noop():label(name) 
  local nn2 = oc.Noop()
  local arm = oc.Arm(nn1 .. nn2)
  arm:inform(torch.rand(2, 2))
  local output = arm:probe()
  octester:asserteq(
    output, nn2:probe(),
    'The outputs should be the same.'
  )
end

function octest.oc_arm_updateGradInput()
  local name = 'nn1'
  local nn1 = oc.Noop():label(name) 
  local nn2 = oc.Noop()
  local arm = oc.Arm(nn1 .. nn2)
  arm:inform(2)
  local output = arm:probe()
  arm:informGrad(output)
  local gradInput = arm:probeGrad()
  octester:asserteq(
    gradInput, nn1:probeGrad(),
    'The gradInputs should be the same.'
  )
end

function octest.oc_arm_root()
  local name = 'nn1'
  local nn1 = oc.Noop():label(name) 
  local nn2 = oc.Noop()
  local arm = oc.Arm(nn1 .. nn2)
  local root = arm:root()
  octester:asserteq(
    root, nn1,
    'The modules should be the same.'
  )
end

function octest.oc_arm_fromNerve()
  local name = 'nn1'
  local nn1 = oc.Noop():label(name) 
  local arm = oc.Arm.fromNerve(nn1)
  local root = arm:root()
  octester:asserteq(
    root, nn1,
    'The modules should be the same.'
  )
end

function octest.oc_arm_strand()
  local name = 'nn1'
  local nn1 = oc.Noop():label(name) 
  local nn2 = oc.Noop()
  local strand = nn1 .. nn2
  local arm = oc.Arm(strand)
  octester:asserteq(
    arm:strand():lhs(), strand:lhs(),
    'The modules should be the same.'
  )
  octester:asserteq(
    arm:strand():rhs(), strand:rhs(),
    'The modules should be the same.'
  )
end
