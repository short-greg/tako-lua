local matrixops = {}

--! @module matrixops
--! Includes operations to help in doing row-column matrix 
--! operations such as maxmin composition, 
--! euclidean distance between and so on
--! Because some of these operations may require a lot of 
--! memory, there most of the operations are for dealing
--! with sub matrices.

function matrixops.divideMatrix(m, count, dim)
  local result = {}
  local dimSize = m:size(dim)
  local stepSize = dimSize / count
  for i=0, count - 1 do
    table.insert(result, m:narrow(
      dim, (i * stepSize) + 1, 
      math.min(stepSize, dimSize - (i * stepSize))
    ))
  end
  return result
end

function matrixops.subMatrixLoop(m1s, m2s)
  --! Loop through two sets of matrices (can be created
  --! with divideMatrix) and output each combination
  --! @param m1s - {torch.Tensor()} 
  --! @param m2s - {torch.Tensor()}
  --! @return function (for looping)
  local i, j = 1, 1
  
  local function loop()
    --! returns tensor combination
    --! @return torch.Tensor, torch.Tensor
    if j > #m2s then
      return
    end
    local m1 = m1s[i]
    local m2 = m2s[j]
    i = i + 1
    if i > #m1s then
      i = 1
      j = j + 1
    end
    return m1, m2
  end

  return loop
end


function matrixops.getExpanded(
    m1, m2
)
  --! Expand two matrices so that they have the 
  --! 3 dimensions and the first dimension size is 
  --! equal to m1:size(1) and the second dimesnion size
  --! is m2:size(1) and the third is equal to m1:size(2) 
  --! and m2:size(2)
  --! @param m1 - torch.Tensor
  --! @param m2 - torch.Tensor
  --! @return torch.Tensor, torch.Tensor
  local m1BaseSize = m1:size()
  local m2BaseSize = m2:size()
  local mExpandedSize = torch.LongStorage(
    #m1BaseSize + 1
  )
  mExpandedSize[1] = m1BaseSize[1]
  mExpandedSize[2] = m2BaseSize[1]
  mExpandedSize[3] = m2BaseSize[2]
  local m1Expanded = torch.Tensor(
    mExpandedSize
  )
  local m2Expanded = m1Expanded:clone()
  return m1Expanded, m2Expanded
end

function matrixops.narrowExpanded(
    m1, m1Expanded,
    m2, m2Expanded
)
  --! If dimension size / step size  != floor(dimension size /
  --! step size) the final matrix may not be of the same
  --! size as the other.  In this case the expanded matrix
  --! should be narrowed to accomadate for matrices of a
  --! smaller size.
  --! @param m1
  --! @param m1Expanded
  --! @param m2
  --! @param m2Expanded

  local narrowed1, narrowed2 = m1Expanded, m2Expanded
  if m1:size(1) < m1Expanded:size(1) then
    narrowed1 = narrowed1:narrow(1, 1, m1:size(1))
    narrowed2 = narrowed2:narrow(1, 1, m1:size(1))
  end
  if m2:size(1) < m1Expanded:size(2) then
    narrowed1 = narrowed1:narrow(2, 1, m2:size(1))
    narrowed2 = narrowed2:narrow(2, 1, m2:size(1))
  end
  return narrowed1, narrowed2
end

function matrixops.expandMatrices(
    m1, m1Expanded, m1BaseSize, 
    m2, m2Expanded, m2BaseSize
)
  --! Expands the matrices m1 and m2 so that they
  --! are the same size 
  --! @param m1
  --! @param m1Expanded 
  --! @param m1BaseSize
  --! @param m2
  --! @param m2Expanded
  --! @param m2BaseSize
  
  -- the resulting tensors should be the same
  -- size for m1 and m2
  torch.repeatTensor(
    m1Expanded,
    m1:view(1, m1:size(1), m1:size(2)), 
    m2BaseSize[1], 1, 1
  )
  torch.repeatTensor(
    m2Expanded,
    m2:view(m2:size(1), 1, m2:size(2)), 
    1, m1BaseSize[1], 1
  )
end


function matrixops.mergeMatricesLoop(
    matrices, resultMatrix, rSize, cSize
)
  --! Merge all of the matrices in the parameter matrices
  --! into one matrix (the result matrix)
  --! @param matrices {tensor} (2 dimensional)
  --! @param resultMatrix - Matrix to put the result into
  --!   (2 dimensional)
  --! 
  local rSubResult
  local cSubResult
  local idx = 1
  for i=0, i < rSize do
    rSubResult = result:narrow(
      1, (i * matrices[idx]:size(1)) + 1, 
      matrices[idx]:size(1)
    )
    for j=0, j < cSize do
      cSubResult = rSubResult:narrow(
        2, (j * matrices[idx]:size(2)) + 1, 
        matrices[idx]:size(2)
      ):add(matrices[idx])
      idx = idx + 1
    end
  end
end

return matrixops
