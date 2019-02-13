require 'oc.ops.pkg'

oc.ops.tensor = {}

local tens = oc.ops.tensor

--! TODO: Move to ocnn or call oct (oct.expandTo) 
--! is oct too similar?

function tens.expandTo(tensor1, tensor2, secondDim)
  --! Expand a sample tensor to the same number 
  --! of dimensions in
  --! @param tensor1 - torch.Tensor
  --! @param tensor2 - torch.Tensor
  --! @return torch.Tensor
  local repeatSize = {}
  for i=1, tensor1:dim() do
    repeatSize[i] = 1
  end
  
  if secondDim == true then
    repeatSize[2] = tensor2:size(2)
  else
    repeatSize[1] = tensor2:size(1)
  end
  return torch.repeatTensor(tensor1, table.unpack(repeatSize))
end


function tens.sampleSizeOf(tensor)
  --! Retrieve the size of a sample for a batch tensor
  --! @param tensor torch.Tensor
  --! @return torch.Storage 
  local t = tensor:size()
  t[1] = 1
  return t
end


function tens.sampleSizeEqual(tensor1, tensor2)
  --! Retrieve whether or not two batch tensors have
  --! the same sample size.  Must have more than one 
  --! dimension
  --! @param tensor1 - torch.Tensor
  --! @param tensor2 - torch.Tensor
  --! @return boolean
  return tensor1:dim() > 1 and tensor2:dim() > 1 and
         tostring(tens.sampleSizeOf(tensor1)) == 
         tostring(tens.sampleSizeOf(tensor2)) 
end


function tens.sizeEqual(tensor1, tensor2)
  --! Retrieve whether two tensors have the same size
  --! @param tensor1 - torch.Tensor
  --! @param tensor2 - torch.Tensor
  --! @return boolean
  return tostring(tensor1:size()) == tostring(tensor2:size())
end


function tens.expandDim2(tens)
  --! Expand the tensor to be of two dimensions
  --! @param tens - torch.Tensor
  --! @return torch.Tensor
  return tens:view(tens:size(1), tens:stride(1))
end


function tens.expandDim1(tens)
  --! TODO: Change name?
  --! Shrink the tensor to be of two dimensions
  --! @param tens - torch.Tensor
  --! @return torch.Tensor
  return tens:view(tens:nElement(1))
end


function tens.flattenBatch(tens)
  --! TODO: Change name?
  --! Shrink the tensor to be of two dimensions
  --! @param tens - torch.Tensor
  --! @return torch.Tensor
  return tens:view(tens:size(1), tens:stride(1))
end


function tens.flatten(tens)
  --! Shrink the tensor to be of one dimensions
  --! @param tens - torch.Tensor
  --! @return torch.Tensor
  return tens:view(tens:nElement())
end


function tens.doBatchView(tens)
  --! Do batch view
  --! @param tens - torch.Tensor
  --! @return torch.Tensor in batch mode where the
  --!         first dimension has 1 
  local sz = tens:size()
  local newSz = {1}
  for i=1, #sz do
    table.insert(newSz, sz[i])
  end
  return tens:view(torch.LongStorage(newSz))
end
 
 
function tens.undoBatchView(tens)
  --! Undo the batch view
  --! @param tens - torch.Tensor
  --! @return torch.Tensor in batch mode where the
  --!         first dimension has 1
  local sz = tens:size()
  local newSz = {}
  for i=2, #sz do
    table.insert(newSz, sz[i])
  end
  return tens:view(torch.LongStorage(newSz))
end


function tens.createOfBatchSize(batchSize, tens)
  --! @param batchSize - Size to make the batch
  --! @param tens - torch.Tensor
  --! @return torch.Tensor in batch mode where the
  --!         first dimension has 1
  local size = tens:size()
  size[1] = batchSize
  
  return torch.Tensor():typeAs(tens):resize(size):zero()
end


function tens.isNullTensor (tens)
  --! @param batchSize - Size to make the batch
  --! @param tens - torch.Tensor
  --! @return torch.Tensor in batch mode where the
  --!         first dimension has 1
  if torch.isTypeOf(tens, 'torch.Tensor') and 
     tens:dim() == 0 then
    return true
  else
    return false
  end
end
