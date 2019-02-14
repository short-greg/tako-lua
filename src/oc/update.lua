require 'oc.pkg'
require 'oc.class'
require 'oc.nerve'


do
  local MOD_CONFLICTS, checkConflicts

  local Update, parent = oc.class(
    'oc.Update', oc.Nerve
  )
  --! ################################################
  --! Use separate nerves for forward and backward 
  --! propagation and accumulation.  Useful if some nerves    
  --! are not required for backpropagation or 
  --! cannot backpropagate.
  --! @input  input into out/
  --! @gradOutput - updateGradInput - 
  --! gradOutput into grad/back
  --!               accGradParameters - 
  --! gradOutput into acc/back
  --! 
  --! @usage updateDiscriminator = oc.NerveUpdater{
  --!          out=oc.my.generator .. oc.my.discriminator,
  --!          back=oc.my.discriminate
  --!        }
  --! 
  --! In this case it is used to train the discriminator for
  --! a Gan where you don't want to backpropagate through
  --! the generator
  --!
  --! TODO Determine whether or not nerveupdater should
  --!      have its modules specified under modules
  --!      this results in the wrapper being said
  --!      to be relaxed if one of the inner modules is relaxed
  --! ################################################
  
  oc.Update = Update
  
  function Update:__init(nerves) 
    --! nerves = {} - set of nerves to wrap.  Some of the
    --!     valid fields overlap so the caller must not
    --!     use fields that overlap such as out and outgrad
    --!     both of which define updateOutput
    --! @param nerves.out - nerve for updateOutput()
    --! @param nerves.grad - nerve for updateGradInput()
    --! @param nerves.back - nerve for :updateOutput(),
    --!              updateGradInput
    --! @param nerves.outgrad - nerves for 
    --!      updateOutput, updateGradInput
    --! @param nerves.acc - function to accumulate gradInputs
    --!    (input, gradOutput)
    parent.__init(self)
    checkConflicts(nerves)
    self._baseMods = {}
    for k, mod in pairs(nerves) do
      self._baseMods[k] = oc.nerve(mod)
    end
    self._modules = {}
    self._modules.forward = self._baseMods.out or
      self._baseMods.outgrad
    self._modules.backward = self._baseMods.back or 
      self._baseMods.grad or self._baseMods.outgrad
    self._modules.acc = self._baseMods.acc or 
      self._baseMods.back
  end
  
  function Update:updateOutput(input)
    local output = self._modules.forward:stimulate(input)
    self.output = output
    return output
  end
  
  function Update:updateGradInput(input, gradOutput)
    self:updateOutput(input)
    local gradInput = self._modules.backward:stimulateGrad(
      gradOutput
    )
    self.gradInput = gradInput
    return gradInput
  end
  
  function Update:accGradParameters(input, gradOutput)
    self:updateGradInput(input, gradOutput)
    self._modules.acc:accumulate()
  end

  MOD_CONFLICTS = {
    {'out', 'outgrad'},
    {'back', 'outgrad', 'grad'},
    {'back', 'acc'}
  }

  checkConflicts = function(mods)
    --! Throw error if the modules passed to 
    --! NerveUpdater conflict
    --! @param mods - The modules passed to init 
    --! in NerveUpdater - {}
    --! @raises error
    for k, v in pairs(MOD_CONFLICTS) do
      local set = nil
      for k2, name in pairs(v) do
        if mods[name] and not set then
          set = nil
        elseif mods[name] then
          error(string.format(
            'Conflict in modules %s and %s cannot both be set',
            name, set
          ))
        end
      end
    end
  end
end
