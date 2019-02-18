require 'oc.flow.multi'
require 'oc.chain'
require 'oc.noop'


function octest.control_multi_probe()
  local input_ = 1
  local multi = oc.Multi{oc.Noop(), oc.Noop()}
  local output = multi:stimulate(input_)
  
  octester:eq(
    output, {input_, input_},
    'The output should have the input repeated twice.'
  )
end

function octest.control_multi_probe_with_module_count_argument()
  local input_ = 1
  local multi = oc.Multi{n=2}
  local output = multi:stimulate(input_)
  
  octester:eq(
    output, {input_, input_},
    'The output should have the input repeated twice.'
  )
end

function octest.control_multi_probeGrad()
  local multi = oc.Multi{
  	n=2
  }
  local input_ = 1
  local output = multi:stimulate(input_)
  local gradInput = multi:stimulateGrad(output)
  
  octester:eq(
    gradInput, input_ + input_,
    'The input should input_ + iinput_'
  )
end
