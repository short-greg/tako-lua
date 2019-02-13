require 'oc.bot.pkg'
require 'oc.class'
require 'oc.bot.nano'


do
  local Call, parent = oc.class(
    'oc.bot.Call', oc.bot.Nano
  )
  --! Call is for creating a bot that 
  --! will call a member of a nerve that it
  --! passes through.
  --!
  --! @usage oc.bot.call:relax()
  
  --! For 'class methods' use dot
  --! oc.bot.call.func(
  --!   args={<arg>}
  --!   cond=function(self, nerve) return nerve.func ~= nil end
  --! )
  --!
  --! For 'instance methods' use colon and it will
  --! pass self as the first algorithm
  --! 
  --! oc.bot.call:func(
  --!   args={<arg>}
  --!   cond=function(self, nerve) return nerve.func ~= nil end
  --! )
  --! 
  --! Calls the function relax on all nerves
  --!
  
  oc.bot.Call = Call
  
  --! default function calls
  local selfCallFunc, nonSelfCallFunc
  local nullCond, baseProcess, baseReport
  
  function Call:__init(
    funcName, args, cond, process, report, selfCall
  )
    parent.__init(self)
    self._funcName = funcName
    self.cond = cond or nullCond
    self.report = report or baseReport
    self._process = process or baseProcess
    self._results = {}
    if selfCall == true then
      self._callFunc = selfCallFunc
    else
      self._callFunc = nonSelfCallFunc
    end
    self._selfCall = selfCall or false
    self._args = args or {}
  end
  
  function Call:toVisit(nerve)
    if self:cond(nerve) then
      return parent.toVisit(self, nerve)
    end
    return false
  end
  
  function Call:visit(nerve)
    --! @brief Visit the module and relax it
    self:_process(
      nerve, self:_callFunc(nerve)
    )
    return nerve
  end
  
  function Call:spawn()
    --! Spawn another Call Bot
    return oc.Call(
      self._funcName, self._args, self.cond, self._process,
      self._report, self._callFunc == self._selfCallFunc
    )
  end
  
  selfCallFunc = function(self, nerve)
    return nerve[self._funcName](
      nerve, table.unpack(self._args)
    )
  end
  
  nonSelfCallFunc = function(self, nerve)
    return nerve[self._funcName](
      table.unpack(self._args)
    )
  end
  
  nullCond = function(self, nerve)
    return true
  end

  baseProcess = function(self, nerve, results)
    self._results[nerve] = results
  end
  
  baseReport = function(self)
    return self._results
  end

  oc.bot.call = {}
  --! convenience table for create a call class
  --! 
  
  local callmeta
  local function createCallFunc(index)
    local _ = function(arg1, arg2)
      --! 
      --!
      local args
      if arg1 == oc.bot.call then
        args = arg2 or {}
        assert(
          args.selfCall == nil or args.selfCall == false,
          'Arg2 must not specify selfCall as false '.. 
          'if calling with :.'
        )
        args.selfCall = true
      else
        args = arg1 or {}
      end
      
      return oc.bot.Call(
        index,
        args.args, args.cond, 
        args.process, args.report, 
        args.selfCall
      )
    end
    return _
  end
  callmeta = {
    __newindex=function () error(
      'Cannot define new index for the table call'
      ) end,
    __index=function (self, index)
      return createCallFunc(index) 
    end
  }
  setmetatable(oc.bot.call, callmeta)
end
