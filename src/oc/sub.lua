require 'oc.pkg'
require 'oc.nerve'
require 'oc.oc'
require 'oc.ops.table'
require 'oc.chain'

--! TODO: Need to edit this

do
  local Sub, parent = oc.class(
    'oc.Sub', oc.Nerve
  )
  --! ######################################
  --! Sub is a Nerve retrieves a value from 
  --! a table that is passed in.  The value
  --! is passed in as an index.
  --! 
  --! @input a table
  --! @output the value at the index specified
  --! 
  --! @example p1[1] will output the first
  --!    value of the p1 nerve.
  --!
  --! ##########################################
  oc.Sub = Sub

  function Sub:__init(indices)
    --! @constructor
    --! @param indices - The indices or index to 
    --!                  retrieve - number or {number}
    parent.__init(self)
    self._indices = indices
    if oc.type(indices) == 'table' then
      self.updateOutput = self.updateOutputTable
      self.updateGradInput = self.updateGradInputTable
    else
      self.updateOutput = self.updateOutputScalar
      self.updateGradInput = self.updateGradInputScalar
    end
  end

  function Sub:updateOutputTable(input)
    local output = {}
    for i, v in ipairs(self._indices) do
      --[[if type(v) == 'table' then
        local cur = {}
        for j=1, #v do
          table.insert(cur, input[v])
        end
        table.insert(output, cur)
      else--]]
      table.insert(output, input[v])
      --end
    end
    self.output = output
    return output
  end

  --! @summary
  function Sub:updateOutputScalar(input)
    local output = input[self._indices]
    self.output = output
    return output
  end

  --! TODO: What if the same Value gets indexed twice
  function Sub:updateGradInputTable(input, gradOutput)
    local gradInput = {}
    for i, v in ipairs(self._indices) do
      --[[if type(v) == 'table' then
        local cur = {}
        for j=1, #v do
          gradInput[v] = v[j]
        end
      else--]]
      gradInput[v] = gradOutput[i]
      --end
    end
    self.gradInput = gradInput
    return gradInput
  end

  function Sub:updateGradInputScalar(input, gradOutput)
    local gradInput = {}
    gradInput[self._indices] = gradOutput
    self.gradInput = gradInput
    return gradInput
  end

  function Sub:accGradParameters(input, gradOutput)
  end
end

do
  local IndexChain, parent = oc.class(
    'oc.IndexChain', oc.Chain
  )
  --! ################################
  --!
  --! Used for chaining sub nerves for indexing
  --! as in x[1][2]
  --! @input  Input to retrieve the sub of (must be indexable)
  --! @output The output for the nerve indexed
  --! 
  --! ##############################

  oc.IndexChain = IndexChain

  function IndexChain:__init(mod, ...)
    local subItems = table.pack(...)
    local prev = mod
    for i=1, #subItems do
      local cur = oc.Sub(subItems[i])
      local _ = prev .. cur
      prev = cur
    end
    rawset(self, '_lhs', mod)
    rawset(self, '_rhs', prev)
  end

  function IndexChain:__index__(key)
    --! Index the IndexChain.  Overrides the 
    --! __index___ function for chain
    local res = rawget(self, key)
    
    if res then
      return res
    end

    local cur = oc.Sub(key)
    local _ = self._rhs .. cur
    self._rhs = cur
    return self
  end

  function IndexChain.__nerve__(self)
    return oc.nerve(oc.Chain(self._lhs, self._rhs))
  end

  function IndexChain.__tostring(self)
    return string.format(
      '%s .. %s', 
      oc.type(self._lhs), oc.type(self._rhs)
    )
  end
end


function oc.Nerve:__index__(key)
--! ##########################################
--!	Module (index) <- add indexing support
--! Index the module. Indexing is done with tables
--! so as not to have conflict with 
--! 'members' of the module nerve[{1}][{2}]
--! ##########################################
  local res = rawget(self, key)
  
  if res then
    return res
  end
  if (oc.type(key) == 'number' or 
     oc.type(key) == 'table') and
     oc.isInstance(self) then  
    local stream = oc.IndexChain(self, key)
    return stream
  end
end
