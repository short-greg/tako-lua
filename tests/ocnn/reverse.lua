require 'oc.init'
require 'ocnn.module'
require 'ocnn.reverse'


function octest.reverse_spatialconvolution()
  local y = nn.SpatialConvolution(1, 2, 4, 4)
  local z = y:rev()
  local f = y .. z
  local input_ = torch.randn(1, 5, 5)
  local result = f:stimulate(input_)
  octester:assert(
    tostring(result:size()) == tostring(input_:size()),
    'The size of result and input should be the same.'
  )
end


function octest.reverse_linear()
  local y = nn.Linear(2, 4)
  local z = y:rev()
  local f = y .. z
  local input_ = torch.randn(2)
  local result = f:stimulate(input_)
  octester:assert(
    tostring(result:size()) == tostring(input_:size()),
    'The size of result and input should be the same.'
  )
end


function octest.reverse_max_pooling()
  local y = nn.SpatialMaxPooling(2, 2, 2, 2)
  local z = y:rev()
  local f = y .. z
  local input_ = torch.randn(1, 6, 6)
  local result = f:stimulate(input_)
  octester:eq(
    tostring(result:size()), 
    tostring(input_:size()),
    'The size of result and input ' ..
    'should be the same.'
  )
end


function octest.reverse_combo_pooling_and_convolution2()
  local y1 = nn.SpatialConvolution(
    1, 2, 2, 2, 1, 1
  )
  local y2 = nn.SpatialMaxPooling(2, 2, 2, 2)
  local z = ocnn.SpatialConvAndPoolReverse2({y1, y2})
  local f = y1 .. y2 .. z
  
  
  local input_ = torch.randn(1, 6, 6)
  local result = f:stimulate(input_)
  octester:assert(
    tostring(result:size()) == tostring(input_:size()),
    'The size of result and input should be the same.'
  )
end


function octest.reverse_combo_pooling_and_convolution()
  local y1 = nn.SpatialConvolution(1, 2, 2, 2, 1, 1)
  local y2 = nn.SpatialMaxPooling(2, 2, 2, 2)
  local z = ocnn.SpatialConvAndPoolReverse({y1, y2})
  local f = y1 .. y2 .. z
  
  local input_ = torch.randn(1, 6, 6)
  local result = f:stimulate(input_)
  octester:assert(
    tostring(result:size()) == tostring(input_:size()),
    'The size of result and input should be the same.'
  )
end
