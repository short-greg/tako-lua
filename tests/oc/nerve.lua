require 'oc.nerve'
require 'oc.noop'
require 'oc.chain'
require 'oc.const'


function octest.oc_nerve_concat_with_two()
  local nn2 = oc.Noop()
  local nn1 = (oc.Noop() .. nn2):lhs()
  octester:asserteq(
    nn2:incoming(), nn1, 
    'Incoming module after concat must '..
    'be equal to concatenated module'
  )
  octester:asserteq(
    nn1:outgoing()[1], nn2,
    'Outgoing module after concat '..
    'must be equal to concatenated module'
  )
end

function octest.oc_module_concat_with_two_streams()
  local nn3 = oc.Noop()
  local nn2 = oc.Noop()
  local nn1 = (oc.Noop().. nn2):lhs()
  nn1 = (nn1 .. nn3):lhs()
  octester:asserteq(
    nn2:incoming(), nn1, 
    'Incoming module after concat must '.. 
    'be equal to concatenated module'
  )
  octester:asserteq(
    nn1:outgoing()[1], nn2,
    'Outgoing module after concat must '..
    'be equal to concatenated module'
  )
  octester:asserteq(
    nn1:outgoing()[2], nn3,
    'Outgoing module after concat must be '..
    'equal to concatenated module'
  )
end

function octest.oc_module_concat_with_three()
  local nn2 = oc.Noop()
  local nn1 = (oc.Noop().. nn2  .. nn.Linear(2, 2)):lhs()
  octester:asserteq(
    nn2:incoming(), nn1, 
    'Incoming module after concat must '..
    'be equal to concatenated module'
  )
  octester:asserteq(
    nn1:outgoing()[1], nn2,
    'Outgoing module after concat must be '..
    'equal to concatenated module'
  )
end

function octest.oc_module_lab()
  local name = 'nn1'
  local nn1 = oc.Noop():label(name)
  
  octester:asserteq(
    nn1.name, name, 
    "The tentacles label must be "..name
  )
end


function octest.oc_module_inform()
  local name = 'nn1'
  local nn1 = oc.Noop():label(name)
  local input = torch.randn(1, 4)
  octester:asserteq(
    nn1._relaxed, true,
    'Module should be relaxed before informing'
  )
  nn1:inform(input)
  octester:asserteq(
    nn1.input, input, 
    "Input to module should change after informing"
  )
  octester:asserteq(
    nn1:relaxed(), true,
    'Module should be relaxed after informing'
  )
end


function octest.oc_module_probe()
  local name = 'nn1'
  local nn2 = oc.Noop():label('nn2')
  local nn1 = (oc.Noop():label(name) .. nn2):lhs()
  local input = torch.zeros(1, 2)
  nn1:inform(input)
  local output = nn2:probe(input)
  octester:asserteq(
    nn2:relaxed(), false, 
    "Should not be relaxed after informing"
  )
  octester:asserteq(
    torch.type(output), torch.type(input),
    'Output should be a tensor'
  )
end

function octest.oc_nerve_relax_all()
  local name = 'nn1'
  local nn2 = oc.Noop():label('nn2')
  local nn3 = oc.Noop():label('nn3')
  local nn1 = (oc.Noop():label(name) .. nn2):lhs()
  nn1 = (nn1 .. nn3):lhs()
  local input = torch.zeros(1, 2)
  nn1:inform(input)
  local output = nn3:probe(input)
  nn1:relax()
  octester:asserteq(
    nn1:relaxed(), true, 
    "Output of nn1 should be relaxed after relaxing"
  )
  octester:asserteq(
    nn2:relaxed(), true, 
    "Output of nn2 should still be relaxed (not probed)"
  )
  octester:asserteq(
    nn3:relaxed(), false, 
    "Output of nn3 should not be relaxed after relaxing nn1"
  )
end

function octest.oc_nerve_unlink_with_two()
  local nn2 = oc.Noop()
  local nn1 = (oc.Noop() .. nn2):lhs()
  octester:asserteq(
    nn2:incoming(), nn1, 
    "Incoming module after concat must be equal to concatenated module"
  )
  octester:asserteq(
    nn1:outgoing()[1], nn2,
    'Outgoing module after concat must be equal to concatenated module'
  )
end


function octest.oc_nerve_get_seq()
  local nn1 = oc.Noop():label('nn1')
  local nn2 = oc.Noop():label('nn2')
  local nn3 = oc.Noop():label('nn3')
  local chain = nn1 .. nn2 .. nn3
  local modules, found = nn3:getSeq(nn1)
  octester:eq(
    modules[1].name, nn1.name,
    'The sequences are not equal'
  )
  octester:eq(
    modules[2].name, nn2.name,
    'The sequences are not equal'
  )
  octester:eq(
    modules[3].name, nn3.name,
    'The sequences are not equal'
  )
end

function octest.oc_nerve_get_seq_no_from()
  local nn1 = oc.Noop():label('nn1')
  local nn2 = oc.Noop():label('nn2')
  local nn3 = oc.Noop():label('nn3')
  local chain = nn1 .. nn2 .. nn3
  local modules, found = nn3:getSeq()
  octester:eq(
    modules[1].name, nn1.name,
    'The sequences are not equal'
  )
  octester:eq(
    modules[2].name, nn2.name,
    'The sequences are not equal'
  )
  octester:eq(
    modules[3].name, nn3.name,
    'The sequences are not equal'
  )
end

function octest.oc_nerve_get_invalid_seq()
  local nn1 = oc.Noop():label('nn1')
  local nn2 = oc.Noop():label('nn2')
  local nn3 = oc.Noop():label('nn3')
  local chain = nn2 .. nn3
  local modules, found = nn3:getSeq(nn1)
  --print(modules)
  octester:asserteq(
    found, false,
    'Should not be able to retrieve the sequence'
  )
end

function octest.oc_nerve_get_length()
  local nn1 = oc.Noop():label('nn1')
  local nn2 = oc.Noop():label('nn2')
  local nn3 = oc.Noop():label('nn3')
  local chain = nn1 .. nn2 .. nn3
  local length = nn3:getLength(nn1)
  octester:eq(
    length, 3,
    'The length of the sequence is invalid.'
  )
end

function octest.oc_nerve_get_invalid_length()
  local nn1 = oc.Noop():label('nn1')
  local nn2 = oc.Noop():label('nn2')
  local nn3 = oc.Noop():label('nn3')
  local chain = nn2 .. nn3
  if pcall(nn3.getLength, nn3, nn1) then
    error('Should not be able to retrieve the sequence')
  end
end
