require 'oc.init'
require 'ocnn.module'
require 'nn'
require 'ocnn.shape'
require 'ocnn.pkg'
--require 'ocnn.classarray'


--- Nerves to be used in AutoEncoders 
-- that reverse the encoding operation
--
-- LinearReverse
-- SpatialConvolutionReverse
-- ReshapeReverse
-- BatchNormalizationReverse
-- FlattenBatchReverse

do
  --- Reverses a Linear OPeration
  --
  -- y = nn.Linear(2, 4)
  -- y:rev() -> will result in a 
  --   nn.Linear(4, 2) once defined
  local LinearReverse, parent = oc.class(
    'ocnn.LinearReverse', oc.Reverse
  )
  ocnn.LinearReverse = LinearReverse
  
  function LinearReverse:__init(nerve, dynamic)
    parent.__init(self, nerve, dynamic)
    self._toShare = false
  end
  
  function LinearReverse:share(toShare)
    toShare = toShare or true
    self._toShare = toShare
  end
  
  function LinearReverse:_define(input)
    local linear = self._toReverse
    
    local linearTranspose = nn.Linear(
      linear.weight:size(1),
      linear.weight:size(2)
    )
    if self._toShare then
      linearTranspose.weight = linear.weight:transpose(1, 2)
    end
    return linearTranspose
  end

  function nn.Linear:rev(dynamic)
    return ocnn.LinearReverse(
      self, dynamic
    )
  end
end


local function calcAdj(op, before, after, d, pad, k)
  return before - ((after - 1) * d) + (2 * pad) - k
end

local function getBeforeAfter(nerve)
  return nerve:getInput(), nerve.output
end

local function getSpatialDimensions(spatial)
  local maps, w, h
  if spatial:dim() == 3 then
    maps = spatial:size(1)
    w = spatial:size(2)
    h = spatial:size(3)
  else
    maps = spatial:size(2)
    w = spatial:size(3)
    h = spatial:size(4)
  end
  return maps, w, h
end
  

do
  --- Reverses SpatialConvolution
  local SpatialConvolutionReverse, parent = oc.class(
    'ocnn.SpatialConvolutionReverse', oc.Reverse
  )
  ocnn.SpatialConvolutionReverse = 
    SpatialConvolutionReverse

  --- Reverse a spatialConvolution operation 
  -- with an upsampling operation
  -- @param conv - The convolution 
  -- operation - nn.SpatialConvolution
  -- @return nn.SpatialFullConvolution
  function SpatialConvolutionReverse:_define(input)
    local conv = self._toReverse
    
    local beforeConv, afterConv = getBeforeAfter(conv)
    local afterMaps, afterW, afterH = getSpatialDimensions(
      afterConv
    )
    local beforeMaps, beforeW, beforeH = getSpatialDimensions(
      beforeConv
    )
    local adjW = calcAdj(
      conv, beforeW, afterW, conv.dW, conv.padW, conv.kW
    )
    local adjH = calcAdj(
      conv, beforeH, afterH, conv.dH, conv.padH, conv.kH
    )
    
    return nn.SpatialFullConvolution(
      conv.nOutputPlane,
      conv.nInputPlane, 
      conv.kW, conv.kH, 
      conv.dW, conv.dH, 
      conv.padW, conv.padH,
      adjW, adjH
    )
  end

  function nn.SpatialConvolution:rev(dynamic)
    return ocnn.SpatialConvolutionReverse(
      self, dynamic
    )
  end
end
  

do
  --- Reverses SpatialMaxPooling
  local SpatialMaxPoolingReverse, parent = oc.class(
    'ocnn.SpatialMaxPoolingReverse', oc.Reverse
  )
  ocnn.SpatialMaxPoolingReverse =
    SpatialMaxPoolingReverse

  --- @brief Reverse a spatial max pooling operation
  -- @param pool - The pooling operation - nn.Pool
  -- @param nInputs - The number of inputs into the pooling op - number
  -- @param nOutputs - The number of outputs into the 
  -- pooling op - number
  -- @return nn.SpatialFullConvolution
  function SpatialMaxPoolingReverse:_define(input)
    local pool = self._toReverse
    local beforePool, afterPool = getBeforeAfter(pool)
    
    local afterMaps, afterW, afterH = getSpatialDimensions(
      afterPool
    )
    local beforeMaps, beforeW, beforeH = getSpatialDimensions(
      beforePool
    )
    local adjW = calcAdj(
      pool, beforeW, afterW, pool.dW, pool.padW, pool.kW
    )
    local adjH = calcAdj(
      pool, beforeH, afterH, pool.dH, pool.padH, pool.kH
    )

    return nn.SpatialFullConvolution(
      beforeMaps,
      beforeMaps,
      pool.kW, pool.kH, 
      pool.dW, pool.dH, 
      pool.padW, pool.padH,
      adjW, adjH
    )
  end

  function nn.SpatialMaxPooling:rev(dynamic)
    return ocnn.SpatialMaxPoolingReverse(
      self, dynamic
    )
  end
end


do
  --- Reverses Reshape
  local ReshapeReverse, parent = oc.class(
    'ocnn.ReshapeReverse', oc.Reverse
  )
  ocnn.ReshapeReverse = ReshapeReverse

  --- Reverse a spatial max pooling operation
  -- @param pool - The pooling operation - nn.Pool
  -- @param nInputs - The number of inputs into the pooling op - number
  -- @param nOutputs - The number of outputs into the pooling op - number
  -- @return nn.SpatialFullConvolution
  function ReshapeReverse:_define(input)
    local reshape = self._toReverse
    local baseSize = reshape:getInput():size()
    local updatedSize = {}
    for i=1, #baseSize - 1 do
      updatedSize[i] = baseSize[i + 1]
    end
    updatedSize[#updatedSize] = reshape.batchMode
    return nn.Reshape(
      table.unpack(updatedSize)
    )
  end

  function nn.Reshape:rev(dynamic)
    return ocnn.ReshapeReverse(
      self, dynamic
    )
  end
end


do
  --- Reverses SpatialConvAndPoolReverse
  local SpatialConvAndPoolReverse, parent = oc.class(
    'ocnn.SpatialConvAndPoolReverse', oc.Reverse
  )
  
  ocnn.SpatialConvAndPoolReverse = 
    SpatialConvAndPoolReverse

  --! Reverses a combination of spatial and pooling
  --! This version makes use of FullConvolution (deconvolution)
  function SpatialConvAndPoolReverse:_define(input)
    local conv, pool = 
      self._toReverse[1], self._toReverse[2]
    local beforePool, afterPool = getBeforeAfter(pool)
    local beforeConv, afterConv = getBeforeAfter(conv)
    
    local afterMaps, afterW, afterH = getSpatialDimensions(
      afterPool
    )
    local beforeMaps, beforeW, beforeH = getSpatialDimensions(
      beforeConv
    )
    
    local padW = pool.padW + conv.padW
    local kW = pool.kW + conv.kW
    local dW = pool.dW * conv.dW
    local padH = pool.padH + conv.padH
    local kH = pool.kH + conv.kH
    local dH = pool.dH * conv.dH
    
    local adjW = calcAdj(
      pool, beforeW, afterW, dW, padW, kW
    )
    local adjH = calcAdj(
      pool, beforeH, afterH, dH, padH, kH
    )
    return oc.Arm(nn.SpatialFullConvolution(
      conv.nOutputPlane,
      conv.nInputPlane,
      kW, kH, 
      dW, dH, 
      padW, padH,
      adjW, adjH
    ))
  end
  
  function SpatialConvAndPoolReverse:internals()
    return {}
    -- return self._toReverse
  end
end


do
  --- Reverses FlattenBatch
  local FlattenBatchReverse, parent = oc.class(
    'ocnn.FlattenBatchReverse', oc.Reverse
  )
  ocnn.FlattenBatchReverse = FlattenBatchReverse

  --- Reverse a spatial max pooling operation
  -- @return nn.SpatialFullConvolution
  function FlattenBatchReverse:_define(input)
    local pool = self._toReverse
    local baseSize = self._toReverse:getInput():size()
    local updatedSize = {}
    for i=2, #baseSize do
      updatedSize[i - 1] = baseSize[i]
    end
    updatedSize[#updatedSize + 1] = true
    return nn.Reshape(
      table.unpack(updatedSize)
    )
  end
  
  function ocnn.FlattenBatch:rev(dynamic)
    return ocnn.FlattenBatchReverse(
      self, dynamic
    )
  end
end


do
  local NarrowReverse, parent = oc.class(
    'ocnn.NarrowReverse', oc.Reverse
  )
  ocnn.NarrowReverse = NarrowReverse

  --- Narrow the output after upsampling based 
  -- on the input into the layer
  -- @param inputSize size of input to create 
  -- torch.LongStorage
  -- @param conv The upsampling convolution to narrow
  function NarrowReverse:_define(input)
    local narrow = self._toReverse
    local input_ = narrow:getInput()
    local postPoolSize = input_:size()[narrow.dimension]
    
    return nn.Narrow(narrow.dimension, 1, postPoolSize)
  end
  
  function nn.Narrow:rev(dynamic)
    return ocnn.NarrowReverse(
      self, dynamic
    )
  end
end

--! The below will be in the Stem 

do
  --- Reverses a combination of 
  -- SpatialConvolution with Pooling
  local SpatialConvAndPoolReverse2, parent = oc.class(
    'ocnn.SpatialConvAndPoolReverse2', oc.Reverse
  )
  ocnn.SpatialConvAndPoolReverse2 = 
    SpatialConvAndPoolReverse2

  --- Reverses a combination of spatial and pooling
  -- This version makes use of UpSampling
  function SpatialConvAndPoolReverse2:_define(input)
    local conv, pool = self._toReverse[1], self._toReverse[2]

    local beforePool, afterPool = getBeforeAfter(pool)
    local beforeConv, afterConv = getBeforeAfter(conv)
    
    local afterMapsPool, afterWPool, afterHPool = 
      getSpatialDimensions(afterPool)
    local beforeMapsConv, beforeWConv, beforeHConv = 
      getSpatialDimensions(beforeConv)
    
    local scale = math.ceil(math.max(
      beforeWConv / afterWPool,
      beforeHConv / afterHPool
    ))
    local owidth = beforeWConv + 1
    local oheight = beforeHConv + 1

    local upscale = nn.SpatialUpSamplingBilinear(
      {owidth=owidth, oheight=oheight}
    )
    
    local postScaleW = owidth
    local postScaleH = oheight
    
    local dW = 1 --math.floor(postScaleW / beforeWConv)
    local dH = 1 --math.floor(postScaleH / beforeHConv)
    local minKW = conv.kW + pool.kW
    local minKH = conv.kH + pool.kH
    
    local kW = math.max(
      conv.kW,
      postScaleW / dW - beforeWConv + 1
    )
    
    local kH = math.max(
      conv.kH,
      postScaleH / dH - beforeHConv + 1
    )
    
    local padW = math.max(
      0, math.floor(
        ((beforeWConv - 1) * dW + kW - postScaleW) / 2
      )
    )
    
    local padH = math.max(
      0, math.floor(((beforeHConv - 1) * dH + kH - postScaleH) / 2)
    )
    local revConv = nn.SpatialConvolution(
      afterMapsPool, beforeMapsConv,
      kW, kH, dW, dH, padW, padH
    )

    return oc.Arm(upscale .. revConv)
  end

  function SpatialConvAndPoolReverse2:internals()
    return {}
    --return self._toReverse
  end
end
-- {nn.SpatialConvolution, nn.SpatialMaxPooling},


local resizeToBatch, updateTensor

do
  --- Reverses BatchNormalization
  local BatchNormalizationReverse, parent = oc.class(
    'ocnn.BatchNormalizationReverse', nn.Module
  )
  ocnn.BatchNormalizationReverse = BatchNormalizationReverse
  
  function BatchNormalizationReverse:std(self)
    return self._normalizer.running_var:pow(0.5)
  end

  function BatchNormalizationReverse:mean(self)
    return self._normalizer.running_mean
  end

  function BatchNormalizationReverse:__init(batchNorm)
    parent.__init(self)
    assert(
      oc.isTypeOf(batchNorm, 'nn.BatchNormalization'),
      'Argument batchNorm must be of type '..
      'BatchNormalization'
    )
    self._normalizer = batchNorm
  end

  function BatchNormalizationReverse:updateOutput(input)
    self.output = updateTensor(self.output, input):zero()
    
    if input:nElement() > 0 then
      self.output:add(input):add(
        resizeToBatch(input, self:mean())
      ):cmul(
        resizeToBatch(input, self:std())
      )
    end
    return self.output
  end
  
  function BatchNormalizationReverse:updateGradInput(
    input, gradOutput
  )
    self.gradInput = updateTensor(
      self.gradInput, 
      input
    ):zero()
    self.gradInput:add(gradOutput):cmul(
      resizeToBatch(input, self:std())
    )
    return self.gradInput
  end
  
  
  function nn.BatchNormalization:rev()
    return ocnn.BatchNormalizationReverse(self)
  end
  --[[
  function nn.SpatialBatchNormalization:rev(dynamic)
    --! TODO Figure out what to od here.
    --! probably need a reverse class here
  end
  --]]
end

--- @param target
-- @param base
resizeToBatch = function (target, base)
  return torch.repeatTensor(
    base, target:size(1), 1
  )
end

--- @param curTensor
-- @param input_
updateTensor = function (curTensor, input_)
  if tostring(input_:size()) ~= 
     tostring(curTensor:size()) then
    return curTensor:typeAs(
      input_
    ):resizeAs(input_)
  else
    return curTensor
  end
end
