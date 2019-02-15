require 'oc.flow.pkg'
require 'oc.nerve'
require 'oc.class'

--[[
x .. oc.onto()
oc.onto(oc.get(y)) <- 
oc.ref <- results in a differerent mergein
oc.exec(y) <- always executes updateOutput
--]]


do
  local MergeNoop, parent = oc.class(
    'oc.MergeNoop', oc.Noop
  )
  --! ########################################
  --! Connect another process stream (chain) into 
  --! this stream.  It makes it possible to 
  --! get around the issue of it being 
  --! possible to only have one incoming stream
  --!
  --! @input   nil
  --! @output  depends on the nerve to merge in
  --!
  --! ########################################
  oc.MergeNoop = MergeNoop
  
  function MergeNoop:__init(mergeNerve)
    parent.__init(self)
    --! mergenoop should not have outgoing nerve
    self._outgoing = nil
    self._mergeNerve = mergeNerve
  end
  
  function MergeNoop:outgoing()
    return {self._mergeNerve}
  end
  
  function MergeNoop:setMergeNerve(mergeNerve)
    self._mergeNerve = mergeNerve
  end
end


do
  local MergeInBase, parent = oc.class(
    'oc.MergeInBase', oc.Nerve
  )
  --! ########################################
  --! 
  --!
  --! @input   nil
  --! @output  depends on the nerve to merge in
  --!
  --! ########################################
  oc.MergeInBase = MergeInBase
  
  function MergeInBase:__init(nerve, outer)
  --! Controls how MergeIn takes place
  --! 
  --! @constructor
  --! @param outer - The module or stream to retrieve from
  --! @param toProbe - Whether to probe in 
  --! module to merge or just get the ouptut 
  --! - boolean (default=true)
    parent.__init(self)
    self._toGet = oc.nerve(nerve)
    self._noop = oc.MergeNoop(outer)
    self._arm = (self._toGet .. self._noop):arm()
  end

  function MergeInBase:accGradParameters(input, gradOutput)
    --
  end

  function MergeInBase:setMergeNerve(mergeNerve)
    self._noop:setMergeNerve(mergeNerve)
  end
end


do
  local MergeIn, parent = oc.class(
    'oc.MergeIn', oc.MergeInBase
  )
  --! ########################################
  --!	Connective nerve to merge a sub nerve into
  --! a Merge nerve.
  --!
  --! MergeIn should be defined implicitly rather than
  --! explicitly when creating an arm.
  --! 
  --! @input    value
  --! @output  {}
  --!
  --! ########################################
  oc.MergeIn = MergeIn

  function MergeIn:children()
    return {}
  end

  function MergeIn:out(input)
    self._noop:relax()
    return self._noop:probe()
  end

  function MergeIn:grad(input, gradOutput)
    self._noop:informGrad(gradOutput)
    return gradOutput
  end

  function MergeIn:updateGradInput(input, gradOutput)
    self.gradInput = gradOutput
    return gradOutput
  end
end


do
  local Get, parent = oc.class(
    'oc.Get', oc.MergeInBase
  )
  --! ########################################
  --!	Merges in the output of a nerve
  --! It will not call probe on the output
  --!
  --! Useful for RNNs where the nerve to check
  --! may have been informed and thus probe
  --! would update its value.
  --! 
  --! @input   nil
  --! @output  depends on the nerve to merge in
  --!
  --! ########################################
  oc.Get = Get
  
  function Get:out(input)
    local output = self._toGet.output
    self._noop:stimulate(output)
    return output
  end
  
  function Get:grad(input, gradOutput)
    self._noop:informGrad(gradOutput)
    return gradOutput
  end
  
  function Get:accGradParameters(input, gradOutput)
  end

  function Get:probe()
    return self:updateOutput()
  end
end


do
  local Exec, parent = oc.class(
    'oc.Exec', oc.MergeInBase
  )
  --! ########################################
  --!	Stimulates the nerve to mergeIn, though
  --! does not inform it.
  --!
  --! Useful if the nerve to merge in is a 
  --! trainable tensor
  --! 
  --! @input   nil
  --! @output  depends on the nerve to merge in
  --!
  --! ########################################
  oc.Exec = Exec
  
  function Exec:out()
    return self._arm:stimulate()
  end

  function Exec:grad(input, gradOutput)
    self._arm:stimulateGrad(gradOutput)
    return gradOutput
  end
  
  function Exec:children()
    return {self._arm}
  end
end


do
  local RefMerge, parent = oc.class(
    'oc.RefMerge', oc.MergeInBase
  )
  --! ########################################
  --!	Stimulates the nerve to mergeIn, though
  --! does not inform it.
  --!
  --! Useful if the nerve to merge in is a 
  --! reference to a value or a function.
  --! 
  --! @input   nil
  --! @output  depends on the nerve to merge in
  --!
  --! ########################################
  oc.RefMerge = RefMerge
  
  function RefMerge:out()
    return self._arm:stimulate()
  end

  function RefMerge:grad(input, gradOutput)
    return gradOutput
  end
  
  function RefMerge:children()
    return {self._arm}
  end
end


do
  local ArmRefMerge, parent = oc.class(
    'oc.ArmRefMerge', oc.MergeInBase
  )
  --! ########################################
  --!	Probes an Arm reference
  --!
  --! Used if the nerve to merge in is a 
  --! reference to an arm
  --! 
  --! @input   nil
  --! @output  depends on the nerve to merge in
  --!
  --! ########################################
  oc.ArmRefMerge = ArmRefMerge
  
  function ArmRefMerge:out()
    self._arm:relaxStream(true)
    return self._arm:probe()
  end

  function ArmRefMerge:grad(input, gradOutput)
    return gradOutput
  end
  
  function ArmRefMerge:children()
    return {self._arm}
  end
end


function oc.mergeIn(nerve, mergeTo)
  local isMergeType = oc.isTypeOf(nerve, 'oc.MergeInBase') 
  if not isMergeType and 
     oc.isTypeOf(nerve, 'oc.ValRefBase') then
    return oc.RefMerge(nerve, mergeTo)
  elseif not isMergeType and 
     oc.isTypeOf(nerve, 'oc.ArmRefBase') then
    return oc.ArmRefMerge(nerve, mergeTo)
  elseif not isMergeType then
    return oc.MergeIn(nerve, mergeTo)
  end
  nerve:setMergeNerve(mergeTo)
  return nerve
end
