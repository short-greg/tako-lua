require 'oc.pkg'
require 'oc.nerve'
require 'oc.class'


do
  --- Function object (a function that can contain state)
  -- Along with the potential to do back propagation
  -- Useful for defining nerves 'on-the-fly' 
  -- within a given arm or tako
  --
  -- @example nerve1 .. 
  --          oc.Functor{
  --            out=function (self, input) return input + 1 end,
  --            grad=function (self, input, gradOutput) 
  --              return gradOutput end
  --          }
  -- 
  -- @example nerve1 ..
  --          oc.Functor{
  --            grad=
  --             function (self, input, gradOutput) 
  --               return gradOutput * 100
  --             end
  --          }
  -- -- Amplify the gradient
  -- 
  -- @input  Depends on the user's definition
  -- @output Depends on the user's definition
  local Functor, parent = oc.class(
    'oc.Functor', oc.Nerve
  )

  
  oc.Functor = Functor
  --- @param args - Arguments defining the update methods
  -- for the nerve
  -- @param args.out - used for updateOutput
  -- function - (optional)
  -- @param args.grad - used for updateGradInput 
  -- function - (optional)
  -- @param args.acc - used for accGradParameters
  -- function - (optional)
  function Functor:__init(args)
    parent.__init(self)
    if args.init then
      for k, v in pairs(args.init) do
        self['_' .. tostring(k)] = v
      end
    end
    self.out = args.out or self.baseOut
    self.grad = args.grad or self.baseGrad
    self.acc = args.acc or self.baseAcc
  end

  --- Set the 'owner' of the module
  -- @param  owner 
  function Functor:setOwner(owner)
    if owner ~= nil and not self._owner then
      self._owner = owner
      return true
    end
    return false
  end
  
  function Functor:owner()
    return self._owner
  end

  function Functor:baseOut(input)
    return input
  end

  function Functor:baseGrad(input, gradOutput)
  end

  function Functor:baseAcc(input, gradOutput)
  end

  function Functor:accGradParameters(
      input, gradOutput
  )
    self:acc(input, gradOutput)
  end
end
