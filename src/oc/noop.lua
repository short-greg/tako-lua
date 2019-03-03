require 'oc.pkg'
require 'oc.class'
require 'oc.nerve'


do
  --- Non-operational nerve (does not
  -- alter the input).  
  -- 
  -- @usage y = oc.nerve(nil) -> oc.Noop()
  -- @usage y = oc.Noop()
  --          y:stimulate(1) -> y.output = 1
  --
  -- Especially useful for control nerves
  -- like oc.Multi{n=3} will replicate create
  -- a table of 3 with each value being the input.
  local Noop, parent = oc.class(
    'oc.Noop', oc.Nerve
  )
  oc.Noop = Noop

  --- @constructor
  function Noop:__init()
    parent.__init(self)
  end
  
  function Noop:out(input)
    self.output = input
    return input
  end
  
  function Noop:grad(input, gradOutput)
    self.gradInput = gradOutput
    return gradOutput
  end
end
