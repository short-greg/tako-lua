require 'oc.flow.pkg'
require 'oc.nerve'
require 'oc.class'


do
  --- Repeat a process until the process outputs false
  -- It is possible to update the gradient of
  -- the process through updateOutput if 
  -- gradOn is set to true.  The stream will 
  -- repeatedly be informed by the input that 
  -- is passed in.  Repeat executes
  -- backpropagation and accumulation as 
  -- well if they are turned on.
  -- @input Whatever the inner process takes
  -- @output nil
  -- @usage oc.Repeat(
  --             oc.ref.getResponse():eq('Finished')
  --        )
  local Repeat, parent = oc.class(
    'oc.Repeat', oc.Nerve
  )
  oc.Repeat = Repeat

  --- @param strand
  -- @param gradOn
  function Repeat:__init(strand, gradOn)
    parent.__init(self)
    if gradOn == nil then
      gradOn = true
    end
    assert(
      type(gradOn) == 'boolean',
      string.format(
        'Argument gradOn should be of type '.. 
        'boolean not %s.',
        type(gradOn)
      )
    )
    self.gradOn = gradOn
    self._module = oc.nerve(strand)
    self.output = nil
  end
  
  function Repeat:out(input)
    local toContinue = 1
    local output
    while toContinue == 1 do
      output = self._module:stimulate(input)
      toContinue = output[1]
    end
    return output[2]
  end

  function Repeat:grad(input, gradOutput)
    --
  end

  function Repeat:accGradParameters(input, gradOutput)
    --
  end

end
