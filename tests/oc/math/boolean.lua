require 'oc.math.boolean'
require 'oc.coalesce'


function octest.math_boolean_and()
  local name = 'nn1'
  local input = true
  local input2 = false
  local input3 = true
  local var = oc.Coalesce(input)
  local var2 = oc.Coalesce(input2)
  local var3 = oc.Coalesce(input3)
  nn1 = var:AND(var2)
  nn2 = var:AND(var3)
  local output = nn1:probe()
  local output2 = nn2:probe()
  octester:eq(
    output2, true,
    'Output should be true'
  )
  octester:eq(
    output, false,
    'Output should be false'
  )
end

function octest.math_boolean_or()
  local name = 'nn1'
  local input = false
  local input2 = false
  local input3 = true
  local var = oc.Coalesce(input)
  local var2 = oc.Coalesce(input2)
  local var3 = oc.Coalesce(input3)
  nn1 = var:OR(var2)
  nn2 = var:OR(var3)
  local output = nn1:probe()
  local output2 = nn2:probe()
  octester:eq(
    output2, true,
    'Output should be true'
  )
  octester:eq(
    output, false,
    'Output should be false'
  )
end

function octest.math_boolean_nor()
  local name = 'nn1'
  local input = false
  local input2 = false
  local input3 = true
  local var = oc.Coalesce(input)
  local var2 = oc.Coalesce(input2)
  local var3 = oc.Coalesce(input3)
  nn1 = var:NOR(var2)
  nn2 = var:NOR(var3)
  local output = nn1:probe()
  local output2 = nn2:probe()
  octester:eq(
    output2, false,
    'Output should be false'
  )
  octester:eq(
    output, true,
    'Output should be true'
  )
end

function octest.math_boolean_xor()
  local name = 'nn1'
  local input = true
  local input2 = false
  local input3 = true
  local var = oc.Coalesce(input)
  local var2 = oc.Coalesce(input2)
  local var3 = oc.Coalesce(input3)
  nn1 = var:XOR(var2)
  nn2 = var:XOR(var3)
  local output = nn1:probe()
  local output2 = nn2:probe()
  octester:eq(
    output2, false,
    'Output should be false'
  )
  octester:eq(
    output, true,
    'Output should be true'
  )
end
