require 'ocnn.pkg'
require 'oc.oc'

function ocnn.tensorSizeEqual(tensor1, tensor2)
  return tostring(tensor1:size()) == 
         tostring(tensor2:size())
end

function ocnn.clone(val)
  if type(val) == 'userdata' or type(val) == 'table' then
    return torch.deserialize(torch.serialize(val))
  end
  return val
end

function ocnn.updateTensor(into, from)
  if into == nil then
    into = from:clone()
  elseif into:isSameSizeAs(
    from
  ) then 
    into:copy(from)
  else
    into:typeAs(
      from
    ):resizeAs(
      from
    ):copy(from)
  end
  --self._tensorMap[torch.pointer(from)] = into
  return into
end


function ocnn.deepUpdate(
    toUpdate, updateWith, alreadyUpdated
  )
  --! Perform a deep copy on a 'table' (from torch.type)
  --! @param toCopy - the table to copy
  --! @param alreadyCopied - tables that were already
  --!       copied to prevent infinite 
  --!       looping - nil or table
  --! @return {copied table}
  alreadyCopied = alreadyCopied or {}
  
  if alreadyCopied[updateWith] then
    return alreadyCopied[updateWith]
  end

  local parent = getmetatable(updateWith)

  if parent and 
     parent.__constructor and 
     parent.__constructor == updateWith then
    return
  end
  
  setmetatable(toUpdate, parent)
  alreadyCopied[toUpdate] = toUpdate
  
  for k, v in pairs(updateWith) do
    if torch.isTypeOf(v, torch.Tensor) then
      -- tensor Copy
      if not torch.isTypeOf(toUpdate[k], torch.Tensor) then
        toUpdate[k] = v:clone()
      else
        toUpdate[k]:resizeAs(v):copy(v)
      end
    elseif type(v) == 'table' then
      toUpdate[k] = {}
      local child = ocnn.deepUpdate(
        toUpdate[k], v, alreadyCopied
      )
    else
      toUpdate[k] = v
    end
  end
end


function ocnn.updateVal(val, with)
  if oc.type(val) ~= oc.type(with) then
    val = nil
  end
  
  if oc.type(with) == 'table' and oc.type(val) == 'table' then
    for k, v in pairs(val) do
      if with[k] == nil then
        --! TODO: is this okay?
        val[k] = nil
      end
    end
  elseif oc.type(with) == 'table' then
    val = {}
  end
  
  if oc.type(with) == 'table' then
    for k, v in pairs(with) do
      val[k] = ocnn.updateVal(val[k], v)
    end
  elseif oc.isTypeOf(with, torch.Tensor) then
    val = ocnn.updateTensor(val, with)
  else
    val = with
  end
  return val
end
