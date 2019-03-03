require 'oc.ops.pkg'

oc.ops.tensor = {}

local tens = oc.ops.tensor

--! TODO: Move to ocnn or call oct (oct.expandTo) 
--! is oct too similar?

--- Expand a sample tensor to the same number 
-- size as the other tensor
-- @param tensor1 - torch.Tensor
-- @param tensor2 - torch.Tensor
-- @return torch.Tensor
function tens.expandTo(
    tensor1, tensor2, secondDim
  )
  local repeatSize = {}
  for i=1, tensor1:dim() do
    repeatSize[i] = 1
  end
  
  if secondDim == true then
    repeatSize[2] = tensor2:size(2)
  else
    repeatSize[1] = tensor2:size(1)
  end
  return torch.repeatTensor(
    tensor1, table.unpack(repeatSize)
  )
end

--- Retrieve the size of a sample for a batch tensor
-- @param tensor torch.Tensor
-- @return torch.Storage 
function tens.sampleSizeOf(tensor)
  local t = tensor:size()
  t[1] = 1
  return t
end

--- Retrieve whether or not two batch tensors have
-- the same sample size.  Must have more than one 
-- dimension
-- @param tensor1 - torch.Tensor
-- @param tensor2 - torch.Tensor
-- @return boolean
function tens.sampleSizeEqual(tensor1, tensor2)
  return tensor1:dim() > 1 and tensor2:dim() > 1 and
         tostring(tens.sampleSizeOf(tensor1)) == 
         tostring(tens.sampleSizeOf(tensor2)) 
end


--- Retrieve whether two tensors have the same size
-- @param tensor1 - torch.Tensor
-- @param tensor2 - torch.Tensor
-- @return boolean
function tens.sizeEqual(tensor1, tensor2)
  return tostring(
    tensor1:size()) == tostring(tensor2:size()
  )
end

--- Expand the tensor to be of two dimensions
-- @param tens - torch.Tensor
-- @return torch.Tensor
function tens.expandDim2(tens)

  return tens:view(tens:size(1), tens:stride(1))
end

--- TODO: Change name?
-- Shrink the tensor to be of two dimensions
-- @param tens - torch.Tensor
-- @return torch.Tensor
function tens.expandDim1(tens)
  return tens:view(tens:nElement(1))
end


--- TODO: Change name?
-- Shrink the tensor to be of two dimensions
-- @param tens - torch.Tensor
-- @return torch.Tensor
function tens.flattenBatch(tens)
  return tens:view(tens:size(1), tens:stride(1))
end


--- Shrink the tensor to be of one dimensions
-- @param tens - torch.Tensor
-- @return torch.Tensor
function tens.flatten(tens)
  return tens:view(tens:nElement())
end


--- Do batch view
-- @param tens - torch.Tensor
-- @return torch.Tensor in batch mode where the
-- first dimension has 1 
function tens.doBatchView(tens)
  local sz = tens:size()
  local newSz = {1}
  for i=1, #sz do
    table.insert(newSz, sz[i])
  end
  return tens:view(torch.LongStorage(newSz))
end
 
 
--- Undo the batch view
-- @param tens - torch.Tensor
-- @return torch.Tensor in batch mode where the
-- first dimension has 1
function tens.undoBatchView(tens)
  local sz = tens:size()
  local newSz = {}
  for i=2, #sz do
    table.insert(newSz, sz[i])
  end
  return tens:view(torch.LongStorage(newSz))
end

--- @param batchSize - Size to make the batch
-- @param tens - torch.Tensor
-- @return torch.Tensor in batch mode where the
-- first dimension has 1
function tens.createOfBatchSize(batchSize, tens)
  local size = tens:size()
  size[1] = batchSize
  return torch.Tensor():typeAs(tens):resize(size):zero()
end


--- @param batchSize - Size to make the batch
-- @param tens - torch.Tensor
-- @return torch.Tensor in batch mode where the
-- first dimension has 1
function tens.isNullTensor (tens)
  if torch.isTypeOf(tens, 'torch.Tensor') and 
     tens:dim() == 0 then
    return true
  else
    return false
  end
end
