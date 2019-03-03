require 'oc.strand'
require 'oc.arm'
require 'oc.pkg'

local createBaseMeta = require 'oc.basemeta'

--- Tako is a type of Class presently with the 
-- ability to define arms (or processing
-- nerves for the tako). The Tako will
-- be set as the 'owner' of any nerves
-- which require one 
-- (such as functor, oc.my etc)
--
-- An arm is a pipeline of function calls.
--
-- @usage
--
-- self.arm.trainStep = oc.my.forward .. 
--   oc.my.backward .. oc.my.optimize
-- self.arm.predict = nn.Linear(<num>, <num>):d() .. 
--   nn.SoftMax():d()
-- self.arm.evaluate = oc.my.predict .. 
--   oc.Onto(oc.my.target) ..
--    ocnn.Criterion(nn.MSECriterion())
-- 
-- Tako example
--
-- @usage y = oc.Tako('y')
--          y.arm.t = nn.Linear:d() <- will create 
--            an arm (or nerve) that contains
--            a Linear declaration
-- 
-- @usage p1[1] will output the first
--    value of the p1 nerve.

local ArmCreator, makeArmCreator
do
  --- Utility used for adding an arm to a particular tako
  -- Normally the user will not interact 
  -- directly with this
  -- 
  -- @usage <tako>.arm.y = <strand> or <nerve>
  -- The index 'arm' will create a new arm creator
  -- And the index y will add an arm 'y' to the tako (an
  -- arm that can be indexed with 'y')
  local takos = {}
  local armindexes = {}
  ArmCreator = {}
  
  function ArmCreator.__index(self, index)
    assert(
      armindexes[self], 
      'The arm index has already been set and '.. 
      'cannot change.'
    )
    armindexes[self] = index
  end

  --- Add a new index in the 
  -- @param key - 
  -- @param value - 
  function ArmCreator.__newindex(self, key, value)
    assert(
      not armindexes[self],
      'An index has already been attached to this value.'
    )
    local moddedValue = oc.nerve(value)
    local tako = takos[self]
    assert(
      tako ~= nil,
      'The arm index has expired probably due to '..
      'setting its value.'
    )
    
    if tako.__instance then
      oc.bot.call:setOwner{
        args={tako},
        cond=function (self, nerve) 
          return nerve.setOwner ~= nil 
        end
      }:exec(
        moddedValue
      )

      oc.bot.call:setSuper{
        args={tako.__arms.__parent},
        cond=function (self, nerve)  
          return nerve.setSuper ~= nil 
        end
      }:exec(
        moddedValue
      )

      tako.__arms[key] = moddedValue
    else
      tako.__basearms[key] = moddedValue
    end
    takos[self] = nil
  end

  --- Make an ArmCreator for a given tako 
  -- in order to add an arm to the tako
  -- @param  The tako to create the arm for - Tako
  -- @return ArmCreator
  function makeArmCreator(tako)
    local result = {}
    setmetatable(result, ArmCreator)
    takos[result] = tako
    return result
  end

  --- need to create a wrap
  -- have to think about how to do this exactly
  -- Wrap <- The __arms for an instance does not 
  -- exist atm.  The problem is that there is no
  -- owner available until being set.
  function ArmCreator:__nerve__()

  end
  
  ArmCreator.__concat__ = oc.concat
end


local makeArmCluster
local makeParentArmCluster
--- MakeArmCluster is a utility class used to 
-- access arms within a tako
--
-- The purpose of the ArmCluster is to
-- be able maintain inheritance heirarchies
-- in the Tako since declaration nerves have to
-- be instantiated
-- 
-- The user does not really interact directly
-- with the ArmCluster
do
  local baseMeta = {}
  
  local function linearize(armCluster)
    local result = {}
    for k, v in pairs(armCluster) do
      if string.match(k, '__.+') == nil then
        table.insert(result, v)
      end
    end
    return result
  end

  --- Retrieve an arm from the ArmCluster
  -- @param key - the name of the arm to retrieve
  -- @return Arm or Nerve (if one exists)
  baseMeta.__index = function (self, key)
    local val = rawget(baseMeta, key)
    if val == nil and rawget(self, '__parent') then
      val = self.__parent[key]
    end
    return val
  end

  --- Add a new arm to the arm cluster
  -- @param - key - The key to index - string
  -- @param - value - The value to set to the ArmCluster
  baseMeta.__newindex = function (self, key, value)
    rawset(self, key, value)
  end

  --- Create an arm cluster for the parent class of
  -- a tako class
  -- @param instance - The Tako instance to create for - Tako
  -- @param cls - The Tako class to create for - TakoClass
  -- @return ArmCluster
  function makeParentArmCluster(instance, cls)
    local result = oc.ops.table.deepCopy(
      cls.__basearms  
    )
    
    result = makeArmCluster(instance, cls, result)

    oc.bot.call:setOwner{
      args={instance},
      cond=function (self, nerve) 
        return nerve.setOwner ~= nil 
      end
    }:execBatch(
      linearize(result)
    )
    -- TOOD: remove ??
    --[[
    oc.bot.nerve.SetOwner(
      instance
    ):execBatch(result)--]]
  
    --! perform any other necessary operations
    rawset(result, '__index', baseMeta.__index)
    rawset(result, '__newindex', baseMeta.__newindex)
    
    return result
  end

  --- Make an ArmCluster and all its parent
  -- classes for a Tako instance
  -- @param instance - Tako instance
  -- @param cls - Tako class
  -- @param result - table
  function makeArmCluster(instance, cls, result)
    result = result or {}
    
    if not cls then 
      cls = instance.__metatable 
    else 
      cls = cls.__metatable 
    end

    if cls then
      result.__parent = makeParentArmCluster(
        instance, cls
      )

      oc.bot.call:setSuper{
        args={result.__parent},
        cond=function (self, nerve)  
          return nerve.setSuper ~= nil 
        end
      }:execBatch(linearize(result))
      
      setmetatable(result, result.__parent)
    else
      setmetatable(result, baseMeta)
    end
    return result
  end  
end
  

do
  --- Methods used to build a Tako class and 
  -- instantiate Takos from that class
  -- Instantiate each of the arms in the tako
  -- @param instance - The tako to instantiate
  local instantiateArms = function (
    cls, instance
  )

  end

  --- Create an index function for a newly created tako
  -- 
  -- @param child - The child tako (subclass) - Tako
  -- @param parent - The parent tako - Tako
  -- @return closure for the index function
  local createIndexFunc = function (child)
  
    --- @param index - the index to the 
    -- @return
    local __index = function (
      self, index
    )
      local result = rawget(child, index)
      local parent = getmetatable(child)
      
      if index == 'arm' then
        return makeArmCreator(self)
      end
      
      --[[
      if self.__arms[index] then
        return self.__arms[index]
      end--]]
      
      if result ~= nil then
        return result
      end
    
      local childIndex = rawget(child, '__index__')
      if childIndex ~= nil then
        return childIndex(self, index)
      end
      
      if parent ~= nil then
        return parent.__index(self, index)
      end
      
      local arms = rawget(self, '__arms')
      if arms then
        return arms[index]
      end
      
    end
    return __index
  end

  --- Function to create a new tako
  --
  -- @param cls - The tako class
  -- @param ... - Arguments to the __init function
  -- @return Tako
  local new = function (
    cls, ...
  )
    local result = {
      __instance=true, 
      __typename=cls.__typename,
      __metatable=cls
    }
    setmetatable(result, cls)
    -- Instantiate the arms
    rawset(
      result, '__arms', makeArmCluster(result)
    )
    if cls.__init then
      cls.__init(result, ...)
    end
    
    return result
  end
  
  local function createTakoBaseMeta(vals)
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
  
    --- newindex function for basemeta
    -- 
    -- @param index - The index to update
    -- @param val - The value to update it with
    -- 
    rawset(vals, '__newindex', function (
        self, index, val
      )
        if index == 'arm' then
          error('The index arm is reserved.')
        end

        local f = vals['__newindex__']
        
        if f ~= nil then
          f(self, index, val)
        else
          rawset(self, index, val)
        end
      end
    )
  end
  local basemeta = {}
  createTakoBaseMeta(basemeta)
  basemeta.__instance = false
  basemeta.__typename = ''
  basemeta.__classtype = 'tako'
  
  rawset(basemeta, '__index', createIndexFunc(basemeta))

  local function baseSignal(tako, signal)
    if rawget(tako, '__head') ~= nil then
      return tako.__head:signal(signal)
    end
    error(
      string.format(
        'The Tako of type %s is headless so it '..
        'cannot be signalled.', tako.__typename
      )
    )
  end

  --[[
  basemeta.__call = function (
    self, ...
  )
    --! 
    --! @param ... - The arguments to the call function
    --!           if it's an instance otherwise the arguments
    --!           to __init
    --! @return - The results of the call function
    if self.__instance then
      return self['__call__'](self, ...)
    else
      return new(self, ...)
    end
  end
  --]]

  --- Create a new tako class
  -- @param className - The name for the tako - string
  -- @param parent - The super class for the new tako class - Tako
  -- @return Tako class
  oc.tako = function (
    className, parent  
  )
    local result = {
      __instance=false,
      __typename=className,
      __signal=baseSignal,
      __classtype = 'tako'
    }
    
    result.__basearms = {}
    createTakoBaseMeta(result)
    rawset(result, '__index', createIndexFunc(result, parent))
    
    if parent then
      result.__metatable = parent
      setmetatable(result, parent)
    else
      setmetatable(result, basemeta)
    end
    
    return result, parent
  end
end


--- Call a tako's signal function
-- @param tako - The tako to signal - Tako
-- @param signal - The signal to send to the tako - Signal
-- @return response from the signal
function oc.signal(tako, signal)
  return tako.__signal(signal)
end

--! @return Receptor
--[[
function oc.ops.tako.receptor(tako)
  checkTakoInstance(tako)
	return oc.Receptor(tako)
end
--]]
