require 'oc.pkg'
require 'oc.nerve'
require 'oc.class'
require 'oc.undefined.base'


do
  local Declaration, parent = oc.class(
    'oc.Declaration', oc.Undefined
  )
  --! Declares a nerve to be used in an arm
  --! @input Should not use updateOutput (must define)
  --! @gradOutput Should not use updateOutput (must define)
  --!
  oc.Declaration = Declaration

  function Declaration:__init(nerveType, ...)
    parent.__init(self)
    self._mod = nerveType
    self._arguments = table.pack(...)
  end
  
  function Declaration:grad()
    error(
      'Declaration cannot update grad input. '.. 
      'Must instantiate'
    )
  end
  
  function Declaration:accGradParameters()
    error(
      'Declaration cannot update grad input. '..  
      'Must instantiate')
  end
  
  function Declaration:_define(input)
    return oc.nerve(self._mod(
      table.unpack(self._arguments)
    ))
  end
  
  --! could create an argmap in declare if necessary
  --! add ArgFunc() <- which can be used to get retrieve the arg 
  --! if not defined
    
  function Declaration:updateArg(varName, val)
    --! Update the arg to use in declaration when
    --! defining
    --! @param varName - The variable to set
    --! @param val - The value to set hte argument to
    for i=1, #self._arguments do
      if oc.type(self._arguments[i]) == 'oc.Arg' and
         self._arguments[i]:name() == varName then
           
        self._arguments[i] = val
      end
    end
  end
  
  --! TODO: Do I really want to do this???
  --! 
  function Declaration:internals()
    local children = {}
    for i=1, #self._arguments do
      if oc.isTypeOf(self._arguments[i], 'oc.Nerve') or
         oc.isTypeOf(self._arguments[i], 'oc.Strand') then
        table.insert(children, self._arguments[i])
      end
    end
    return children
  end
  
  function Declaration:updateArgs(argVals)
    --! Set the values for the Arg Variables
    --! for the declaration
    --! {string=<value>}
    --! 
    for argName, val in pairs(argVals) do
      self:updateArg(argName, val)
    end
  end
  
  function oc.declaration(cls, ...)
    --! TODO: Make sure it's not an instance
    assert(
      not oc.isInstance(cls),
      'Cannot make a declaration from an instance.'
    )
    
    return oc.Declaration(cls, ...)
  end
  
  --! need to reverse this because there may
  --! be some classes which use a subclass of declaration
  oc.Nerve.d = oc.declaration
end
