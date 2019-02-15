require 'oc.flow.pkg'
require 'oc.nerve'
require 'oc.class'


do
  local Multi, parent = oc.class(
    'oc.Multi', oc.Nerve
  )
  --! ########################################
  --! Multi sends an input through several 
  --! processing
  --! 
  --! @input - value (will be sent through each stream)
  --! @output - []
  --! 
  --! @example oc.Var(1) .. oc.Multi{n=3}
  --! Probing will result in the output {1, 1, 1}
  --! The number of processes is specified to be
  --! 3 but they are all Noops
  --!
  --! @example oc.Var(1) .. oc.Multi{p1, p2, p3}
  --! Here the output will be {
  --!   p1:stimulate(1),
  --!   p2:stimulate(1),
  --!   p3:stimulate(1)
  --! }
  --! ########################################
  oc.Multi = Multi

  function Multi:__init(streams)
    --!	@constructor	
    --! @param streams - {oc.Chain or oc.Nerve}
    --! @param streams.n - number of modules (if not defined will
    --! be table.maxn of streams)
    parent.__init(self)
    self._modules = {
      root=streams.root or oc.Noop()
    }
    self._n = streams.n or table.maxn(streams)
    for i=1, self._n do
      table.insert(
        self._modules,
        self._modules.root .. oc.nerve(streams[i])
      )
    end
  end

  function Multi:out(input)
    local output = {}
    self._modules.root:inform(input)
    for i=1, self._n do
      output[i] = self._modules[i]:probe()
    end
    return output
  end

  function Multi:grad(input, gradOutput)
    local gradInput
    gradOutput = gradOutput or {}
    local curGradOut
    for i=1, self._n do
      self._modules[i]:informGrad(gradOutput[i])
    end
    return self._modules.root:probeGrad()
  end

  function Multi:accGradParameters(input, gradOutput)
    self._modules.root:accumulate()
  end

  function Multi:children()
    return {self._modules.root}
  end
end
