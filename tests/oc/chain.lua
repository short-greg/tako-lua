require 'oc.nerve'
require 'oc.chain'
require 'oc.noop'
require 'oc.oc'
require 'oc.arm'


function octest.oc_concat()
  local module = oc.Noop():label('hello')
  local arm = oc.Arm(
    oc.Chain(module)
  )
  octester:asserteq(
    #arm, 1,
    'Arm should have one module.'
  )
end
