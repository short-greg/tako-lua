require 'oc.math.pkg'
require 'oc.class'
require 'oc.oc'
require 'oc.nerve'
require 'oc.flow.merge'


--- Modules used for doing basic arithmetic such as
-- subtraction (oc.Sub), addition (oc.Add), 
-- multiplication (oc.Mul)
-- division (oc.Div), and exponentiation (oc.Exp)
local BasicArithmetic = oc.class(
  'oc.math.BasicArithmetic', oc.Nerve
)
oc.math.BasicArithmetic = BasicArithmetic


do
  local Sub, parent = oc.class(
    'oc.math.Sub', BasicArithmetic
  )
  --! Subtract the output of one module 
  --! from the otherz
  
  oc.math.Sub = Sub
  
  function Sub:out(input)
    return input[1] - input[2]
  end

  function Sub:grad(input, gradOutput)
    return {
        gradOutput,
        -gradOutput
    }
  end
end


do
  --- Add the output of one module to another
  local Add, parent = oc.class(
    'oc.math.Add', BasicArithmetic
  )
  oc.math.Add = Add

  function Add:out(input)
    return input[1] + input[2]
  end
  
  function Add:updateGradInput(input, gradOutput) 
    return {
      gradOutput,
      gradOutput
    }
  end
end


do
  --- Multiply one module by another
  local Mul, parent = oc.class(
    'oc.math.Mul', BasicArithmetic
  )
  oc.math.Mul = Mul
  
  function Mul:out(input)
    local output
    assert(
      #input == 2, 
      'Size of input into multiplier must be two'
    )
    if oc.isTypeOf(input[2], torch.Tensor) 
      and oc.isTypeOf(input[1], torch.Tensor) then
      output = torch.cmul(input[1], input[2])
    else
      output = input[1] * input[2]
    end
    return output
  end

  function Mul:grad(input, gradOutput) 
    local gradInput = {}
    if oc.isTypeOf(input[2], torch.Tensor) 
      and oc.isTypeOf(input[1], torch.Tensor) then
      gradInput[1] = torch.cmul(gradOutput, input[2])
      gradInput[2] = torch.cmul(gradOutput, input[1])
    else
      gradInput[1] = gradOutput * input[2]
      gradInput[2] = gradOutput * input[1]
    end
    return gradInput
  end
end


do
  --- Divide the output of one nere by 
  -- the output of another
  -- @input Dividable value
  -- @output the output of the division
  local Div, parent = oc.class(
    'oc.math.Div', BasicArithmetic
  )
  oc.math.Div = Div

  function Div:out(input)
    assert(
      #input == 2, 
      'Size of input into multiplier must be two'
    )
    if oc.isTypeOf(input[2], torch.Tensor) 
      and oc.isTypeOf(input[1], torch.Tensor) then
      output = torch.cdiv(input[1], input[2])
    else
      output = input[1] / input[2]
    end
    return output
  end

  function Div:grad(input, gradOutput)
    local gradInput = {}
    if oc.isTypeOf(input[2], torch.Tensor) 
      and oc.isTypeOf(input[1], torch.Tensor) then

      gradInput[1] = torch.cmul(
        gradOutput, torch.pow(input[2], -1)
      )
      gradInput[2] = torch.cdiv(
        torch.log(torch.cmul(input[2], input[1])), 
        gradOutput
      )
    else
      gradInput[1] = gradOutput / input[2]
      gradInput[2] = torch.log(input[2] * input[1]) * gradOutput
    end
    return gradInput
  end
end


do
  --- @input exponentiated value
  local Exp, parent = oc.class(
    'oc.math.Exp', BasicArithmetic
  )
  oc.math.Exp = Exp

  function Exp:out(input)
    assert(
      #input == 2, 
      'Size of input into multiplier must be two'
    )
    return input[1] ^ input[2]
  end
  
  function Exp:grad(input, gradOutput)
    return {
      gradOutput * input[2] * input[1]^(input[2] - 1),
      gradOutput * input[1]^input[2]
    }
  end
end

---	Add two modules together
--	@return	octo.Composite
function oc.Nerve.__add__(lhs, rhs)
	return lhs .. oc.Merge(rhs) .. oc.math.Add()
end

---	Subtract one module from another
-- @return octo.Composite
function oc.Nerve.__sub__(lhs, rhs)
  return lhs .. oc.Merge(rhs) .. oc.math.Sub()
end

--- Multiply two modules together
--	@return	oc.Strand x * y
function oc.Nerve.__mul__(lhs, rhs)
  return lhs .. oc.Merge(rhs) .. oc.math.Mul()
end

---	Divide one module from the other
-- @param lhs
-- @param rhs
-- @return oc.Strand
function oc.Nerve.__div__(lhs, rhs)
	return lhs .. oc.Merge(rhs) .. oc.math.Div()
end

--- Power of elements of one module to another
--	@return oc.Strand
function oc.Nerve.__exp__(lhs, rhs)
	return lhs .. oc.Merge(rhs) .. oc.math.Exp()
end
