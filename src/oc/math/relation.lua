require 'oc.math.pkg'
require 'oc.nerve'
require 'oc.class'
require 'oc.oc'
require 'oc.flow.merge'


local Relation, parent = oc.class(
  'oc.Relation', oc.Nerve
)

oc.Relation = Relation
--! 
--! Relational operations to be used on numbers
--! or other values that can be compared.
--! @input    number
--! @output   boolean
--!
do
  local LT, parent = oc.class(
    'oc.LT', Relation
  )
  --! 
  --! Tests whether the lhs value is
  --! < the rhs value
  --! @input    number
  --! @output   boolean
  --!

  oc.LT = LT

  function LT:out(input)
    return input[1] < input[2]
  end
end


do
  local LE, parent = oc.class(
    'oc.LE', Relation
  )
  --! 
  --! Tests whether the lhs value is <= the rhs value
  --! @input    number
  --! @output   boolean
  --! 
  
  oc.LE = LE
  
  function LE:out(input)
    return input[1] <= input[2]
  end
end


do
  local GT, parent = oc.class(
    'oc.GT', Relation
  )
  --! 
  --! Tests whether the lhs value is > the rhs value
  --! @input    number
  --! @output   boolean
  --! 
  
  oc.GT = GT
  
  function GT:out(input)
    return input[1] > input[2]
  end
end


do
  local GE, parent = oc.class(
    'oc.GE', Relation
  )
  --! 
  --! Tests whether the lhs value is >= the rhs value
  --! @input    number
  --! @output   boolean
  --! 
  oc.GE = GE
  
  function GE:out(input)
    return input[1] >= input[2]
  end
end


do
  local EQ, parent = oc.class(
    'oc.EQ', Relation
  )
  --!
  --! Tests whether the lhs value is >= the rhs value
  --! @input    number
  --! @output   boolean
  --!
  
  oc.EQ = EQ
  function EQ:out(input)
    return input[1] == input[2]
  end
end

do
  local NEQ, parent = oc.class(
    'oc.NEQ', Relation
  )
  
  oc.NEQ = NEQ
  
  function NEQ:out(input)
    --! Tests whether the lhs value is ! 
    --! the rhs value
    --! @input    number
    --! @output   boolean
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
