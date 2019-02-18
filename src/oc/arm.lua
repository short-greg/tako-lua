require 'oc.pkg'
require 'oc.nerve'
require 'oc.chain'
require 'oc.class'


do
  local Arm, parent = oc.class(
    'oc.Arm', oc.Nerve
  )
  --! ####################################
  --! Wraps a processing sequence so that
  --! it can be used like any other nerve.
  --! 
  --!
  --! @example y = oc.Arm(p1 .. p2 .. p3)
  --!          y:stimulate(value) will send the
  --!          value through p1, p2 and then
  --!          p3.
  --!
  --! @input - Whatever the first member nerve takes
  --! @output - Whatever the member nerve outputs
  --! ####################################
  
  oc.Arm = Arm

  function Arm:__init(nerve)
    --! @constructor
    --! @param nerve - nervable
    parent.__init(self)
    self._modules = {}
    if not torch.isTypeOf(nerve, 'oc.Chain') then
      self._modules.root = oc.nerve(nerve)
      self._modules.leaf = self._modules.root
    else
      self._modules.root = nerve:lhs()
      self._modules.leaf = nerve:rhs()
    end
    self._gradOn = nerve._gradOn
    self._accOn = nerve._accOn
  end
  
  
  function Arm:out(input)
    self._modules.root:inform(input)
    return self._modules.leaf:probe()
  end

  function Arm:grad(input, gradOutput)
    local gradInput
    self._modules.leaf:informGrad(gradOutput)
    gradInput = self._modules.root:probeGrad()
    self.gradInput = gradInput
    return gradInput
  end
  
  function Arm:accGradParameters(input, gradOutput)
    self._modules.root:accumulate()
  end
  
  function Arm:get(val)
    local modules = self._modules.leaf:getSeq()
    return modules[val]
  end
  
  function Arm:chain()
    --! Convert the arm into a chain
    --! @return oc.Chain
    return oc.Chain(
      self._modules.root, self._modules.leaf
    )
  end
  
  function Arm:children()
    return {self._modules.root}
  end

  function Arm:root()
    --! Get the root nerve of the arm
    --! @return nn.Module
    return self._modules.root
  end

  function Arm:getByName(name)
    local modules = self._modules.leaf:getSeq()
    for i=1, #modules do
      if modules[i].name == name then
        return modules[i]
      end
    end
    return nil
  end

  function Arm.fromNerve(nerve)
    --! Convert a nerve into an arm
    --! @return Arm
    return oc.Arm(oc.Chain(nerve))
  end

  function Arm:__len__()
    --! Retrieve the length of the arm
    --! @return int
    return self._modules.leaf:getLength()
  end
end
