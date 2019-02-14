require 'oc.math.relation'
require 'oc.var'

function octest.math_relation_le_with_true()
  local name = 'nn1'
  local input = 2
  local input2 = 2
  local input3 = 3
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  local var3 = oc.Var(input2)
  nn1 = var:le(var2)
  nn2 = var:le(var3)
  local output = nn1:probe()
  local output2 = nn2:probe()
  
  octester:eq(
    output, true,
    'Output should be true'
  )
  octester:eq(
    output, true,
    'Output should be true'
  )
end

function octest.math_relation_le_with_false()
  local name = 'nn1'
  local input = 2
  local input2 = 1
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var:le(var2)
  local output = nn1:probe()
  
  octester:eq(
    output, false,
    'Output should be false'
  )
end

function octest.math_relation_lt_with_true()
  local name = 'nn1'
  local input = 2
  local input2 = 3
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var:le(var2)
  local output = nn1:probe()
  
  octester:eq(
    output, true,
    'Output should be true'
  )
end

function octest.math_relation_lt_with_false()
  local name = 'nn1'
  local input = 2
  local input2 = 1
  local input3 = 2
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  local var3 = oc.Var(input3)
  nn1 = var:lt(var2)
  nn2 = var:lt(var3)
  local output = nn1:probe()
  local output2 = nn2:probe()
  
  octester:eq(
    output, false,
    'Output should be false'
  )
  octester:eq(
    output2, false,
    'Output should be false'
  )
end

function octest.math_relation_ge_with_true()
  local name = 'nn1'
  local input = 2
  local input2 = 2
  local input3 = 1
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  local var3 = oc.Var(input2)
  nn1 = var:ge(var2)
  nn2 = var:ge(var3)
  local output = nn1:probe()
  local output2 = nn2:probe()
  
  octester:eq(
    output, true,
    'Output should be true'
  )
  octester:eq(
    output, true,
    'Output should be true'
  )
end

function octest.math_relation_ge_with_false()
  local name = 'nn1'
  local input = 0
  local input2 = 1
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var:ge(var2)
  local output = nn1:probe()
  
  octester:eq(
    output, false,
    'Output should be false'
  )
end

function octest.math_relation_gt_with_true()
  local name = 'nn1'
  local input = 3
  local input2 = 2
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var:gt(var2)
  local output = nn1:probe()
  
  octester:eq(
    output, true,
    'Output should be true'
  )
end

function octest.math_relation_gt_with_false()
  local name = 'nn1'
  local input = 2
  local input2 = 2
  local input3 = 3
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  local var3 = oc.Var(input3)
  nn1 = var:gt(var2)
  nn2 = var:gt(var3)
  local output = nn1:probe()
  local output2 = nn2:probe()
  
  octester:eq(
    output, false,
    'Output should be false'
  )
  octester:eq(
    output2, false,
    'Output should be false'
  )
end

function octest.math_relation_eq_with_true()
  local name = 'nn1'
  local input = 2
  local input2 = 2
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var:eq(var2)
  local output = nn1:probe()
  
  octester:eq(
    output, true,
    'Output should be true'
  )
end

function octest.math_relation_eq_with_false()
  local name = 'nn1'
  local input = 2
  local input2 = 1
  local input3 = 3
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  local var3 = oc.Var(input3)
  nn1 = var:eq(var2)
  nn2 = var:eq(var3)
  local output = nn1:probe()
  local output2 = nn2:probe()
  
  octester:eq(
    output, false,
    'Output should be false'
  )
  octester:eq(
    output2, false,
    'Output should be false'
  )
end

function octest.math_relation_neq_with_true()
  local name = 'nn1'
  local input = 2
  local input2 = 1
  local input3 = 3
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  local var3 = oc.Var(input3)
  nn1 = var:neq(var2)
  nn2 = var:neq(var3)
  local output = nn1:probe()
  local output2 = nn2:probe()
  
  octester:eq(
    output, true,
    'Output should be true'
  )
  octester:eq(
    output2, true,
    'Output should be true'
  )
end

function octest.math_relation_neq_with_false()
  local name = 'nn1'
  local input = 2
  local input2 = 2
  local var = oc.Var(input)
  local var2 = oc.Var(input2)
  nn1 = var:neq(var2)
  local output = nn1:probe()
  
  octester:eq(
    output, false,
    'Output should be false'
  )
end






