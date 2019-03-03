require 'oc.ops.pkg'
require 'oc.class'

oc.ops.module = {}


--- @param mod - oc.Nerve or oc.Strand
-- @return leaf and root of the stream - oc.Nerve, oc.Nerve
--         if what is passed in is an oc.Nerve then
--         it simply returns two pointers to the nerve
function oc.ops.module.getBounds(mod)
  local root, leaf
  if oc.type(mod) == 'oc.Strand' then
    leaf = mod:rhs()
    root = mod:root()
  else
    root = mod
    leaf = mod
  end
  return root, leaf
end
