
do
  require 'ocnn.ocnn'
  
  local table1 = {
    y=torch.Tensor{2, 3}
  }
  toUpdate = {}
  ocnn.deepUpdate(toUpdate, table1)
  assert(
    table1.y:eq(toUpdate.y) and
    table1.y ~= toUpdate.y,
    'Tensors must have equal value but be different tensors.'
    
  )
  
end

do
  require 'ocnn.ocnn'
  
  local table1 = {
    y={
      z=torch.Tensor{2, 3}
    }
  }
  toUpdate = {}
  ocnn.deepUpdate(toUpdate, table1)
  assert(
    table1.y.z:eq(toUpdate.y.z) and
    table1.y.z ~= toUpdate.y.z,
    'Tensors must have equal value but be different tensors.'
    
  )
end


do
  require 'ocnn.ocnn'
  
  local table1 = {
    y={
      z=2
    }
  }
  toUpdate = {}
  ocnn.deepUpdate(toUpdate, table1)
  assert(
    table1.y.z == toUpdate.y.z,
    'Values of tables should be equal.'
    
  )
  assert(
    table1.y ~= toUpdate.y,
    'Tables should not be the same.'
    
  )
end


do
  require 'ocnn.ocnn'
  
  local table1 = nn.Linear(2, 2)
  toUpdate = {}
  ocnn.deepUpdate(toUpdate, table1)
  assert(
    oc.type(toUpdate, 'nn.Linear'),
    'Tables should not be the same.'
    
  )
  assert(
    toUpdate.weight:eq(table1.weight),
    'Values of tables should be equal.'
    
  )
end
