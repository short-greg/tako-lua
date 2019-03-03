require 'oc'
require 'nn'
require 'ocnn.pkg'


do
  --- Clones a nerve k times 
  -- and creates a Diverge nerve
  local DivergeClone, parent = oc.class(
    'ocnn.DivergeClone', oc.Diverge
  )
  
  function DivergeClone:__init(k, nerve)
    local modules = {}
    for i=1, k do
      modules[i] = nerve:clone()
    end
    parent.__init(self, modules)
  end
end
