require 'oc.init'
require 'ocnn.module'
require 'oc.bot.store'
require 'ocnn.bot'


--Tensor storer
function octest.bot_probe()
  local store = oc.bot.store.TensorStorer()
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  
  store:probe():forward(mod)
  local outputs = store:getOutputs()
  octester:assert(
    outputs[mod] ~= mod.output,
    'Outputs[mod] should point '..
    'to a different tensor.'
  )
  octester:eq(
    outputs[mod], mod.output,
    'The output of the bot should equal the mod output'
  )
end

function octest.bot_probeGrad()
  -- Inform
  local store = oc.bot.store.TensorStorer()
  local mod = nn.Linear(2, 2)
  local output = mod.output
  mod:stimulate(torch.rand(2))
  store:probe():forward(mod)
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  local outputs = store:getOutputs()
  local gradInputs = store:getGradInputs()
  octester:assert(
    outputs[mod]:eq(mod.output) and outputs[mod] ~= mod.output,
    'Must store the mod '
  )
  octester:assert(
    gradInputs[mod]:eq(
      mod.gradInput
    ) and gradInputs[mod] ~= mod.gradInput,
    'Must store the mod '
  )
end


function octest.bot_storeGrad()
  -- Inform
  
  local store = oc.bot.store.TensorStorer()
  
  local mod = nn.Linear(2, 2)
  local output = mod.output
  mod:stimulate(torch.rand(2))
  store:probe():forward(mod)
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  store:acc():inform():forward(mod)
  local outputs = store:getOutputs()
  local gradInputs = store:getGradInputs()
  octester:assert(
    outputs[mod] == mod.output,
    'Must store the mod '
  )
  octester:assert(
    gradInputs[mod] == mod.gradInput,
    'Must store the mod '
  )
end
