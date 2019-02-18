require 'oc.bot.store'
require 'ocnn.ocnn'


--! ################################
--! Bots related to Torch
--! 
--! TensorStorer: Stores tensors
--!   that it 
--! ################################


do
  local TensorStorer, parent = oc.class(
    'oc.bot.store.TensorStorer',
    oc.bot.store.Storer
  )
  --! ################################
  --! 
  --! 
  --!
  --! ################################
  oc.bot.store.TensorStorer = TensorStorer
  
  function TensorStorer:__init(...)
    parent.__init(self, ...)
    self._tensorMap = {}
  end
  
  function TensorStorer:_copyTensor(into, from)
    if from and 
       self._tensorMap[torch.pointer(from)] then
      return self._tensorMap[torch.pointer(from)]
    end
    into = ocnn.updateTensor(into, from)
    self._tensorMap[torch.pointer(from)] = into
    return into
  end
  
  function TensorStorer:resetVisited()
    parent.resetVisited(self)
    self._tensorMap = {}
  end
  
  function TensorStorer:_copyTable(toUpdate, updateWith)
    --! Copies an entire table into the table to update
    --! Tensors are copied with copyTensor
    --! updateVal from ocnn is not used in order to make
    --! use of the TensorMap
    --! @param toUpdate - table to update - {} or nl
    --! @param copyTable - table to update the table with - {}
    --! @return {}
    toUpdate = toUpdate or {}
    
    for k, v in pairs(toUpdate) do
      if updateWith[k] == nil then
        toUpdate = nil
      end
    end
    
    for k, v in pairs(updateWith) do
      toUpdate[k] = self:_copyVal(toUpdate[k], v)
    end
  end
  
  function TensorStorer:_copyVal(toUpdate, updateWith)
    if oc.isTypeOf(updateWith, torch.Tensor) then
      return self:_copyTensor(toUpdate, updateWith)
    elseif oc.type(v) == 'table' then
      return self:copyTable(toUpdate, updateWith)
    else
      return updateWith
    end
  end
  
  function TensorStorer:setNerveOut(nerve, output)
    self._outputs[nerve] = self:_copyVal(
      self._outputs[nerve], output
    )
  end
  
  function TensorStorer:setNerveInput(nerve, input_)
    self._inputs[nerve] = self:_copyVal(
      self._inputs[nerve], input_
    )
  end
  
  function TensorStorer:setNerveGradInput(
      nerve, gradInput
  )
    self._gradInputs[nerve] = self:_copyVal(
      self._gradInputs[nerve], gradInput
    )
  end

  function TensorStorer:setNerveGradOut(
      nerve, gradOutput
  )
    self._gradOutputs[nerve] = self:_copyVal(
      self._gradOutputs[nerve], gradOutput
    )
  end
  
  function TensorStorer:_probeForOut(nerve)
    --!
    --!
    self:setNerveOut(nerve, nerve.output)
    self:setNerveInput(nerve, nerve.input)
  end
  
  function TensorStorer:_probeForGrad(nerve)
    self:setNerveGradInput(nerve, nerve.gradInput)
    self:setNerveGradOut(nerve, nerve.gradOutput)
  end
end
