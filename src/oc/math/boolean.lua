require 'oc.math.pkg'
require 'oc.nerve'
require 'oc.class'
require 'oc.oc'
require 'oc.flow.merge'


local BooleanArithmetic, parent = oc.class(
  'oc.math.BooleanArithmetic', oc.Nerve
)
oc.math.BooleanArithmetic = BooleanArithmetic

--! Base class for performing basic arithmetic
--! on modules


do
  local AND, parent = oc.class(
    'oc.math.AND', BooleanArithmetic
  )
  
  oc.math.AND = AND
  
  function AND:out(input)
    return input[1] and input[2]
  end
end


do
  local OR, parent = oc.class(
    'oc.math.OR', BooleanArithmetic
  )
  
  oc.math.OR = OR
  
  function OR:out(input)
    return input[1] or input[2]
  end
end

do
  local NOR, parent = oc.class(
    'oc.math.NOR', BooleanArithmetic
  )
  
  oc.math.NOR = NOR
  
  function NOR:out(input)
    return not (input[1] or input[2])
  end
end


do
  local XOR, parent = oc.class(
    'oc.math.XOR', BooleanArithmetic
  )
  
  oc.math.XOR = XOR
  
  function XOR:out(input)
      return (input[1] or input[2]) and not 
                     (input[1] and input[2])
  end
end

function oc.Nerve.AND(lhs, rhs)
  return lhs .. oc.Merge(rhs)..oc.math.AND()
end

function oc.Nerve.OR(lhs, rhs)
  return lhs .. oc.Merge(rhs) .. oc.math.OR()
end

function oc.Nerve.NOR(lhs, rhs)
  return lhs .. oc.Merge(rhs) ..oc.math.NOR()
end

function oc.Nerve.XOR(lhs, rhs)
  return lhs .. oc.Merge(rhs) ..oc.math.XOR()
end
