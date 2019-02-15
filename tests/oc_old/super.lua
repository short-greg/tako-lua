require 'oc.super'

function octest.nerve_super()
  local super = {
    nn2=nn.Linear(2, 2)
  }
  local owner = {
    _chain=nn.Linear(2, 2) .. oc.Super('nn2') .. nn.Linear(2, 2)
  }
  local superNerve = owner._chain[2]
  superNerve:setSuper(super)
  local superPost = super.nn2
  octester:eq(
    torch.isequal(superNerve:getModule(), super.nn2), true,
    'Super nerve\'s module should equal nn2'
  )
end

function octest.nerve_super_updateOutput()
  local super = {
    nn2=nn.Linear(2, 2)
  }
  local owner = {
    _chain=nn.Linear(2, 2) .. oc.Super('nn2') .. nn.Linear(2, 2)
  }
  local superNerve = owner._chain[2]
  superNerve:setSuper(super)
  
  local input_ = torch.rand(2, 2)
  local output = superNerve:updateOutput(input_)
  local output2 = super.nn2:updateOutput(input_)
  
  octester:eq(
    output, output2,
    'The outputs should be equal'
  )
end

function octest.nerve_super_updateGradInput()
  local super = {
    nn2=nn.Linear(2, 2)
  }
  local owner = {
    _chain=nn.Linear(2, 2) .. oc.Super('nn2') .. nn.Linear(2, 2)
  }
  local superNerve = owner._chain[2]
  superNerve:setSuper(super)
  
  local input_ = torch.rand(2, 2)
  local gradOutput_ = torch.rand(2, 2)
  superNerve:stimulate(input_)
  local gradInput = superNerve:updateGradInput(
    input_, gradOutput_
  )
  super.nn2:stimulate(input_)
  local gradInput2 = super.nn2:updateGradInput(
    input_, gradOutput_
  )
  
  octester:eq(
    gradInput, gradInput2,
    'The gradInputs should be equal'
  )
end
