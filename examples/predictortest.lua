require 'ocnn.init'
require 'data.mnist'
require 'optim'
require 'trans.shape'
mp = require 'multiprogress'

local Predictor, Teacher

local BATCH_SIZE = 32

do
  Predictor = oc.tako(
    'Predictor'
  )
  Predictor.arm.predict = trans.FlattenBatch:d() ..
    nn.Linear:d(784, 32) ..
    nn.ReLU:d() ..
    nn.Linear:d(32, 10) ..
    nn.Sigmoid:d()
  
  Predictor.arm.recognize = oc.my.arm.predict ..
    -- recognize
    function (self, input)
      --! @param input - torch.Tensor (batchsize, 10)
      local val, index = torch.max(
        input, 2
      )
      return (index:view(index:nElement()) - 1):double()
    end
  
  Predictor.arm.evaluate = oc.flow.Diverge{
      oc.my.arm.recognize,
      oc.Noop()
    } ..
    function (self, input)
      local prediction, target = input[1], input[2]
      local eq = torch.eq(prediction, target)
      local result = {}
      for i=0, 9 do
        local toCheck = torch.eq(target, i)
        local total = toCheck:sum()
        local predicted = torch.cmul(
          toCheck, eq
        ):sum()
        table.insert(result, {predicted, total})
      end
      return result
    end

  Predictor.arm.predictTrain = oc.flow.Diverge{
      oc.my.arm.predict,
      --! targets need to be shifted one because it has zeroes
      function (self, input) return input + 1 end
      --oc.my.add1(oc.input)
    } .. ocnn.Criterion(nn.CrossEntropyCriterion())
end

ImageDataIter = oc.Arm:stem(
  --! @input nil
  --! @output DataTable Accessor
  --! @param 1 - Accessor
  --! @param 2 - Batch size
  --y:test() .. 
  oc.Arg(1) ..
  ocnn.data.accessor.Batch:d(oc.Arg(2)) .. 
  ocnn.data.accessor.Relabel({image=1, label=2}) .. 
  ocnn.data.accessor.Random()
)

mnistData = ocnn.data.MNIST(0.1)
mnistData:apply(
  function (data) return data:double() end,
  {'image', 'label'}
)
mnistData:apply(
  function (data) return data / 255 end,
  {'image'}
)

function bool2num(val)
  --! @param val - boolean
  return val and 1 or 0
end

DataLoop = oc.Arm:stem(
  --! @input DataTable Accessor
  --! @output 
  oc.ToIter() .. 
    oc.flow.Repeat(
      oc.Iterate() .. 
      --! @input DataTable
      oc.flow.Multi{n=2} .. 
      oc.flow.Gate(
        function (self, input_) 
          --! convert bool to number
          return bool2num(input_)
        end,
        ocnn.data.ToTable() ..
        oc.Arg(1)
      ) .. function (self, input)
        local output = {
          input[1], self._prev
        }
        self._prev = input[2]
        return output
      end
))

Through = oc.Arm:stem(
  --! Send a value through a process but output the
  --! input
  oc.flow.Multi{
    oc.Noop(),
    oc.Arg(1)
  }[1]
)

Append = oc.Arm:stem(
  --! Send a value through a process but output the
  --! input
  oc.flow.Multi{
    oc.Noop(),
    oc.Arg(1)
  }
)

Prepend = oc.Arm:stem(
  --! Send a value through a process but output the
  --! input
  oc.flow.Multi{
    oc.Arg(1),
    oc.Noop()
  }
)


do
  Teacher = oc.tako(
    'Teacher'
  )
  Teacher.arm.train = oc.flow.Repeat:d(
    oc.flow.Under:d(function () return {count=0}; end) ..
      oc.flow.Gate:d(
        function (self, input)
          input.count = input.count + 1
          return bool2num(
            input.count <= self._owner._iterations
          )
        end,
        --! 
        oc.my.arm.trainBatch
      )
    )  ..
    oc.my:resetState()

  Teacher.arm.trainSample = 
    oc.my._predictor.predictTrain:stimulate(oc.input) ..
    oc.my:outputResult(oc.input)

  Teacher.arm.optim = nil
  Teacher.arm.testBatch = 
    ImageDataIter{
      mnistData:test(), 32
    } .. DataLoop{
      oc.my._predictor.evaluate:stimulate(oc.input) ..
      oc.flow.Onto(function (self, input) return {} end):lab(
        'Storer Merge'
      ) ..
      function (self, input)
        --! @param input[1] - the counts for the current 
        --! @param input[2] - the counts 
        local curCounts, accCounts = input[1], input[2]
        for i=1, 10 do
          if accCounts[i] then
            accCounts[i][1] = accCounts[i][1] + 
              curCounts[i][1]
            input[2][i][2] = accCounts[i][2] + 
              curCounts[i][2]
          else
            input[2][i] = {
              curCounts[i][1], curCounts[i][2]
            }
          end
        end
        return input[2]
      end
    } .. function (self, input) 
      --! print out the accumulated counts
      for i=1, #input do
        print(i - 1) 
        print('Rate: ', input[i][1] / input[i][2])
        print('Correct: ', input[i][1], 'Total', input[i][2])
      end
    end
  
  Teacher.arm.trainBatch = 
    ImageDataIter{
      mnistData:training(), 32
    } .. 
      Through{
        function (self, input) self._owner.curSample = 1 end
      } ..
      DataLoop{
      -- function (self, input) print('Training'); return input end ..
        Through{
          oc.my.arm.trainSample
        } .. 
        Through{
          oc.my._predictor.predictTrain:stimulateGrad()
        } ..
        Through{
          oc.my._predictor.predictTrain:accumulate()
        } ..
        Through{oc.my.arm.optim} ..
        Through{
          function (self, input) 
            self._owner.curSample = self._owner.curSample + 1 
          end
        }
    }

  function Teacher:__init(predictor, iterations)
    self._predictor = predictor
    self._iterations = iterations
    self._iteration = 1
    self.optim = ocnn.Optim:d(
      optim.sgd,
      self._predictor.predict,
      {learningRate=1e-1}
    )
    self.curSample = 1
    self._iteration = 1
  end

  function Teacher:outputResult(result)
    if self._result then
      self._result = self._result * 0.95 + 
        result * 0.05
    else
      self._result = result
    end
    mp.info(
      'Loss '..tostring(
        math.floor(
          self._result * 100000 + 0.5
        ) / 100000
      ), 5
    )
    mp.progress(self.curSample, math.floor(54000 / BATCH_SIZE), 6)
  end

  function Teacher:resetState()
    self._iteration = 1
    self._curSample = 1
    mp.resetProgress()
  end
end

local predictor = Predictor()
local teacher = Teacher(predictor, 6)
teacher.train:stimulate()
collectgarbage()
teacher.testBatch:stimulate()
collectgarbage()
--
--t = teacher.train._module:strand()[2]:super()
