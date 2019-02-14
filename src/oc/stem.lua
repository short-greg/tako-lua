require 'oc.pkg'
require 'oc.class'
require 'oc.nerve'
require 'oc.arm'

do
  oc.Stem = oc.class(
    'oc.Stem'
  )
  --! ######################################
  --! Stems are used for creating 
  --! commonly used compound nerves
  --! (or arms) with ease.
  --! 
  --! ArgStem is a type of stem added for 
  --! convenience to  stems easily
  --! 
  --! sigmoidLayer = oc.stem(
  --!    nn.Linear:d(oc.my.X, oc.my.Y) .. nn.Sigmoid:d() 
  --! )
  --!
  --! Then to create a sigmoid layer the 
  --! following layer can be used.
  --! 
  --! sigmoidLayer{X=1, Y=2} 
  --! 
  --! creates a sigmoid layer with the Linear size being 1 
  --! for the input and 2 for the output
  --!
  --! ##########################################

  function oc.Stem:__init(cls, args)
    assert(
      oc.isInstance(cls) == false,
      'Cannot create a stem of an instance.'
    )
    self._initArgs = args
    self._cls = cls
  end
  
  function oc.Stem:__call(args)
    local initArgs = {}

    for i=1, #self._initArgs do
      local arg = self._initArgs[i]
      if type(arg) == 'table' then
        arg = oc.ops.table.deepCopy(arg)
      end
      
      if oc.isTypeOf(arg, 'oc.Arg') then
        table.insert(
          initArgs, args[arg:name()]
        )
      elseif oc.isTypeOf(self._initArgs[i], 'oc.Nerve') or
             oc.isTypeOf(self._initArgs[i], 'oc.Chain') then
        local copy = oc.ops.table.deepCopy(arg)
        oc.bot.call:updateArgs{
          args={args},
          cond=function (self, nerve)
            return oc.type(nerve) == 'oc.Declaration' or
                   oc.type(nerve) == 'oc.ArgNerve'
          end
        }:exec(copy)

        table.insert(
          initArgs, copy
        )
      else
        table.insert(
          initArgs, arg
        )
      end
    end
    return self._cls(table.unpack(initArgs))
  end

  function oc.Nerve:stem(...)
    return oc.Stem(self, table.pack(...))
  end
  
  function oc.Stem.d(cls, args)
    assert(
      not oc.isInstance(cls),
      'Cannot create a Declaration of an instance.'
    )
    return oc.Declaration(cls, args)
  end
end


function oc.Nerve:subclass(name, members)
  assert(
    oc.isInstance(self) == false,
    'Cannot subcass an instance.'
  )
  local cls, parent = oc.class(name, self)
  
  if members ~= nil then
    for k, v in pairs(members) do
      cls[k] = v
    end
  end
  
  return cls, parent
end
