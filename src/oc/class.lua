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
  --! 
  --! 
  --! For the current implementation new is a 
  --! local function to the module but for 
  --! future implementations this may be changed.
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
  --! Creates an index function for the new class
  --! which will allow for inheritance.
  --! 
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
    --! Defines the 
    --! 
    
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
    --! The base index method used by 
    --! each class
    --! The index function should not be
    --! overloaded. As it is used to
    --! implement inheritance. 
    --! to overload the index function you should
    --! use __index__ instead
    --! @param index - 
    --! @return the value in the index
    local result = rawget(myChild, index)
    if result ~= nil then
      return result
    end

    result = parentIndex(myChild, index)
    if result ~= nil then
      return result
    end
    
    --! TODO: Not done in the right order....
    --! need to see if the index exists in the parent first
    local childIndex = rawget(myChild, '__index__')
    if childIndex ~= nil then
      result = childIndex(self, index)
      if result ~= nil then
        return result
      end
    end

    result = parentIndexFunc(myChild, self, index)
    return result
  end
  return __index
end


local function createClassBaseMeta(vals)
  --! Import the baseMeta methods into 
  --! the class which overload all of the
  --! standard metamethods.
  --! @param vals - a dictionary containing
  --! the newly created object in which
  --! to put the metamethods - {}
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

--! 'instance' refers to whether the object is 
--! an instance or class
basemeta.__instance = false
basemeta.__typename = ''

--! 'generic' means your standard class (not tako)
basemeta.__classtype = 'generic'

oc.class = function (
  className, parent  
)
  --! Creates a new class with a parent
  --! Classes created with this method
  --! 
  --! Classes implement inheritance by
  --! passing a parent who is also a class
  --! into the class function. 
  --! 
  --! In order to overload any metamethod one
  --! must use __metamethod__ rather than
  --! __method. In the implementation the 
  --! metamethods __tostring etc will 
  --! send the string of the overloaded metamethod
  --! to  __index such as '__tostring__' which will
  --! call the __tostring__ method.
  --!
  --! when __index is called it will check all of the
  --! parent metatables to ensure that the index
  --! does not exist in each of them.
  --! 
  --! @param className - The name of the class
  --! @param parent - the metatable for the parent
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
