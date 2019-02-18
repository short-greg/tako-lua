require 'oc.bot.store'
require 'oc.init'


function octest.bot_store_stimulate()
  local store = oc.bot.store.Storer()
  
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  
  store:probe():forward(mod)
  local outputs = store:getOutputs()
  octester:assert(
    outputs[mod] == mod.output,
    'Must store the mod '
  )
end


function octest.bot_store_grad_stimulate()
  -- Inform
  local store = oc.bot.store.Storer()
  
  local mod = nn.Linear(2, 2)
  local output = mod.output
  mod:stimulate(torch.rand(2))
  store:probe():forward(mod)
  mod.output = torch.rand(2)
  
  store:grad():inform():forward(mod)
  local outputs = store:getOutputs()
  octester:assert(
    output == mod.output,
    'Must store the mod '
  )
end


function octest.bot_store_probe_grad()
  -- Inform
  local store = oc.bot.store.Storer()
  local mod = nn.Linear(2, 2)
  local output = mod.output
  mod:stimulate(torch.rand(2))
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  
  local gradInputs = store:getGradInputs()
  octester:assert(
    gradInputs[mod] == mod.gradInput,
    'Must store the mod '
  )
end


function octest.bot_store_acc_inform()
  -- Inform
  local store = oc.bot.store.Storer()
  local mod = nn.Linear(2, 2)
  local output = mod.output
  local gradInput = mod.gradInput
  mod:stimulate(torch.rand(2))
  store:out():probe():forward(mod)
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  mod.output = torch.rand(2)
  mod.gradInput = torch.rand(2)
  store:acc():inform():forward(mod)
  octester:assert(
    output == mod.output,
    'Must store the mod output'
  )
  octester:assert(
    gradInput == mod.gradInput,
    'Must store the mod gradInput'
  )
end


--[[
--TODO: Looks the same as the test above

function octest.bot_store_acc_inform()
  -- Inform
  local store = oc.bot.store.Storer()
  local mod = nn.Linear(2, 2)
  local output = mod.output
  local gradInput = mod.gradInput
  mod:stimulate(torch.rand(2))
  store:out():probe():forward(mod)
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  mod.output = torch.rand(2)
  mod.gradInput = torch.rand(2)
  store:acc():inform():forward(mod)
  octester:assert(
    output == mod.output,
    'Must store the mod output'
  )
  octester:assert(
    gradInput == mod.gradInput,
    'Must store the mod gradInput'
  )
end
--]]

function octest.bot_null_storer_probe()
  -- Inform
  local store = oc.bot.store.NullStorer()
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  store:out():probe():forward(mod)
  octester:assert(
    #store:getOutputs() == 0,
    'Should not have stored any outputs'
  )
end


function octest.bot_null_storer_grad_probe()
  -- Inform
  local store = oc.bot.store.NullStorer()
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  octester:assert(
    #store:getGradInputs() == 0,
    'Should not have stored any outputs'
  )
end


function octest.bot_null_storer_grad_inform()
  -- Inform
  local store = oc.bot.store.NullStorer()
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  local output = torch.rand(2)
  store:out():probe():forward(mod)
  mod.output = output
  store:grad():inform():forward(mod)
  octester:assert(
    mod.output == output,
    ''
  )
end


function octest.bot_null_storer_acc_inform()
  -- Inform
  local store = oc.bot.store.NullStorer()
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  local gradInput = torch.rand(2)
  store:out():probe():forward(mod)
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  
  mod.gradInput = gradInput
  store:acc():inform():forward(mod)
  octester:assert(
    mod.gradInput == gradInput,
    ''
  )
end

--[[
-- TODO: check this
function octest.bot_null_storer_acc_inform()
  -- Inform
  local store = oc.bot.store.NullStorer()
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  local gradInput = torch.rand(2)
  store:out():probe():forward(mod)
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  
  mod.gradInput = gradInput
  store:acc():inform():forward(mod)
  octester:assert(
    mod.gradInput == gradInput,
    ''
  )
end
--]]