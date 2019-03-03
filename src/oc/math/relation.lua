require 'oc.math.pkg'
require 'oc.nerve'
require 'oc.class'
require 'oc.oc'
require 'oc.flow.merge'


--- Relational operations to be used on numbers
-- or other values that can be compared.
-- @input    number
-- @output   boolean
local Relation, parent = oc.class(
  'oc.Relation', oc.Nerve
)

oc.Relation = Relation
do
  --- Tests whether the lhs value is
  -- < the rhs value
  -- @input    number
  -- @output   boolean
  local LT, parent = oc.class(
    'oc.LT', Relation
  )
  oc.LT = LT

  function LT:out(input)
    return input[1] < input[2]
  end
end


do
  --- Tests whether the lhs value is <= the rhs value
  -- @input    number
  -- @output   boolean
  -- 
  local LE, parent = oc.class(
    'oc.LE', Relation
  )
  oc.LE = LE
  
  function LE:out(input)
    return input[1] <= input[2]
  end
end


do
  --- Tests whether the lhs value is > the rhs value
  -- @input    number
  -- @output   boolean
  local GT, parent = oc.class(
    'oc.GT', Relation
  )
  oc.GT = GT
  
  function GT:out(input)
    return input[1] > input[2]
  end
end


do
  --- Tests whether the lhs value is >= the rhs value
  -- @input    number
  -- @output   boolean
  local GE, parent = oc.class(
    'oc.GE', Relation
  )
  oc.GE = GE
  
  function GE:out(input)
    return input[1] >= input[2]
  end
end


do
  --- Tests whether the lhs value is >= the rhs value
  -- @input    number
  -- @output   boolean
  local EQ, parent = oc.class(
    'oc.EQ', Relation
  )
  oc.EQ = EQ

  function EQ:out(input)
    return input[1] == input[2]
  end
end

do
  --- Tests whether the lhs value is ! 
  -- the rhs value
  -- @input    number
  -- @output   boolean
  local NEQ, parent = oc.class(
    'oc.NEQ', Relation
  )  
  oc.NEQ = NEQ

  function NEQ:out(input)
    return input[1] ~= input[2]
  end
end


function oc.Nerve.le(lhs, rhs)
  --! 
	return lhs .. oc.Merge(rhs) .. oc.LE()
end

function oc.Nerve.lt(lhs, rhs)
	return lhs .. oc.Merge(rhs) ..oc.LT()
end

function oc.Nerve.ge(lhs, rhs)
	return lhs .. oc.Merge(rhs)..oc.GE()
end

function oc.Nerve.gt(lhs, rhs)
	return lhs .. oc.Merge(rhs) .. oc.GT()
end

function oc.Nerve.eq(lhs, rhs)
	return lhs .. oc.Merge(rhs) .. oc.EQ()
end

function oc.Nerve.neq(lhs, rhs)
  return lhs .. oc.Merge(rhs) ..oc.NEQ()
end
