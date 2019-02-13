require 'oc.pkg'
require 'oc.nerve'
require 'oc.class'


do
  local Undefined, parent = oc.class(
    'oc.Undefined', oc.Nerve 
  )
  
  oc.Undefined = Undefined

  function Undefined:_define(input)
    error(
      'Method define(input) not '.. 
      'defined for the abstract class Undefined.')
  end
  
  function Undefined:_defineBase(input)
    local mod = self:_define(input)
    mod.input = input
    assert(
      mod,
      string.format(
        'The nerve for %s '.. 
        'has not been defined.', self._argName
      )
    )
    
    if mod.super and 
       mod:super() and 
       mod:super() ~= self._super then
      error(
        string.format(
          'The super of the nerve %s has already been '..
          'set and it does not equal that of the '..
          'ArgNerve %s.',
          self._argName
        )
      )
    end

    if mod.owner and 
       mod:owner() ~= self._owner then
      error(
        string.format(
          'The owner of the nerve %s has already been '..
          'set and it does not equal that of the '..
          'ArgNerve %s.',
          self._argName
        )
      )      
    end
    mod._gradOn = self._gradOn
    mod._accOn = self._accOn
    mod._name = self._name
    mod._annotation = self._annotation
    mod._inAxon = self._inAxon
    mod._outAxons = self._outAxons
    mod._gradFunc = self._gradFunc

    if self:owner() then
      oc.bot.call:setOwner{
        args={self:owner()},
        cond=function (self, nerve) 
          return nerve.setOwner ~= nil 
        end
      }:exec(
        mod
      )
    end

    if self:super() then
      oc.bot.call:setSuper{
        args={self:super()},
        cond=function (self, nerve)  
          return nerve.setSuper ~= nil 
        end
      }:exec(
        mod
      )
    end
    return mod
  end
    
  function Undefined:out(input)
    -- Replace contents of self with created
    local defined = self:_defineBase(input)
    --defined:rewire(self)
    oc.ops.table.copyInto(self, defined)
    return self:stimulate(input)
  end
end
