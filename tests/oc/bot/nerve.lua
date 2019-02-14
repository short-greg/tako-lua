require 'oc.bot.nerve'


function octest.bot_nerve_emission_storer_outputs()
  local bot = oc.bot.nerve.EmissionStorer()
  local seq = nn.Linear(2, 2) .. nn.Linear(2, 2)
  seq:lhs():inform(torch.randn(2, 2))
  local output = seq:rhs():probe()
  bot:probe()
  bot:out()
  seq:forward(bot)
  local outputs = bot:getOutputs()
  octester:eq(
    outputs[seq:lhs()], seq:lhs().output,
    'The outputs should be equal.'
  )
  octester:eq(
    outputs[seq:rhs()], seq:rhs().output,
    'The outputs should be equal.'
  )
end

function octest.bot_nerve_emission_storer_gradInputs()
  local bot = oc.bot.nerve.EmissionStorer()
  local seq = nn.Linear(2, 2) .. nn.Linear(2, 2)
  seq:lhs():inform(torch.randn(2, 2))
  local output = seq:rhs():probe()
  seq:rhs():informGrad(torch.randn(2, 2))
  local gradInput = seq:lhs():probeGrad()
  bot:probe():grad()
  seq:forward(bot)
  local gradInputs = bot:getGradInputs()
  octester:eq(
    gradInputs[seq:lhs()], seq:lhs().gradInput,
    'The gradInputs should be equal.'
  )
  octester:eq(
    gradInputs[seq:rhs()], seq:rhs().gradInput,
    'The gradInputs should be equal.'
  )
end

function octest.bot_nerve_emission_storer_inform_outputs()
  local bot = oc.bot.nerve.EmissionStorer()
  local seq = nn.Linear(2, 2) .. nn.Linear(2, 2)
  seq:lhs():inform(torch.randn(2, 2))
  local output = seq:rhs():probe()
  bot:probe():out()
  seq:forward(bot)
  bot:resetVisited()
  bot:inform():grad()
  seq:lhs():relaxStream()
  seq:forward(bot)
  local outputs = bot:getOutputs()
  octester:eq(
    outputs[seq:lhs()], seq:lhs().output,
    'The outputs should be equal.'
  )
  octester:eq(
    outputs[seq:rhs()], seq:rhs().output,
    'The outputs should be equal.'
  )
end

function octest.bot_nerve_emission_storer_inform_gradInputs()
  local bot = oc.bot.nerve.EmissionStorer()
  local seq = nn.Linear(2, 2):lab('nn1') .. nn.Linear(2, 2):lab('nn2')
  seq:lhs():inform(torch.randn(2, 2))
  local output = seq:rhs():probe()
  seq:rhs():informGrad(torch.randn(2, 2))
  local gradInput = seq:lhs():probeGrad()
  bot:probe():grad()
  seq:forward(bot)
  bot:resetVisited()
  seq:lhs():relaxEmissionStream()
  bot:inform():acc()
  
  seq:forward(bot)
  
  local gradInputs = bot:getGradInputs()
  octester:eq(
    gradInputs[seq:lhs()], seq:lhs().gradInput,
    'The gradInputs should be equal.'
  )
  octester:eq(
    gradInputs[seq:rhs()], seq:rhs().gradInput,
    'The gradInputs should be equal.'
  )
end

function octest.bot_nerve_multiemission_storer_inform_outputs()
  local bot = oc.bot.nerve.MultiEmissionStorer()
  local seq = nn.Linear(2, 2) .. nn.Linear(2, 2)
  seq:lhs():inform(torch.randn(2, 2))
  local output = seq:rhs():probe()
  bot:probe():out()
  seq:forward(bot)
  bot:index(2)
  seq:lhs():inform(torch.randn(2, 2))
  seq:rhs():probe()
  seq:forward(bot)
  bot:index(1)
  bot:inform():grad()
  seq:lhs():relaxStream()
  seq:forward(bot)
  local outputs = bot:getOutputs()
  octester:eq(
    outputs[seq:lhs()], seq:lhs().output,
    'The outputs should be equal.'
  )
  octester:eq(
    outputs[seq:rhs()], seq:rhs().output,
    'The outputs should be equal.'
  )
end

function octest.bot_nerve_multiemission_storer_inform_gradInputs()
  local bot = oc.bot.nerve.MultiEmissionStorer()
  local seq = nn.Linear(2, 2) .. nn.Linear(2, 2)
  seq:lhs():inform(torch.randn(2, 2))
  local output = seq:rhs():probe()
  seq:lhs():inform(torch.randn(2, 2))
  seq:rhs():probe()
  seq:rhs():informGrad(torch.randn(2, 2))
  local gradInput = seq:lhs():probeGrad()
  bot:probe():grad()
  seq:forward(bot)
  
  bot:index(2)
  seq:lhs():inform(torch.randn(2, 2))
  seq:rhs():probe()
  seq:rhs():informGrad(torch.randn(2, 2))
  seq:lhs():probeGrad()
  seq:forward(bot)
  
  bot:inform():acc()
  seq:lhs():relaxStream()
  local gradInputs = bot:getGradInputs()
  
  bot:index(1)
  seq:forward(bot)
  octester:eq(
    gradInput, seq:lhs().gradInput,
    'The outputs should be equal.'
  )
  octester:ne(
    gradInputs[seq:rhs()], seq:rhs().gradInput,
    'The grad  inputs should not be equal.'
  )

  seq:lhs():relaxStream()
  seq:forward(bot)
  gradInputs = bot:getGradInputs()
  octester:eq(
    gradInputs[seq:lhs()], seq:lhs().gradInput,
    'The outputs should be equal.'
  )
  octester:eq(
    gradInputs[seq:rhs()], seq:rhs().gradInput,
    'The outputs should be equal.'
  )
end

