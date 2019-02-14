require 'oc.ops.pkg'
require 'oc.oc'
oc.ops.table = {}


function oc.ops.table.zip(...)
  --!
  --!
  --!
  local i = 0
  local values = table.pack(...)
  
  local iterate = function()
    i = i + 1
    local result = {}
    if i < #values[1] then
      return
    end
    for j = 1, j <= #values do
      table.insert(result, values[j][i])
    end
    return table.unpack(result)
  end
  return iterate
end

function oc.ops.table.listCopy(list)
  local res = {}
  for i=1, #list do
    table.insert(res, list[i])
  end
  return res
end


function oc.ops.table.deepCopy(toCopy, alreadyCopied)
  --! Perform a deep copy on a 'table' (from torch.type)
  --! NOTE: Does not deep copy torch userdata
  --!       like tensors.. Those will need to be cloned.
  --! @param toCopy - the table to copy
  --! @param alreadyCopied - tables that were already
  --!       copied to prevent infinite 
  --!       looping - nil or table
  --! @return {copied table}
  alreadyCopied = alreadyCopied or {}
  
  if alreadyCopied[toCopy] then
    return alreadyCopied[toCopy]
  end
  
  local copied = {}
  local parent = getmetatable(toCopy)

  if parent and 
     parent.__constructor and 
     parent.__constructor == toCopy then
    return toCopy
  end
  
  setmetatable(copied, parent)
  alreadyCopied[toCopy] = copied
  
  for k, v in pairs(toCopy) do
    if type(v) == 'table' then
      local child = oc.ops.table.deepCopy(
        v, alreadyCopied
      )
      rawset(copied, k, child)
    else
      rawset(copied, k, v)
    end
  end
  return copied
end

function oc.ops.table.shallowCopy(toCopy)
  --! @summary Perform a shallow 1 layer copy 
  --! on a 'table' (from torch.type)
  --! @return {copied table}
  local copied = {}
  for k, v in pairs(toCopy) do
    copied[k] = v
  end
  return copied
end

function oc.ops.table.listCat(...)
  --! @summary
  local tabs = table.pack(...)
  local res = {}
  for i=1, #tabs do
    for j=1, #tabs[i] do
      table.insert(res, tabs[i][j])
    end
  end
  return res
end

function oc.ops.table.contains(tab, val)
  for i=1, #tab do
    if tab[i] == val then
      return true
    end
  end
  return false
end

--! TODO: Remove??
function oc.ops.table.updateRefs(tab, oldModule, newModule)
  assert(
    type(oldValue) == 'table' and type(newValue) == 'table',
    'References must be tables'
  )
  local oldPointer = torch.pointer(oldValue)
  for k, v in pairs(tab) do
    if torch.pointer(v) == oldPointer then
      tab[k] = newValue
    end
  end
end

--! @brief Update a table with the values from another table
--! @param toUpdate - the table to update - {}
--! @param updateWith -- the table to update with - {}
function oc.ops.table.update(toUpdate, updateWith)
  for k, v in pairs(updateWith) do
    toUpdate[k] = v
  end
end


--! @brief Do a full unpack of the values in a table
--!        The regular unpack will only unpack up to the first
--!        nil
--! @param input - table
function oc.ops.table.unpack(input)
  return table.unpack(input, 1, table.maxn(input))
end


function oc.ops.table.serialize(table_)
  local serialized = '{'
  for i=1, #table_ do
    if oc.type(table_[i]) == 'table' then
      serialized = serialized .. ' ' .. 
                   oc.ops.table.serialize(table_[i])
    else
      serialized = serialized .. ' ' .. tostring(table_[i])
    end
  end
  serialized = serialized .. '}'
  return serialized
end


function oc.ops.table.copyInto(to, from)
  -- erase values in to
  for k, v in pairs(to) do
    to[k] = nil
  end
  
  setmetatable(to, getmetatable(from))
  for k, v in pairs(from) do
    to[k] = v
  end
end
