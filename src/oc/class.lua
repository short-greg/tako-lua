require 'oc.pkg'
local createBaseMeta = require 'oc.basemeta'

--! ######################################
--! oc.class contains methods is used in order to create 
--! classes.  Class works similar to how
--! they do in torch.class but the class created
--! does not get added to a global variable.
--! 
--! @example 
--! local Gate, parent = oc.class(
--!   'oc.flow.Gate', oc.flow.Base
--! )
--! Gate will point to the metatable and parent will
--! equal Base.  While it is not necessary to have
--! it return the parent this is done just for
--! ease of use.
--! ######################################

local new = function (
  self, ...
)
  local result = {
    __instance=true, __typename=self.__typename
  }
  setmetatable(result, self)
  if self.__init then
    self.__init(result, ...)
  end
  return result
end

local createIndexFunc = function (child)
  local parentIndex
  local myChild = child
  parentIndex = function (myChild, index)
    local parent = getmetatable(myChild)
    if not parent then
      return
    end
    
    local result = rawget(parent, index)
    if result == nil then
      result = parentIndex(parent, index)
    end
    return result
  end
  
  local parentIndexFunc
  parentIndexFunc = function(myChild, self, index)
    local parent = getmetatable(myChild)
    if not parent then
      return
    end
    local indexFunc = rawget(parent, '__index__')
    if indexFunc ~= nil then
      return indexFunc(self, index)
    else
      return parentIndexFunc(parent, self, index)
    end
  end
  
  local __index = function (
    self, index
  )
    local result = rawget(myChild, index)
    if result ~= nil then
      return result
    end
    result = parentIndex(myChild, index)
    if result then
      return result
    end
    --! TODO: Not done in the right order....
    --! need to see if the index exists in the parent first
    local childIndex = rawget(myChild, '__index__')
    if childIndex ~= nil then
      return childIndex(self, index)
    end
    result = parentIndexFunc(myChild, self, index)
    return result
  end
  return __index
end


local function createClassBaseMeta(vals)
  createBaseMeta(vals)

  rawset(vals, '__call', function (
      self, ...
    )
      if self.__instance then
        return vals['__call__'](self, ...)
      else
        return new(self, ...)
      end
    end
  )
end

local basemeta = {}
createClassBaseMeta(basemeta)
rawset(basemeta, '__index', createIndexFunc(basemeta))
basemeta.__instance = false
basemeta.__typename = ''
basemeta.__classtype = 'generic'

oc.class = function (
  className, parent  
)
  local result = {
    __instance=false,
    __typename=className,
    __classtype='generic'
  }
  
  createClassBaseMeta(result)
  rawset(
    result, '__index', createIndexFunc(result, parent)
  )
  if parent then
    --result.__metatable = parent
    setmetatable(result, parent)
  else
    setmetatable(result, basemeta)
  end
  return result, parent
end
