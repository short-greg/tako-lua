require 'oc.ops.pkg'

--!	@usage	
--!
--!

local ops = oc.ops

--! 
function ops.otherwise(cond, ifTrue, ifFalse)
  if cond then return ifTrue else return ifFalse end
end


function ops.is(val1, val2)
  --! Check if val1 and val2 point to the same value
  --! Will also return true if both are nil
  --! @param val1 val to check
  --! @param val2 val to check against
  --! @return true if both point to the same value
  return (val1 == nil and val2 == nil) or
         (
           val1 ~= nil and val2 ~= nil and 
           torch.pointer(val1) == torch.pointer(val2)
         )
end


function ops.pointer(val)
  if val == nil then
    return nil
  else
    return torch.pointer(val)
  end
end
