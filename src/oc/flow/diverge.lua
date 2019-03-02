require 'oc.flow.pkg'
require 'oc.class'
require 'oc.nerve'
require 'oc.strand'
require 'oc.arm'


do
  local Diverge, parent = oc.class(
    'oc.Diverge', oc.Nerve
  )
  --! ########################################
  --! A flow structure that sends each 
  --! emission through a different
  --! processing stream.  
  --! The number of emissions must equal that
  --! of the number of processing streams.
  --! @input   [values] (whatever the process 
  --!          associated with the value at 
  --!          index i takes
  --! @output  [values]
  --! @example oc.Const({1, 2, 3}) .. oc.Diverge{
  --!            p1, p2, p3
  --!          }
  --!          This will send 1, 2, and 3 through
  --!          p1, p2, p3 respectively.
  --! 
  --! ########################################
  oc.Diverge = Diverge
  
  --! private method to determine how many 
  --! times to loop
  local getLoopCount

  function Diverge:__init(streams)
  --! @constructor
  --! @param	streams - Each of the processing 
  --! modules to process the emissions - {nn.Module}
  --!  - Nerve | Strand
  --! @param streams.n - number of modules 
  --! (if not defined will be table.maxn of streams)
    parent.__init(self)
    self._modules = {}
    self._n = streams.n or table.maxn(streams)
    for i=1, self._n do
      self._modules[i] = oc.nerve(streams[i])
    end
  end

  function Diverge:out(input)
    --! Send each index of the input through the
    --! corresponding strand index.
    --! @param input - {}
    local output = {}
    for i=1, self._n do
      output[i] = self._modules[i]:stimulate(input[i])
    end
    return output
  end

  function Diverge:grad(input, gradOutput)
    --! Send the element at each index of the gradInput
    --! through its corresponding strand
    local gradInput = {}
    gradOutput = gradOutput or {}
    for i=1, self._n do
      gradInput[i] = self._modules[i]:stimulateGrad(
        gradOutput[i]
      )
    end
    return gradInput
  end

  function Diverge:accGradParameters(input, gradOutput)
    for i=1, self._n do
      self._modules[i]:accumulate()
    end
  end
end
