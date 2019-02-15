require 'oc.flow.pkg'
require 'oc.class'
require 'oc.nerve'


do
  local Router, parent = oc.class(
    'oc.Router', 
    oc.Nerve
  )
  --! ########################################
  --! @abstract
  --!
  --! Control module that sends data
  --! through a single process amongst several 
  --! processes.  There are two types of routers: 
  --! Switch and Case.  
  --! 
  --! Case works like an IfElse block and
  --! where the first Case to succeed gets output
  --! Switch has a nerve which outputs the 
  --! path to be taken.
  --! TODO: Some unit tests are broken.. 
  --! Need to look into this problem
  --! ########################################
  oc.Router = Router

  Router.DEFAULT = 0
  local DEFAULT = Router.DEFAULT

  function Router:__init(nerves)
    --! @constructor
    --! @param - nerves - {nervable}
    parent.__init(self)
    assert(
      oc.type(self) ~= 'oc.Router',
      'Type oc.Router is Abstract so '.. 
      'cannot be instantiated.'
    )
    self._modules = {}
  
    for i=1, #nerves do
      table.insert(
        self._modules, 
        oc.nerve(nerves[i])
      )
    end
    
    local default = nerves[DEFAULT] or nerves.default
    if default then
      self._modules[DEFAULT] = oc.nerve(
        default
      )
    end
  end
  
  function Router:out(input)
    error(
      'updateOutput is not defined for the '.. 
      'base Router class.'
    )
  end

  function Router:grad(input, gradOutput)
    --! Backgpropagates the grad output through the path
    --! that was chosen in updateOutput
    local gradInput
    local path = self.output[1]
    if path then
      gradInput = self._modules[path]:stimulateGrad(
        gradOutput[2]
      )
    end
    return gradInput
  end

  function Router:accGradParameters(input, gradOutput)
    local path = self.output[1]
    
    if path then
      self._modules[path]:accumulate()
    end
  end
end


do
  local Switch, parent = oc.class(
    'oc.Switch',
    oc.Router
  )
  --! ####################################
  --! Control module that sends data
  --! through a function which routes the input
  --! to one of n nerves where n is the number
  --! of processes.
  --!
  --! @example oc.Switch(
  --!   router,
  --!   {p1, p2, p3}
  --! )
  --! This Switch will send the input through
  --! router which outputs a number representing
  --! the path to take.  If p2 is chosen the output
  --! will be {path, p2.output}
  --!
  --! @input depends on the nerves
  --! @output {path, nerve[path].output[2]}
  --! 
  --! ####################################
  oc.Switch = Switch

  function Switch:__init(router, nerves)
    --! @constructor
    --! @param - nerves - oc.Nerve
    parent.__init(self, nerves)
    router = router or oc.Noop()
    self._modules.router = oc.nerve(router)
  end

  function Switch:out(input)
    --! Sends the input through each possible branch
    --! Then sends that output through the condition nerve
    --! and routes the path output by that 
    --! nerve to the output of the module
    local output = {}
    local path = self._modules.router:stimulate(input[1])
    
    if path and self._modules[path] then
      return self._modules[path]:stimulate(input[2])      
    elseif self._modules[DEFAULT] then
      return self._modules[DEFAULT]:stimulate(input[2])
    else
      return {}
    end
    return output
  end
  
  function Switch:grad(input, gradOutput)
    local gradInput = {
      self._modules.router:stimulateGrad(
        input[1]
      ),
      parent.grad(
        self, input, gradOutput
      )
    }
    return gradInput
  end
  
  function Switch:accGradParameters(input, gradOutput)
    self._modules.router:accumulate(
      input[1]
    )
    parent.accGradParameters(
      self, input, gradOutput
    )
  end
end


do
  local Case, parent = oc.class(
    'oc.Case', 
    oc.Router
  )
  --! ####################################
  --! Control module that sends the input
  --! through processes one by one 
  --! if the process outputs success then
  --! that output will become the output of
  --! the Case
  --!
  --! @example oc.Case{
  --!   oc.Gate{p1, p2},
  --!   oc.Gate{p3, p4},
  --!   default=p5
  --! }
  --! This Case will send through Gate1 and
  --! if its first output is true then it will 
  --! the {path, p2.output}
  --!
  --! @input depends on the nerves
  --! @output {path, nerve[path].output[2]}
  --!     
  --! TODO: Some unit tests are broken.. 
  --! Need to look into this problem
  --! ####################################
  oc.Case = Case

  function Case:out(input)
    --! Sends the input through each possible branch
    --! Then sends that output through the condition nerve
    --! and routes the path output by that 
    --! nerve to the output of the module
    local output
    local path
    for i=1, #self._modules do
      local curOut = self._modules[i]:stimulate(input)
      if curOut[1] ~= true then
        output = {
          i, curOut
        }
        break
      end
    end
    if output == nil and self._modules[DEFAULT] then
      local curOut = self._modules[DEFAULT]:stimulate(
        input
      )
      if curOut[1] == true then
        output = {DEFAULT, curOut}
      end
    end

    if output == nil then
      output = {}
    end
    return output
  end
  
  function Case:grad(input, gradOutput)
    --! Backgpropagates the grad output through the path
    --! that was chosen in updateOutput
    local gradInput = parent.updateGradInput(
      self, input, gradOutput
    )
    return gradInput
  end
end
