require 'torch'
require 'oc.data.accessor'

function octest.data_accessor_base_init()
  local data = oc.data.accessor.Base()
end

function octest.data_accessor_batchtensor_init()
  local data = oc.data.accessor.BatchTensor(
    torch.randn(4, 4)
  )
  
end

function octest.data_accessor_batchtensor_retrieverange()
  local input = torch.randn(4, 4)
  local data = oc.data.accessor.BatchTensor(
    input
  )
  
  local result = data:retrieveRange(2, 4)

  octester:eq(
    result, input:narrow(1, 2, 3),
    'The result is incorrect'
  )
end

function octest.data_accessor_batchtensor_retrieveindices()
  local input = torch.randn(4, 4)
  local data = oc.data.accessor.BatchTensor(
    input
  )
  local indices = torch.LongTensor{4, 3, 2}
  local result = data:retrieveIndices(indices)

  octester:eq(
    result, input:index(1, torch.LongTensor(indices)),
    'The result is incorrect'
  )
end

function octest.data_accessor_compositetensor_retrievecolindices()
  local input = torch.randn(4, 4)
  local input2 = torch.randn(4, 4)
  
  local data = oc.data.accessor.Composite(
    {
      oc.data.accessor.BatchTensor(
        input
      ),
      oc.data.accessor.BatchTensor(
        input2
      )  
    }
  )
  local indices = torch.LongTensor{4, 3, 2}
  local result = data:retrieveColIndices({1}, indices)

  octester:eq(
    #result, 1,
    'The result is of the incorrect size'
  )
  octester:eq(
    result[1], input:index(1, torch.LongTensor(indices)),
    'The result is incorrect'
  )
end

function octest.data_accessor_compositetensor_retrievecolrange()
  local input = torch.randn(4, 4)
  local input2 = torch.randn(4, 4)
  
  local data = oc.data.accessor.Composite(
    {
      oc.data.accessor.BatchTensor(
        input
      ),
      oc.data.accessor.BatchTensor(
        input2
      )  
    }
  )
  local result = data:retrieveColRange({2, 1}, 2, 3)

  octester:eq(
    #result, 2,
    'The result is of the incorrect size'
  )
  octester:eq(
    result[1], input2:narrow(1, 2, 2),
    'The result is incorrect'
  )
  octester:eq(
    result[2], input:narrow(1, 2, 2),
    'The result is incorrect'
  )
end


