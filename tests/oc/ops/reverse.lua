require 'torch'
require 'oc.ops.reverse'
require 'oc.ops.tensor'

function octest.reverse_test_revLinear()
  local mod = nn.Linear(2, 3)
  local weight = mod.weight
  local reverseMod = oc.ops.rev.linear(mod, false)
  octester:eq(
    weight:transpose(1, 2):size(), reverseMod.weight:size(),
    'The size of the weights should be equal'
  )
end

function octest.reverse_test_revLinear_with_share()
  local mod = nn.Linear(2, 3)
  local weight = mod.weight
  local reverseMod = oc.ops.rev.linear(mod, true)
  weight[1][1] = weight[1][1] + 1
  octester:eq(
    weight:transpose(1, 2), reverseMod.weight,
    'The size of the weights should be equal'
  )
end


function octest.reverse_test_revSpatialConvolution()
  local mod = nn.SpatialConvolution(1, 3, 2, 2, 1, 1)
  local input = torch.rand(1, 4, 4)
  local output = mod:stimulate(input)
  local rev = oc.ops.rev.spatialConvolution(mod, input, output)
  local rec = rev:updateOutput(mod:updateOutput(input))
  octester:eq(
    rec:size(), input:size(),
    'The size of the reconstructed value and input should be equal'
  )
end

function octest.reverse_test_revSpatialConvolution_with_padding()
  local mod = nn.SpatialConvolution(1, 3, 2, 2, 1, 1, 2, 2)
  local input = torch.rand(1, 4, 4)
  local output = mod:stimulate(input)
  local rev = oc.ops.rev.spatialConvolution(mod)
  local rec = rev:updateOutput(mod:updateOutput(input))
  octester:eq(
    rec:size(), input:size(),
    'The size of the reconstructed value and input should be equal'
  )
end

function octest.reverse_test_revSpatialPooling()
  local mod = nn.SpatialMaxPooling(2, 2, 1, 1)
  local input = torch.rand(1, 4, 4)
  local output = mod:stimulate(input)
  local rev = oc.ops.rev.spatialPooling(mod, input, output)
  local rec = rev:updateOutput(mod:updateOutput(input))
  octester:eq(
    rec:size(), input:size(),
    'The size of the reconstructed value and input should be equal'
  )
end

function octest.reverse_test_narrowTo()
  local postPoolSize = torch.LongStorage{1, 1, 4, 4}
  local input = torch.randn(1, 1, 6, 6)
  local narrow1 = oc.ops.rev.narrowTo(postPoolSize, 3)
  local narrow2 = oc.ops.rev.narrowTo(postPoolSize, 4)
  local output = narrow1:updateOutput(narrow2:updateOutput(input))
  octester:eq(
    output:size(), postPoolSize,
    'The size of the reconstructed value and input should be equal'
  )
end


