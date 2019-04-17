require 'oc.flow.pkg'
require 'oc.class'
require 'oc.oc'
require 'oc.strand'
require 'oc.arm'
require 'oc.ref'
--require 'oc.placeholder'
require 'oc.noop'

local mergeIn

--[[
x .. oc.onto()
oc.onto(oc.get(y)) <- 
oc.ref <- results in a differerent mergein
oc.exec(y) <- always executes updateOutput
--]]

do
  --- Connect another process stream (strand) into 
  -- this stream.  It makes it possible to 
  -- get around the issue of it being 
  -- possible to only have one incoming stream
  --
  -- @input    value
  -- @output  {}
  -- 
  -- @usage
  -- oc.Linear() .. 
  --   oc.Under(oc.my.arm.x) .. 
  --   oc.Add()
  --   (will probe x)
  -- oc.Linear() ..
  --   oc.Append(oc.my.arm.x) ..
  --   oc.Add()
  --   (will not probe x)
  --
  -- Merging in References will
  -- not form a 'strand' and the gradient will not be 
  -- informed.  References will always be probed, however
  -- Outputs an emission with the items 
  -- being merged with the input stream.
  local Merge, parent = oc.class(
    'oc.Merge', oc.Nerve
  )
  
  oc.Merge = Merge

  function Merge:__init(nerves, updatePost)
    parent.__init(self)
    self._modules = {}
    self._updatePost = updatePost
    
    local curStrand
    for i, cur in ipairs(nerves) do
      self._modules[i] = mergeIn(
        oc.nerve(cur), self
      )
    end
    
    if self._updatePost == true then
      self._divide = self._dividePost
      self._merge = self._mergePost
    elseif self._updatePost == false then
      self._divide = self._dividePre
      self._merge = self._mergePre
    end
  end

  function Merge:setGradOutputs(gradOutputs)
    --! set the gradients of MergeIn
    for i=1, #self._modules do
      self._modules[i]:stimulateGrad(gradOutputs[i])
    end
  end

  function Merge:getInputs()
    local inputs = {}
    for i=1, #self._modules do
      inputs[i] = (self._modules[i]:stimulate())
    end
    return inputs
  end

  function Merge:out(input)
    local mergeOutputs = self:getInputs()
    return self:_merge(input, mergeOutputs)
  end

  function Merge:_mergePre(input, mergeInputs)
    return {input, table.unpack(mergeInputs)}
  end

  function Merge:_dividePre(gradOutput)
    return gradOutput[1], {table.unpack(gradOutput, 2)}
  end

  function Merge:_mergePost(input, mergeInputs)
    local result = {table.unpack(mergeInputs)}
    result[table.maxn(result) + 1] = input
    return result
  end

  function Merge:_dividePost(gradOutput)
    return gradOutput[table.maxn(gradOutput)], 
      {table.unpack(gradOutput, 1, table.maxn(gradOutput) - 1)}
  end
  
  function Merge:_divide(gradOutput)
    error(
      'Divide be reset to dividePost or Pre for an instance.'
    )
  end

  function Merge:_merge()
    error(
      'Divide be reset to mergePost or Pre for an instance.'
    )
  end

  function Merge:grad(input, gradOutput)
    local gradInput, mergeGradOutputs = self:_divide(
      gradOutput
    )
    self:setGradOutputs(mergeGradOutputs)
    return gradInput
    --[[
    self:setGradOutputs(table.pack(table.unpack(
        gradOutput, 1, table.maxn(gradOuput) - 1
    )))
    --]]
  end

  function Merge:accGradParameters(input, gradOutput)
  end

  -- get a stream that 'Merge' merges in
  function Merge:getMergeIn(index)
    return self._modules[index]
  end
  
  function Merge:internals()
    return self._modules
  end
end

do
  local Under, Onto, parent
  oc.Under = Under
  Under, parent = oc.class(
    'oc.Under', oc.Merge
  ) 
  oc.Under = Under
  function Under:__init(...)
    parent.__init(self, table.pack(...), true)
  end

  Onto, parent = oc.class(
    'oc.Onto', oc.Merge
  ) 
  oc.Onto = Onto
  
  function Onto:__init(...)
    parent.__init(self, table.pack(...), false)
  end
  oc.Onto = Onto
end

function oc.lhsRhsMerge(lhs, rhs)
  --! merge two modules together and return the merge
  return (lhs..oc.Onto(rhs)):rhs()
end



do
  --- Connect another process stream (strand) into 
  -- this stream.  It makes it possible to 
  -- get around the issue of it being 
  -- possible to only have one incoming stream
  --
  -- @input   nil
  -- @output  depends on the nerve to merge in
  local MergeNoop, parent = oc.class(
    'oc.MergeNoop', oc.Noop
  )
  oc.MergeNoop = MergeNoop
  
  --- mergenoop should not have outgoing nerve
  function MergeNoop:__init(mergeNerve)
    parent.__init(self)
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
  --- @input   nil
  -- @output  depends on the nerve to merge in
  local MergeInBase, parent = oc.class(
    'oc.MergeInBase', oc.Nerve
  )
  oc.MergeInBase = MergeInBase

  --- Controls how MergeIn takes place
  -- 
  -- @constructor
  -- @param outer - The module or stream to retrieve from
  -- @param toProbe - Whether to probe in 
  -- module to merge or just get the ouptut 
  -- - boolean (default=true)
  function MergeInBase:__init(nerve, outer)
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
  ---	Connective nerve to merge a sub nerve into
  -- a Merge nerve.
  --
  -- MergeIn should be defined implicitly rather than
  -- explicitly when creating an arm.
  -- 
  -- @input    value
  -- @output  {}
  local MergeIn, parent = oc.class(
    'oc.MergeIn', oc.MergeInBase
  )
  oc.MergeIn = MergeIn

  function MergeIn:internals()
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
end


do
  --	Merges in the output of a nerve
  -- It will not call probe on the output
  --
  -- Useful for RNNs where the nerve to check
  -- may have been informed and thus probe
  -- would update its value.
  -- 
  -- @input   nil
  -- @output  depends on the nerve to merge in
  local Get, parent = oc.class(
    'oc.Get', oc.MergeInBase
  )
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
  ---	Stimulates the nerve to mergeIn, though
  -- does not inform it.
  --
  -- Useful if the nerve to merge in is a 
  -- trainable tensor
  -- 
  -- @input   nil
  -- @output  depends on the nerve to merge in
  local Exec, parent = oc.class(
    'oc.Exec', oc.MergeInBase
  )
  oc.Exec = Exec
  
  function Exec:out()
    return self._arm:stimulate()
  end

  function Exec:grad(input, gradOutput)
    self._arm:stimulateGrad(gradOutput)
    return gradOutput
  end
  
  function Exec:internals()
    return {self._arm}
  end
end


do
  ---	Stimulates the nerve to mergeIn, though
  -- does not inform it.
  --
  -- Useful if the nerve to merge in is a 
  -- reference to a value or a function.
  -- 
  -- @input   nil
  -- @output  depends on the nerve to merge in
  local RefMerge, parent = oc.class(
    'oc.RefMerge', oc.MergeInBase
  )
  oc.RefMerge = RefMerge
  
  function RefMerge:out()
    return self._arm:stimulate()
  end

  --! ref does not have a grad
  function RefMerge:grad(input, gradOutput)
    return gradOutput
  end
  
  function RefMerge:internals()
    return {self._arm}
  end
end


do
  ---	Probes an Arm reference
  --
  -- Used if the nerve to merge in is a 
  -- reference to an arm
  -- 
  -- @input   nil
  -- @output  depends on the nerve to merge in
  local NerveRefMerge, parent = oc.class(
    'oc.NerveRefMerge', oc.MergeInBase
  )
  oc.NerveRefMerge = NerveRefMerge
  
  function NerveRefMerge:out()
    --! ensure that the arm is ready to probe
    self._arm:relaxStream(true)
    return self._arm:probe()
  end

  function NerveRefMerge:grad(input, gradOutput)
    return gradOutput
  end
  
  function NerveRefMerge:internals()
    return {self._arm}
  end
end


 mergeIn = function (nerve, mergeTo)
  local isMergeType = oc.isTypeOf(nerve, 'oc.MergeInBase') 
  if not isMergeType and 
     oc.isTypeOf(nerve, 'oc.RefBase') then
    return oc.RefMerge(nerve, mergeTo)
  elseif not isMergeType and 
     oc.isTypeOf(nerve, 'oc.NerveRef') then
    return oc.NerveRefMerge(nerve, mergeTo)
  elseif not isMergeType then
    return oc.MergeIn(nerve, mergeTo)
  end
  nerve:setMergeNerve(mergeTo)
  return nerve
end
