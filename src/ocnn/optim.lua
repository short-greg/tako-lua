require 'ocnn.pkg'
require 'oc.ops.table'
require 'oc.nerve'
require 'ocnn.module'
require 'oc.bot.get'


do
  local Optim, parent = oc.class(
    'ocnn.Optim', oc.Nerve
  )
  ocnn.Optim = Optim
  --! ###########################################
  --! Wraps Torch optimizers to work in the context of a graph
  --!
  --! @example ocnn.Optim(
  --!    optim.adadelta, 
  --!    r(oc.my.autoencoder), -- the nerve to get parameters for
  --!    config -- The config you send to the optimizer
  --! )
  --! 
  --! @input CriterionResult - float
  --! @output CriterionResult - float
  --! ############################################

  function Optim:__init(optim, nerve, config, toCache)
    --! Updates the parameters of the newtork
    --! @param optim - the optimizer to use - optim
    --! @param config - Config for the optimizer - {}
    parent.__init(self)

    local params = oc.bot.get.Param:reportFor(
      nerve
    )
    assert(
      type(params) == 'table' and params.x and params.dx ~= nil,
      'Must pass the params.x and params.dx to the constructor.'
    )
    config = config or {}
    self._optim = optim or error('Must specify an optimizer')
    self._baseConfig = config
    self._config = oc.ops.table.deepCopy(config)
    self._curNerve = nil
    self._x = params.x
    self._dx = params.dx
    self._state = nil
    self:resetState()
  end
  
  function Optim:resetState()
    self._state = {}
  end
  
  function Optim:setConfigVar(varname, value)
    self._config[varname] = value
  end
  
  function Optim:out(input)
    -- TODO: NEED TO ChANGE THIS! DO not want to have to get the
    --  second input
    local feval = function ()
      return input, self._dx
    end
    if self._x:dim() > 0 then
      before = self._x[1]
    end
    local result = self._optim(
      feval, self._x, self._config, self._state
    )
    self._dx:zero()
    return result
  end
  
  function Optim:grad(input, gradOutput)
    return gradOutput
  end
  
  function Optim:resetGrad()
    self._dx:zero()
  end
  
  function Optim:reset(nerve)
    self._config = oc.ops.table.deepCopy(self._baseConfig)
  end
  
  function Optim:__tostring__()
    return tostring('Optimizer: ', tostring(self.optim))    	
  end
end


do
  local MultiOptim, parent = oc.class(
    'ocnn.MultiOptim', oc.Nerve
  )
  ocnn.MultiOptim = MultiOptim
  --! #####################################
  --! Wraps multiple optimizers to be used as one 
  --! optimizer
  --! A composite optim, whcih allows multiple optimizers 
  --! to be executed as one or each individual optimizer to be
  --! accessed as a member of the 
  --!
  --! @input CriterionResult - float
  --! @output CriterionResult - float
  --! #######################################
  
  function MultiOptim:__init(optims)
    --! @param optims
    
    parent.__init(self)
    for k, optim in pairs(optims) do
      assert(
        self[k] == nil, 
        string.format(
          'Optim  member %s has the same name as a class member',
          k
        )
      )
      assert(
        torch.type(optim) == 'ocnn.Optim',
        'Optimizer must be type of ocnn.Optim'
      )
    end
    self.optims = optims
  end
  
  function MultiOptim:__index__(index)
    local optims = rawget(self, 'optims')
    if optims and optims[index] ~= nil then
      return self.optims[index], true
    end
    return false
  end
  
  function MultiOptim:_applyOnAll(funcName, ...)
    local result = {}
    for name, optimizer in pairs(self.optims) do
      result[name] = optimizer[funcName](optimizer, ...)
    end
    return result
  end
  
  function MultiOptim:resetGrad()
    self:_applyOnAll('resetGrad', input)
  end
  
  function MultiOptim:out(input)
    local output = 0
    local result = self:_applyOnAll('updateOutput', input)
    for i=1, #result do
      output = result + output
    end
    self.output = output
    return output
  end
  
  function MultiOptim:grad(input, gradOutput)
    self:_applyOnAll('updateGradInput', input, gradOutput)
  end
  
  function MultiOptim:reset(nerve)
    self:_applyOnAll('reset', nerve)
  end
end
