require 'ocnn.ocnn'


function octest.deep_update()
  local table1 = {
    y=torch.Tensor{2, 3}
  }
  toUpdate = {}
  ocnn.deepUpdate(toUpdate, table1)
  octester:assert(
    table1.y:eq(toUpdate.y) and
    table1.y ~= toUpdate.y,
    'Tensors must have equal value but be different tensors.'
    
  )
end

function octest.deep_update_with_nested()
  local table1 = {
    y={
      z=torch.Tensor{2, 3}
    }
  }
  toUpdate = {}
  ocnn.deepUpdate(toUpdate, table1)
  octester:assert(
    table1.y.z:eq(toUpdate.y.z) and
    table1.y.z ~= toUpdate.y.z,
    'Tensors must have equal value but be different tensors.'
    
  )
end


function octest.deep_update_with_two_nested()
  local table1 = {
    y={
      z=2
    }
  }
  toUpdate = {}
  ocnn.deepUpdate(toUpdate, table1)
  octester:assert(
    table1.y.z == toUpdate.y.z,
    'Values of tables should be equal.'
    
  )
  octester:assert(
    table1.y ~= toUpdate.y,
    'Tables should not be the same.'
    
  )
end


function octest.deep_update_with_nn_linear()
  local table1 = nn.Linear(2, 2)
  toUpdate = {}
  ocnn.deepUpdate(toUpdate, table1)
  octester:assert(
    oc.isTypeOf(toUpdate, nn.Linear),
    'Tables should not be the same.'
    
  )
  octester:eq(
    toUpdate.weight, table1.weight,
    'Values of tables should be equal.'
  )
end
