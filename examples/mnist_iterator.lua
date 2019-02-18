
do
  require 'oc.iter'
  require 'ocnn.data.accessor'
  require 'data.mnist'
  require 'oc.stem'
  MNISTIter = oc.Arm:stem(
    --y:test() .. 
    oc.Arg(1) ..
    ocnn.data.accessor.Batch:d(oc.Arg(2)) .. 
    ocnn.data.accessor.Relabel:d({image=1, label=2}) .. 
    ocnn.data.accessor.Random:d()
  )
  data = ocnn.data.MNIST(0.1)
  t = MNISTIter{oc.nerve(data:test()), 16}
  t = MNISTIter{oc.nerve(data:training()), 16}
  t = MNISTIter{oc.nerve(data:validation()), 16}
end


do
  require 'oc.iter'
  require 'ocnn.data.accessor'
  require 'data.mnist'
  require 'oc.stem'
  MNISTIter = oc.Arm:stem(
    --y:test() .. 
    oc.Arg(1) ..
    ocnn.data.accessor.Batch:d(oc.Arg(2)) .. 
    ocnn.data.accessor.Relabel:d({image=1, label=2}) .. 
    ocnn.data.accessor.Random:d()
  )
  
  loop = oc.ToIter() .. oc.flow.Repeat(
    oc.Iterate() .. ocnn.data.ToTable()[1] .. 
      oc.flow.Multi{n=2} .. 
      oc.flow.Gate(
        function (self, input_) 
          return (input_ ~= nil) and 1 or 0 
        end
      )
  ):gradOff()
  
  data = ocnn.data.MNIST(0.1)
  t = MNISTIter{oc.nerve(data:test()), 16} .. loop
end


do
  require 'oc.iter'
  require 'ocnn.init'
  require 'ocnn.data.accessor'
  require 'data.mnist'
  require 'oc.stem'
  MNISTIter = oc.Arm:stem(
    --! @input nil
    --! @output DataTable Accessor
    --y:test() .. 
    oc.Arg(1) ..
    ocnn.data.accessor.Batch:d(oc.Arg(2)) .. 
    ocnn.data.accessor.Relabel({image=1, label=2}) .. 
    ocnn.data.accessor.Random()
  )
  
  Loop = oc.Arm:stem(
    --! @input DataTable Accessor
    --! @output 
    oc.ToIter() .. 
      oc.flow.Repeat(
        oc.Iterate() .. 
        --! @input DataTable
        oc.flow.Multi{n=2} .. 
        oc.flow.Gate:d(
          function (self, input_) 
            --! convert bool to number
            return (input_ ~= nil) and 1 or 0 
          end,
          ocnn.data.ToTable() ..
          oc.Sub(1) .. 
          oc.Arg(1)
        )
  ))
  
  data = ocnn.data.MNIST(0.1)
end

Through = oc.Arm:stem(
  oc.flow.Multi{
    oc.Arg(1),
    oc.Noop()
  }[2]
)


ref.predictTrain:stimulate(oc.input) .. 
  Append{ref.predictTrain:stimulateGrad()} .. 
  Through{ref.predictTrain:accumulate()} ..
  oc.Optim(self.predictTrain)
  

  t = MNISTIter{oc.nerve(data:test()), 16} .. 
    Loop{
      oc.Noop()
    }:gradOff()


x = t:out():get(oc.data.index.Index(1)).data[1]
