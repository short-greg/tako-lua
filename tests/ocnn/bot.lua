


--Tensor storer

do
  require 'oc.init'
  require 'oc.bot.nerve'
  require 'ocnn.bot'
  
  local store = oc.bot.nerve.TensorStorer()
  
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  
  store:probe():forward(mod)
  local outputs = store:getOutputs()
  assert(
    outputs[mod]:eq(mod.output) and
    outputs[mod] ~= mod.output,
    'Must store the mod '
  )
  
end

do
  -- Inform
  require 'oc.init'
  require 'ocnn.bot'
  
  local store = oc.bot.nerve.TensorStorer()
  
  local mod = nn.Linear(2, 2)
  local output = mod.output
  mod:stimulate(torch.rand(2))
  store:probe():forward(mod)
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  local outputs = store:getOutputs()
  local gradInputs = store:getGradInputs()
  assert(
    outputs[mod]:eq(mod.output) and outputs[mod] ~= mod.output,
    'Must store the mod '
  )
  assert(
    gradInputs[mod]:eq(
      mod.gradInput
    ) and gradInputs[mod] ~= mod.gradInput,
    'Must store the mod '
  )
end


do
  -- Inform
  require 'oc.init'
  require 'ocnn.bot'
  
  local store = oc.bot.nerve.TensorStorer()
  
  local mod = nn.Linear(2, 2)
  local output = mod.output
  mod:stimulate(torch.rand(2))
  store:probe():forward(mod)
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  store:acc():inform():forward(mod)
  local outputs = store:getOutputs()
  local gradInputs = store:getGradInputs()
  assert(
    outputs[mod] == mod.output,
    'Must store the mod '
  )
  assert(
    gradInputs[mod] == mod.gradInput,
    'Must store the mod '
  )
end
