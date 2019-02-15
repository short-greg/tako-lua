
do
  require 'oc.init'
  require 'oc.bot.nerve'
  
  local store = oc.bot.nerve.Storer()
  
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  
  store:probe():forward(mod)
  local outputs = store:getOutputs()
  assert(
    outputs[mod] == mod.output,
    'Must store the mod '
  )
  
end

do
  -- Inform
  require 'oc.init'
  require 'oc.bot.nerve'
  
  local store = oc.bot.nerve.Storer()
  
  local mod = nn.Linear(2, 2)
  local output = mod.output
  mod:stimulate(torch.rand(2))
  store:probe():forward(mod)
  mod.output = torch.rand(2)
  
  store:grad():inform():forward(mod)
  local outputs = store:getOutputs()
  assert(
    output == mod.output,
    'Must store the mod '
  )
  
end


do
  -- Inform
  require 'oc.init'
  require 'oc.bot.nerve'
  
  local store = oc.bot.nerve.Storer()
  
  local mod = nn.Linear(2, 2)
  local output = mod.output
  mod:stimulate(torch.rand(2))
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  
  local gradInputs = store:getGradInputs()
  assert(
    gradInputs[mod] == mod.gradInput,
    'Must store the mod '
  )
end


do
  -- Inform
  require 'oc.init'
  require 'oc.bot.nerve'
  local store = oc.bot.nerve.Storer()
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
  assert(
    output == mod.output,
    'Must store the mod output'
  )
  print('Grad Input')
  assert(
    gradInput == mod.gradInput,
    'Must store the mod gradInput'
  )
end


do
  -- Inform
  require 'oc.init'
  require 'oc.bot.nerve'
  local store = oc.bot.nerve.Storer()
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
  assert(
    output == mod.output,
    'Must store the mod output'
  )
  assert(
    gradInput == mod.gradInput,
    'Must store the mod gradInput'
  )
end


do
  -- Inform
  require 'oc.init'
  require 'oc.bot.nerve'
  local store = oc.bot.nerve.NullStorer()
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  store:out():probe():forward(mod)
  assert(
    #store:getOutputs() == 0,
    'Should not have stored any outputs'
  )
end


do
  -- Inform
  require 'oc.init'
  require 'oc.bot.nerve'
  local store = oc.bot.nerve.NullStorer()
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  assert(
    #store:getGradInputs() == 0,
    'Should not have stored any outputs'
  )
end

do
  -- Inform
  require 'oc.init'
  require 'oc.bot.nerve'
  local store = oc.bot.nerve.NullStorer()
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  local output = torch.rand(2)
  store:out():probe():forward(mod)
  mod.output = output
  store:grad():inform():forward(mod)
  assert(
    mod.output == output,
    ''
  )
end


do
  -- Inform
  require 'oc.init'
  require 'oc.bot.nerve'
  local store = oc.bot.nerve.NullStorer()
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  local gradInput = torch.rand(2)
  store:out():probe():forward(mod)
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  
  mod.gradInput = gradInput
  store:acc():inform():forward(mod)
  assert(
    mod.gradInput == gradInput,
    ''
  )
end

do
  -- Inform
  require 'oc.init'
  require 'oc.bot.nerve'
  local store = oc.bot.nerve.NullStorer()
  local mod = nn.Linear(2, 2)
  mod:stimulate(torch.rand(2))
  local gradInput = torch.rand(2)
  store:out():probe():forward(mod)
  mod:stimulateGrad(torch.rand(2))
  store:grad():probe():forward(mod)
  
  mod.gradInput = gradInput
  store:acc():inform():forward(mod)
  assert(
    mod.gradInput == gradInput,
    ''
  )
end