require 'oc.arm'
require 'oc.chain'

function octest.oc_arm_len()
  local module = nn.Linear(2, 2):lab('hello')
  local arm = oc.Arm(
    oc.Chain(module)
  )
  octester:asserteq(
    #arm, 1,
    'Arm should have one module.'
  )
end

function octest.oc_arm_getByName()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name) 
  local arm = oc.Arm(oc.Chain(nn1))
  local nn = arm:getByName(name)
  octester:asserteq(
    nn, nn1,
    'The modules should be the same.'
  )
end

function octest.oc_arm_get()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name) 
  local nn2 = nn.Linear(2, 2) 
  local arm = oc.Arm(nn1 .. nn2)
  local nn = arm:get(2)
  octester:asserteq(
    nn, nn2,
    'The modules should be the same.'
  )
end

function octest.oc_arm_updateOutput()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name) 
  local nn2 = nn.Linear(2, 2) 
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
  local nn1 = nn.Linear(2, 2):lab(name) 
  local nn2 = nn.Linear(2, 2) 
  local arm = oc.Arm(nn1 .. nn2)
  arm:inform(torch.rand(2, 2))
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
  local nn1 = nn.Linear(2, 2):lab(name) 
  local nn2 = nn.Linear(2, 2) 
  local arm = oc.Arm(nn1 .. nn2)
  local root = arm:root()
  octester:asserteq(
    root, nn1,
    'The modules should be the same.'
  )
end

function octest.oc_arm_fromNerve()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name) 
  local arm = oc.Arm.fromNerve(nn1)
  local root = arm:root()
  octester:asserteq(
    root, nn1,
    'The modules should be the same.'
  )
end

function octest.oc_arm_chain()
  local name = 'nn1'
  local nn1 = nn.Linear(2, 2):lab(name) 
  local nn2 = nn.Linear(2, 2)
  local chain = nn1 .. nn2
  local arm = oc.Arm(chain)
  octester:asserteq(
    arm:chain(), chain,
    'The modules should be the same.'
  )
end


