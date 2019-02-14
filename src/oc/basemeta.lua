local basemeta = {}

--[[
basemeta.createCallFunction = function (child)
  rawset(child, '__call', function (
      self, ...
    )
      return child['__call__'](self, ...)
    end
  )
end
--]]


basemeta.createNewIndexFunction = function (
  child
)
  rawset(child, '__newindex', function (
      self, index, val
    )
      --[[
      if self[index] then
        -- TODO: Look into how to deal with this 
        -- in the lua programming guide
        return
      end
      --]]
      local f = child['__newindex__']
      if f ~= nil then
        f(self, index, val)
      else
        rawset(self, index, val)
      end
    end
  )
end


basemeta.createToStringFunction = function (child)
  local childNerve = child
  rawset(child, '__tostring', function (
      self
    )
      local f = childNerve['__tostring__']
      if f ~= nil then
        return f(self)
      end
      return childNerve.__typename
    end
  )
end


basemeta.createAddFunction = function (child)
  rawset(child, '__add', function (
      self, other
    )
      return child['__add__'](self, other)
    end
  )
end


basemeta.createSubFunction = function (child)
  rawset(child, '__sub', function (
      self, other
    )
      return child['__sub__'](self, other)
    end
  )
end


basemeta.createMulFunction = function (child)
  rawset(child, '__mul', function (
      self, other
    )
      return child['__mul__'](self, other)
    end
  )
end


basemeta.createDivFunction = function (child)
  rawset(child, '__div', function (
      self, other
    )
      return child['__div__'](self, other)
    end
  )
end


basemeta.createIDivFunction = function (child)
  rawset(child, '__idiv', function (
      self, other
    )
      return child['__idiv__'](self, other)
    end
  )
end


basemeta.createPowFunction = function (child)
  rawset(child, '__pow', function (
      self, other
    )
      return child['__pow__'](self, other)
    end
  )
end


basemeta.createUNMFunction = function (child)
  rawset(child, '__unm', function (
      self, other
    )
      return child['__unm__'](self)
    end
  )
end


basemeta.createConcatFunction = function (child)
  rawset(child, '__concat', function (
      self, other
    )
      return child['__concat__'](self, other)
    end
  )
end


basemeta.createEQFunction = function (child)
  rawset(child, '__eq', function (
      self, other
    )
      if oc.isInstance(child) then
        return child['__eq__'](self, other)
      else
        return rawequal(self, other)
      end
    end
  )
end


basemeta.createLTFunction = function (child)
  rawset(child, '__lt', function (
      self, other
    )
      return child['__lt__'](self, other)
    end
  )
end


basemeta.createLEFunction = function (child)
  rawset(child, '__le', function (
      self, other
    )
      return child['__le__'](self, other)
    end
  )
end

basemeta.createLengthFunction = function (child)
  rawset(child, '__len', function (
      self
    )
      return child['__len__'](self)
    end
  )
end


createBaseMeta = function (vals)
  for k, func in pairs(basemeta) do
    func(vals)
  end
end

return createBaseMeta
