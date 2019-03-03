require 'oc.pkg'
require 'oc.nerve'
require 'oc.strand'
require 'oc.class'


do
  --- Wraps a processing sequence so that
  -- it can be used like any other nerve.
  -- 
  --
  -- @usage y = oc.Arm(p1 .. p2 .. p3)
  --          y:stimulate(value) will send the
  --          value through p1, p2 and then
  --          p3.
  --
  -- @input - Whatever the first member nerve takes
  -- @output - Whatever the member nerve outputs
  local Arm, parent = oc.class(
    'oc.Arm', oc.Nerve
  )
  
  oc.Arm = Arm

  --- @constructor
  -- @param nerve - nervable
  function Arm:__init(nerve)
    parent.__init(self)
    self._modules = {}
    if not torch.isTypeOf(nerve, 'oc.Strand') then
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
    return gradInput
  end
  
  function Arm:accGradParameters(
    input, gradOutput
  )
    self._modules.root:accumulate()
  end
  
  function Arm:get(val)
    local modules = self._modules.leaf:getSeq()
    return modules[val]
  end

  --- @return The arm converted into a strand - oc.Strand
  function Arm:strand()
    return oc.Strand(
      self._modules.root, self._modules.leaf
    )
  end
  
  function Arm:internals()
    return {self._modules.root}
  end

  --- @return the root of the arm - oc.Nerve
  function Arm:root()
    return self._modules.root
  end

  --- @param name
  -- @return The nerve which has name - oc.Nerve or nil
  -- Probably better to use a bot
  function Arm:getByName(name)
    local modules = self._modules.leaf:getSeq()
    for i=1, #modules do
      if modules[i].name == name then
        return modules[i]
      end
    end
    return nil
  end

  --- Retrieve the length of the arm
  -- @return int
  function Arm:__len__()
    return self._modules.leaf:getLength()
  end

  --- @static
  -- @return An arm constructed from a nerve - Arm
  function Arm.fromNerve(nerve)
    return oc.Arm(oc.Strand(nerve))
  end
end
