require 'oc.flow.pkg'
require 'oc.flow.mergein'
require 'oc.class'
require 'oc.oc'


do
  local Merge, parent = oc.class(
    'oc.flow.Merge', oc.Nerve
  )
  --! ########################################
  --! Connect another process stream (chain) into 
  --! this stream.  It makes it possible to 
  --! get around the issue of it being 
  --! possible to only have one incoming stream
  --!
  --! @input    value
  --! @output  {}
  --! 
  --! @usage
  --! oc.Linear() .. 
  --!   oc.Under(oc.my.arm.x) .. 
  --!   oc.Add()
  --!   (will probe x)
  --! oc.Linear() ..
  --!   oc.Append(oc.my.arm.x) ..
  --!   oc.Add()
  --!   (will not probe x)
  --!
  --! Merging in References will
  --! not form a 'chain' and the gradient will not be 
  --! informed.  References will always be probed, however
  --! Outputs an emission with the items 
  --! being merged with the input stream.
  --! ########################################
  
  oc.flow.Merge = Merge

  function Merge:__init(nerves, updatePost)
    parent.__init(self)
    self._modules = {}
    self._updatePost = updatePost
    
    local curChain
    for i, cur in ipairs(nerves) do
      self._modules[i] = oc.mergeIn(
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
    for i=1, #self._modules - 1 do
      self._modules[i]:stimulateGrad(gradOutput[i])
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
    return gradOutput[1], table.unpack(gradOutput, 2)
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
    local gradInput, mergeGradOutputs = self:divideGrad(
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

  function Merge:getMergeIn(index)
    --! get a stream that 'Merge' merges in
    return self._modules[index]
  end
  
  function Merge:children()
    return self._modules
  end
end

do
  local Under, Onto, parent
  oc.flow.Under = Under
  Under, parent = oc.class(
    'oc.flow.Under', oc.flow.Merge
  ) 
  oc.flow.Under = Under
  function Under:__init(...)
    parent.__init(self, table.pack(...), true)
  end

  Onto, parent = oc.class(
    'oc.flow.Onto', oc.flow.Merge
  ) 
  oc.flow.Onto = Onto
  
  function Onto:__init(...)
    parent.__init(self, table.pack(...), false)
  end
  oc.flow.Onto = Onto
end

function oc.lhsRhsMerge(lhs, rhs)
  --! merge two modules together and return the merge
  return (lhs..oc.flow.Onto(rhs)):rhs()
end
