require 'oc.dependent'

function octest.oc_dependent_init()
  local tako = {}
  local dependent = oc.DependentNerve(tako)
end

function octest.oc_dependent_ownerSet()
  local tako = {}
  local dependent = oc.DependentNerve(tako)
  octester:eq(
    dependent:ownerSet(), true,
    'Owner should be set'
  )
end

function octest.oc_dependent_getOwner()
  local tako = {}
  local dependent = oc.DependentNerve(tako)
  octester:eq(
    dependent:getOwner(), tako,
    'Owner should be tako'
  )
end

function octest.oc_argProcessor_init()
  local tako = {}
  local argproc = oc.ArgProcessor(1, oc.ref.input.x)
end

function octest.oc_argProcessor_updateArgs_input()
  local input = {x=2}
  local argproc = oc.ArgProcessor(1, oc.ref.input.x)
  local args = argproc:updateArgs(input)
  
  octester:eq(
    args[1], 1,
    'First argument should be 1'
  )
  octester:eq(
    args[2], 2,
    'Second argument should be 2'
  )
end

function octest.oc_argProcessor_updateArgs_my()
  local tako = {x=2}
  local argproc = oc.ArgProcessor(1, oc.ref.my.x)
  argproc:setOwner(tako)
  local args = argproc:updateArgs(nil)
  octester:eq(
    args[1], 1,
    'First argument should be 1'
  )
  octester:eq(
    args[2], 2,
    'Second argument should be 2'
  )
end


