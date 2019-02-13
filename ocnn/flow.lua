require 'oc'
require 'nn'
require 'ocnn.pkg'

ocnn.flow = {}


do
  local DivergeClone, parent = oc.class(
    'ocnn.flow.DivergeClone', oc.flow.Diverge
  )
  
  function DivergeClone:__init(k, stream)
    local modules = {}
    for i=1, k do
      modules[i] = stream:clone()
    end
    parent.__init(self, modules)
  end
end
