
do
  require 'ocnn.data.index'
  local index = oc.data.index.Index(1)
  local indices = index:tensorIndices(
    torch.LongTensor{1}
  )
  assert(
    oc.type(indices) == 'ocnn.data.index.Indices',
    ''
  )
end


do
  require 'ocnn.data.index'
  local index = oc.data.index.IndexRange(1, 4)
  local indices = index:tensorIndices(
    torch.LongTensor{1, 2}
  )
  assert(
    oc.type(indices) == 'ocnn.data.index.Indices',
    ''
  )
end


do
  require 'ocnn.data.index'
  local index = oc.data.index.IndexRange(1, 4)
  local expanded = index:expand(2)
  assert(
    oc.type(expanded) == 'oc.data.index.IndexRange',
    ''
  )
  print(
    expanded._startingVal, expanded._frameSize
  )
  assert(
    expanded._startingVal == 1,
    ''
  )
  assert(
    expanded._frameSize == 8,
    ''
  )
end


do
  require 'ocnn.data.index'
  local index = oc.data.index.IndexRange(2, 2)
  local tensor = torch.randn(6)
  local subTensor = index:indexOnTensor(tensor)
  assert(
    subTensor:eq(tensor:index(1, torch.range(2, 3):long())),
    ''
  )
end


do
  require 'ocnn.data.index'
  local index = oc.data.index.IndexRange(2, 2)
  local sub = index:indexOn({3, 2, 4, 5, 6, 7})
  assert(
    sub[1] == 2 and sub[2] == 4,
    ''
  )
end


do
  require 'ocnn.data.index'
  local index = ocnn.data.index.Indices(
    torch.LongTensor{5, 2, 1}
  )
  local tensor = torch.randn(6)
  local subTensor = index:indexOnTensor(tensor)
  assert(
    subTensor[1] == tensor[5],
    ''
  )
  assert(
    subTensor[2] == tensor[2],
    ''
  )
  assert(
    subTensor[3] == tensor[1],
    ''
  )
end

do
  require 'ocnn.data.index'
  local index = ocnn.data.index.Indices(
    torch.LongTensor{4, 2}
  )
  local expanded = index:expand(2)
  local expandedComp = torch.LongTensor{
    7, 8, 3, 4
  }
  assert(
    expanded._indices:equal(expandedComp),
    ''
  )
end


do
  require 'ocnn.data.index'
  local index = ocnn.data.index.Indices(
    torch.LongTensor{4, 2}
  )
  local offset = index:offset(2)
  local offsetComp = torch.LongTensor{
    6, 4
  }
  assert(
    offset._indices:equal(offsetComp),
    ''
  )
end


do
  require 'ocnn.data.index'
  local index = ocnn.data.index.Indices(torch.LongTensor{4, 2})
  local sub = index:indexOn({3, 2, 4, 5, 6, 7})
  assert(
    sub[1] == 5 and sub[2] == 2,
    ''
  )
end


do
  require 'ocnn.data.index'
  local index = ocnn.data.index.Indices(torch.LongTensor{4, 2, 3, 5})
  local sub = index:tensorIndices(torch.LongTensor{2, 1, 4})
  assert(
    sub._indices[1] == 2 and sub._indices[2] == 4 and sub._indices[3] == 5,
    ''
  )
end

do
  require 'ocnn.data.index'
  local index = oc.data.index.IndexRange(2, 4)
  local sub = index:tensorIndices(torch.LongTensor{2, 1, 4})
  assert(
    sub._indices[1] == 3 and sub._indices[2] == 2 and sub._indices[3] == 5,
    ''
  )
end

do
  require 'ocnn.data.index'
  local index = oc.data.index.Index(2)
  local sub = index:tensorIndices(torch.LongTensor{1})
  assert(
    sub._indices[1] == 2,
    ''
  )
end

do
  require 'ocnn.data.index'
  local index = oc.data.index.Index(2)
  local tensor1 = torch.zeros(4, 4)
  local tensor2 = torch.ones(1, 4)
  index:indexUpdateTensor(tensor1, tensor2)
  assert(
    tensor1:narrow(1, 2, 1):eq(tensor2),
    ''
  )
end


do
  require 'ocnn.data.index'
  local index = oc.data.index.IndexRange(2, 2)
  local tensor1 = torch.zeros(4, 4)
  local tensor2 = torch.ones(2, 4)
  index:indexUpdateTensor(tensor1, tensor2)
  assert(
    tensor1:narrow(1, 2, 2):eq(tensor2),
    ''
  )
end


do
  require 'ocnn.data.index'
  local index = ocnn.data.index.Indices(torch.LongTensor{3, 1})
  local tensor1 = torch.zeros(4, 4)
  local tensor2 = torch.randn(2, 4)
  
  index:indexUpdateTensor(tensor1, tensor2)
  assert(
    tensor1:index(
      1, torch.LongTensor{3, 1}
    ):eq(tensor2),
    ''
  )
end
