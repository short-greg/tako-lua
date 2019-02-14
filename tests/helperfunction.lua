require 'oc.init'

do
  local cfunc = function (func)
    local tablefunc = {} 
    for k, v in pairs(func) do
      tablefunc[k] = v
    end
    setmetatable(
      tablefunc,
      {
        __call=function(self, ...)
          return tablefunc.__call(self, ...)
        end
      }
    )
    return tablefunc
  end
  
  local y = {}
  y.z = 2
  y.add = cfunc{
    __call=function(self, outer, t)
      local v = self:prepare(outer)
      return self:add(v, t)
    end,
    prepare=function(self, outer, t)
      return outer.z
    end,
    add=function(self, v, t)
      return v + t
    end
  }
  print(y:add(1))
end
