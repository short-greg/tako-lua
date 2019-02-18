require 'torch'
require 'oc.ops.tensor'


function octest.ops_expandTo_with_one_dim()
  local expandFrom = torch.Tensor{{1, 1}}
  local expandBase = torch.Tensor{
    {1, 2},
    {3, 4},
    {4, 5}
  }
  local expandTo = torch.Tensor{
    {1, 1},
    {1, 1},
    {1, 1}
  }
  octester:eq(
    oc.ops.tensor.expandTo(
      expandFrom, expandBase
    ),
    expandTo,
    'Tensor not expanded properly'
  )
end

function octest.ops_expandTo_with_two_dim()
  local expandFrom = torch.Tensor{{1, 1}}
  local expandBase = torch.Tensor{
    {1, 2},
    {3, 4},
    {4, 5}
  }
  local expandTo = torch.Tensor{
    {1, 1},
    {1, 1},
    {1, 1}
  }
  octester:eq(
    oc.ops.tensor.expandTo(expandFrom, expandBase),
    expandTo,
    'Tensor not expanded properly'
  )
end

function octest.ops_sampleSizeOf_with_one_dim()
  local sample = torch.Tensor{{1, 1}}
  octester:eq(
    oc.ops.tensor.sampleSizeOf(sample),
    torch.LongStorage{1, 2}
  )
end

function octest.ops_sampleSizeOf_with_two_dim()
  local sample = torch.Tensor{{1, 1, 1}, {2, 2, 3}}
  octester:eq(
    oc.ops.tensor.sampleSizeOf(sample),
    torch.LongStorage{1, 3}
  )
end

function octest.ops_sampleSizeEqual_with_one_eq()
  local sample = torch.Tensor{{1, 1}}
  local sample2 = torch.Tensor{{1, 2}}
  octester:eq(
    oc.ops.tensor.sampleSizeEqual(sample, sample2),
    true
  )
end

function octest.ops_sampleSizeEqual_with_one_ne()
  local sample = torch.Tensor{{1, 1}}
  local sample2 = torch.Tensor{{1, 2, 3}}
  octester:eq(
    oc.ops.tensor.sampleSizeEqual(sample, sample2),
    false
  )
end

function octest.ops_sampleSizeEqual_with_two_eq()
  local sample = torch.Tensor{{1, 1}, {2, 4}}
  local sample2 = torch.Tensor{{1, 2}, {6, 4}}
  octester:eq(
    oc.ops.tensor.sampleSizeEqual(sample, sample2),
    true
  )
end

function octest.ops_sampleSizeEqual_with_two_ne()
  local sample = torch.Tensor{{1, 1}, {1, 4}}
  local sample2 = torch.Tensor{{1, 2, 3}, {3, 4, 5}}
  octester:eq(
    oc.ops.tensor.sampleSizeEqual(sample, sample2),
    false
  )
end

function octest.ops_sampleSizeEqual_with_one_dim()
  local sample = torch.Tensor{1, 4}
  local sample2 = torch.Tensor{4, 5}
  octester:eq(
    oc.ops.tensor.sampleSizeEqual(sample, sample2),
    false
  )
end

function octest.ops_sizeEqual_with_two_ne()
  local sample = torch.Tensor{{1, 1}, {1, 4}}
  local sample2 = torch.Tensor{{1, 2, 3}, {3, 4, 5}}
  octester:eq(
    oc.ops.tensor.sizeEqual(sample, sample2),
    false
  )
end

function octest.ops_sizeEqual_with_two_eq()
  local sample = torch.Tensor{{1, 1}, {1, 4}}
  local sample2 = torch.Tensor{{1, 2}, {3, 4}}
  octester:eq(
    oc.ops.tensor.sizeEqual(sample, sample2),
    true
  )
end

function octest.ops_sizeEqual_with_one_eq()
  local sample = torch.Tensor{1, 1}
  local sample2 = torch.Tensor{1, 2}
  octester:eq(
    oc.ops.tensor.sizeEqual(sample, sample2),
    true
  )
end

function octest.ops_sizeEqual_with_none()
  local sample = torch.Tensor{}
  local sample2 = torch.Tensor{}
  octester:eq(
    oc.ops.tensor.sizeEqual(sample, sample2),
    true
  )
end
