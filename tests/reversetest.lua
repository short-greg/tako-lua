do
  require 'ocnn.reverse'
  
  local y = nn.SpatialConvolution(1, 2, 4, 4)
  local z = y:rev()
  local f = y .. z
  local input_ = torch.randn(1, 5, 5)
  local result = f:stimulate(input_)
  assert(
    tostring(result:size()) == tostring(input_:size()),
    'The size of result and input should be the same.'
  )
end


do
  require 'ocnn.reverse'
  
  local y = nn.Linear(2, 4)
  local z = y:rev()
  local f = y .. z
  local input_ = torch.randn(2)
  local result = f:stimulate(input_)
  assert(
    tostring(result:size()) == tostring(input_:size()),
    'The size of result and input should be the same.'
  )
end


do
  require 'ocnn.reverse'
  
  local y = nn.SpatialMaxPooling(2, 2, 2, 2)
  local z = y:rev()
  local f = y .. z
  local input_ = torch.randn(1, 6, 6)
  local result = f:stimulate(input_)
  assert(
    tostring(result:size()) == tostring(input_:size()),
    'The size of result and input should be the same.'
  )
end


do
  require 'ocnn.reverse'
  
  local y1 = nn.SpatialConvolution(1, 2, 2, 2, 1, 1)
  local y2 = nn.SpatialMaxPooling(2, 2, 2, 2)
  local z = ocnn.SpatialConvAndPoolReverse2({y1, y2})
  local f = y1 .. y2 .. z
  
  
  local input_ = torch.randn(1, 6, 6)
  local result = f:stimulate(input_)
  assert(
    tostring(result:size()) == tostring(input_:size()),
    'The size of result and input should be the same.'
  )
end


do
  require 'ocnn.reverse'
  
  local y1 = nn.SpatialConvolution(1, 2, 2, 2, 1, 1)
  local y2 = nn.SpatialMaxPooling(2, 2, 2, 2)
  local z = ocnn.SpatialConvAndPoolReverse({y1, y2})
  local f = y1 .. y2 .. z
  
  local input_ = torch.randn(1, 6, 6)
  local result = f:stimulate(input_)
  assert(
    tostring(result:size()) == tostring(input_:size()),
    'The size of result and input should be the same.'
  )
end
