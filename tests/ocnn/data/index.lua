require 'ocnn.data.index'


function octest.data_index_tensor_indices()
  local index = oc.data.index.Index(1)
  local indices = index:tensorIndices(
    torch.LongTensor{1}
  )
  octester:eq(
    oc.type(indices), 'ocnn.data.index.Indices',
    ''
  )
end


function octest.data_index_range()
  local index = oc.data.index.IndexRange(1, 4)
  local indices = index:tensorIndices(
    torch.LongTensor{1, 2}
  )
  octester:eq(
    oc.type(indices), 'ocnn.data.index.Indices',
    ''
  )
end


function octest.data_index_range_expand()
  local index = oc.data.index.IndexRange(1, 4)
  local expanded = index:expand(2)
  octester:eq(
    oc.type(expanded), 'oc.data.index.IndexRange',
    ''
  )
  octester:eq(
    expanded._startingVal, 1,
    ''
  )
  octester:eq(
    expanded._frameSize, 8,
    ''
  )
end


function octest.data_index_range_rand_tensor()
  local index = oc.data.index.IndexRange(2, 2)
  local tensor = torch.randn(6)
  local subTensor = index:indexOnTensor(tensor)
  octester:eq(
    subTensor,
      tensor:index(
        1, torch.range(2, 3):long()
      ),
    ''
  )
end


function octest.data_index_range_index_on_table()
  local index = oc.data.index.IndexRange(2, 2)
  local sub = index:indexOn({3, 2, 4, 5, 6, 7})
  octester:eq(
    sub[1], 2, ''
  )
  octester:eq(
    sub[2], 4,
    ''
  )
end


function octest.data_indices_on_tensor()
  local index = ocnn.data.index.Indices(
    torch.LongTensor{5, 2, 1}
  )
  local tensor = torch.randn(6)
  local subTensor = index:indexOnTensor(tensor)
  octester:eq(
    subTensor[1], tensor[5],
    ''
  )
  octester:eq(
    subTensor[2], tensor[2],
    ''
  )
  octester:eq(
    subTensor[3], tensor[1],
    ''
  )
end


function octest.data_indices_on_tensor_expanded()
  local index = ocnn.data.index.Indices(
    torch.LongTensor{4, 2}
  )
  local expanded = index:expand(2)
  local expandedComp = torch.LongTensor{
    7, 8, 3, 4
  }
  octester:eq(
    expanded._indices, expandedComp,
    ''
  )
end


function octest.data_indices_on_tensor_offset()
  local index = ocnn.data.index.Indices(
    torch.LongTensor{4, 2}
  )
  local offset = index:offset(2)
  local offsetComp = torch.LongTensor{
    6, 4
  }
  octester:eq(
    offset._indices, offsetComp,
    ''
  )
end


function octest.data_indices_on_tensor_randomish_order()
  local index = ocnn.data.index.Indices(
    torch.LongTensor{4, 2}
  )
  local sub = index:indexOn({3, 2, 4, 5, 6, 7})
  octester:eq(
    sub[1], 5
  )
  octester:eq(
    sub[2], 2,
    ''
  )
end


function octest.data_indices_on_tensor_indices()
  local index = ocnn.data.index.Indices(
    torch.LongTensor{4, 2, 3, 5}
  )
  local sub = index:tensorIndices(
    torch.LongTensor{2, 1, 4}
  )
  octester:eq(
    sub._indices[1], 2, ''
  )
  octester:eq(
    sub._indices[2], 4, ''
  )
  octester:eq(
    sub._indices[3], 5,
    ''
  )
end

function octest.data_indices_on_index_range_with_tensor_indices()
  local index = oc.data.index.IndexRange(2, 4)
  local sub = index:tensorIndices(torch.LongTensor{2, 1, 4})
  octester:eq(
    sub._indices[1], 3, '' 
  )
  octester:eq(
    sub._indices[2], 2, '' 
  )
  octester:eq(
    sub._indices[3], 5,
    ''
  )
end

function octest.data_indices_on_index_with_tensor()
  local index = oc.data.index.Index(2)
  local sub = index:tensorIndices(torch.LongTensor{1})
  octester:eq(
    sub._indices[1], 2,
    ''
  )
end


function octest.data_index_update_indexed_with_tensor()
  local index = oc.data.index.Index(2)
  local tensor1 = torch.zeros(4, 4)
  local tensor2 = torch.ones(1, 4)
  index:indexUpdateTensor(tensor1, tensor2)
  octester:eq(
    tensor1:narrow(1, 2, 1), tensor2,
    ''
  )
end


function octest.data_index_range_update_with_tensor()
  local index = oc.data.index.IndexRange(2, 2)
  local tensor1 = torch.zeros(4, 4)
  local tensor2 = torch.ones(2, 4)
  index:indexUpdateTensor(tensor1, tensor2)
  octester:eq(
    tensor1:narrow(1, 2, 2), tensor2,
    ''
  )
end


function octest.data_indices_update_with_tensor()
  local index = ocnn.data.index.Indices(
    torch.LongTensor{3, 1}
  )
  local tensor1 = torch.zeros(4, 4)
  local tensor2 = torch.randn(2, 4)
  
  index:indexUpdateTensor(tensor1, tensor2)
  octester:eq(
    tensor1:index(
      1, torch.LongTensor{3, 1}
    ), tensor2,
    ''
  )
end
