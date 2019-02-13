require 'oc.ops.pkg'
require 'oc.ops.tensor'

if oc.ops.math then
  return
end

oc.ops.math = {}
local mathops = oc.ops.math

function mathops.mul(lhs, rhs)
  return lhs * rhs
end

function mathops.div(lhs, rhs)
  if lhs and rhs then
    return lhs / rhs
  else
    return lhs
  end
  -- return lhs / rhs
end

function mathops.add(lhs, rhs)
  return lhs + rhs
end

function mathops.sub(lhs, rhs)
	return lhs - rhs
end

local function tableOp(lhs, rhs, op)
  local result = {}
  --! TODO: maybe I do want to use 
  --! a table class rather than just a table so 
  --! I don't need this
  for i=1, math.max(table.maxn(lhs), table.maxn(rhs)) do
    result[i] = mathops.opIfNotNil(lhs[i], rhs[i], op)
  end
  return result
end

function mathops.opIfNotNil(lhs, rhs, op)
  
  if lhs and rhs and 
     not oc.ops.tensor.isNullTensor(lhs) and 
     not oc.ops.tensor.isNullTensor(rhs) then
    return op(lhs, rhs)
  elseif rhs then
    return rhs
  else
    return lhs
  end
end

function mathops.baseOp(lhs, rhs, op)
  if oc.type(lhs) == 'table' and oc.type(rhs) == 'table' then
    return tableOp(lhs, rhs, op)
  else
    return mathops.opIfNotNil(lhs, rhs, op)
  end
end

function mathops.addIfNotNil(lhs, rhs)
  return mathops.baseOp(lhs, rhs, mathops.add)
end

function mathops.mulIfNotNil(lhs, rhs)
  return mathops.baseOp(lhs, rhs, mathops.mul)
end

function mathops.subIfNotNil(lhs, rhs)
  return mathops.baseOp(lhs, rhs, mathops.sub)
end

function mathops.divIfNotNil(lhs, rhs)
  return mathops.baseOp(lhs, rhs, mathops.div)
  --if lhs and rhs then
    -- return lhs / rhs
  --else
    --return lhs
  --end
end

function mathops.boolToInt(value)
  if value == true then
    return 1
  else
    return 0
  end
end

function mathops.sumIfNotNil(values)
  local result
  for i=1, #values do
    result = mathops.addIfNotNil(result, values[i])
  end
  return result
end

