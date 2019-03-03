require 'oc.pkg'

--- Module: oc (utility functions for oc)
-- 
-- oc.type(value) -> returns the type of class
-- oc.isTypeOf(value, class) -> returns true or false
-- os.isInstance(value) -> whether the value is an
--    instance of a class
--
-- Some of these are redundant with the
-- utility functions in torch, but to ensure
-- that torch was not a requirement tese were 
-- included


--- @param obj1 - The object to retrieve the type for
-- @return - The type of the object - boolean
function oc.type(obj1)
  if type(obj1) == 'table' and obj1.__typename then
    return obj1.__typename
  elseif torch then
    return torch.type(obj1)
  else
    return type(obj1)
  end
end

--- Helper function to determine if an object
-- is of a particular type
-- @param obj1 - object ot test if of
-- type clsStr
-- @param clsStr - the string for the class name
-- @return true if obj1 is of type clsStr
local function isTypeOf(obj1, clsStr)

  local parent = getmetatable(obj1)
  local myType = type(obj1)

  if myType == clsStr then
    return true
  end
  
  if myType ~= 'table' and parent then
    return isTypeOf(parent, clsStr)
  end
  
  if myType == 'table' and oc.type(obj1) == clsStr then
    return true
  end
  
  if parent then
    return isTypeOf(parent, clsStr)
  else
    return false
  end
end

--- see if obj1 is of type obj2.  Works like 
-- torch.isTypeOf..
-- @param obj1 - object created with oc.Class 
-- (or torch.class)
-- @param obj2 - object created with oc.Class 
-- (or torch.class) or string of object name
-- @return - true if obj1 is of type obj2 else false
function oc.isTypeOf(obj1, obj2)
  if oc.type(obj2) == 'string' then
    return isTypeOf(obj1, obj2)
  else
    return isTypeOf(obj1, oc.type(obj2))
  end
end

--- convert a value to a nerve
-- @param val - value to convert
-- @return oc.Nerve
function oc.nerve(val)
  if val == nil then
    return oc.Noop()
  elseif type(val) == 'function' then
    return oc.Functor{out=val}
  elseif type(val) == 'table' and val.__nerve__ then
    return val:__nerve__()
  else
    return oc.Const(val)
  end
end

--- Check if the nerve is an instance
-- With torch classes, one does not access the classes
-- directly but instead accesses the constructor so
-- we check whether the nerve equals the constructor
-- 
-- @param nerve - nerve or nerve class 
-- (or constructor for torch)
-- @return boolean
function oc.isInstance(nerve)
  local parent = getmetatable(nerve)
  return not (
    rawget(nerve, '__instance') == false or    
    -- Ensure that it is not a base class
    (parent == nil) or
    -- Ensure that it is not a torch constructor table
    (rawget(parent, '__constructor') == nerve) or
    -- Ensure that it is not a torch class
    (nerve.__typename ~= parent.__typename)
  )
end
