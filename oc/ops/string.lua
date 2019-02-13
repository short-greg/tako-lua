require 'oc.ops.pkg'

oc.ops.string = {}

local str = oc.ops.string

--!	String utility functions
--!
--! str.tokenize(input, by)
--! str.createTable

--! @brief Expand a sample tensor to the same number of dimensions in
--! https://stackoverflow.com/questions/1426954/split-string-in-lua
function str.tokenize(input, by)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for s in string.gmatch(input, "([^"..by.."]+)") do
    t[i] = s
    i = i + 1
  end
  return t
end

function str.createTable(strSeq)
  local res = {}
  local cur = res
  for i=1, #strSeq do
    cur[strSeq[i]] = {}
    cur = cur[strSeq[i]]
  end
  return res
end
