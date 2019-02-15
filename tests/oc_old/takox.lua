require 'oc.classx'

function octest.oc_tako_define()
  local T = oc.tako('oc.T')
  local target = 1
  function T:y()
    return target
  end
  local instance = T()
  octester:eq(
    instance:y(), target,
    'The result of target should be value.'
  )
end

function octest.oc_tako_init()
  local T = oc.tako('oc.T')
  local target = 2
  function T:__init(val)
    self.val = val
  end
  local instance = T(target)
  octester:eq(
    instance.val, target,
    'The result of target should be value.'
  )
end

function octest.oc_tako_tostring()
  local T = oc.tako('oc.T')
  local target = 'HI'
  function T:__tostring__()
    return target
  end
  local instance = T()
  octester:eq(
    tostring(instance), target,
    'The result of target should be value.'
  )
end

function octest.oc_tako_newindex()
  local T = oc.tako('oc.T')
  local target = 2
  function T:__init()
  end
  
  function T:__newindex__(index, val)
    print('New index was called ', index, val)
    rawset(self, index, target)
  end
  
  local instance = T()
  instance.val = target + 1
  
  octester:eq(
    instance.val, target,
    'The result of target should be value.'
  )
end

function octest.oc_tako_arm()
  local T = oc.tako('oc.T')
  local target = 2
  function T:__init()
  end
  
  T.arm.y = nn.Linear(2, 2)
  local z = T()
  print(z.__basearms)
  print(z.__arms)
  print(z.__arms.y)
  
  local instance = T()
  instance.val = target + 1
  
  octester:eq(
    instance.val, target,
    'The result of target should be value.'
  )
end

