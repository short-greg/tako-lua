require 'oc.functor'
require 'oc.noop'


function octest.oc_functor_with_out()
  local functor = oc.Functor{
    out=function (self, input)
      return input + 1
    end
  }

  octester:asserteq(
    functor:stimulate(0), 1, 
    'Output of functor should be 1'
  )
end


function octest.oc_functor_with_grad()
  local functor = oc.Functor{
    out=function (self, input)
      return input
    end,
    grad=function (self, input, gradOutput)
      return gradOutput + 1
    end
  }
  functor:stimulate(0)
  
  octester:asserteq(
    functor:stimulateGrad(0), 1, 
    'GradOutput of functor should be 1'
  )
end


function octest.oc_functor_with_back()
  local functor = oc.Functor{
    out=function (self, input)
      return input
    end,
    back=function (self, input, gradOutput)
      return gradOutput + 1
    end
  }
  functor:stimulate(0)
  
  octester:asserteq(
    functor:stimulateGrad(0), 1, 
    'GradOutput of functor should be 1'
  )
end
