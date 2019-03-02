require 'oc.placeholder'


function octest.oc_placeholder_input()
  local nerve = oc.nerve(oc.input.x)
  octester:eq(
    oc.type(nerve), 'oc.InputRef',
    'The placeholder should become type InputRef'
  )
end


function octest.oc_placeholder_input_concat()
  local strand = oc.input.x .. oc.my.x
  octester:eq(
    oc.type(strand:lhs()), 'oc.InputRef',
    'The lhs placeholder should become type InputRef'
  )

  octester:eq(
    oc.type(strand:rhs()), 'oc.MyRef',
    'The rhs placeholder should become type MyRef'
  )
end


function octest.oc_placeholder_input_with_call()
  local nerve = oc.nerve(oc.input.x('hi').y.z('bye'))

  octester:eq(
    oc.type(nerve), 'oc.InputRef',
    'The placeholder should become type InputRef'
  )
end


function octest.oc_placeholder_convert_input_ref()
  local nerve = oc.nerve(oc.input)

  octester:eq(
    oc.type(nerve), 'oc.InputRef',
    'The placeholder should become type InputRef'
  )
end


function octest.oc_placeholder_input_with_no_indexing()
  local nerve = oc.nerve(oc.input)

  octester:eq(
    oc.type(nerve), 'oc.InputRef',
    'The placeholder should become type InputRef'
  )
end

function octest.oc_placeholder_val()
  local nerve = oc.nerve(oc.ref{1})

  octester:eq(
    oc.type(nerve), 'oc.ValRef',
    'The placeholder should become type ValRef'
  )
end


function octest.oc_placeholder_my()
  local nerve = oc.nerve(oc.my.x)

  octester:eq(
    oc.type(nerve), 'oc.MyRef',
    'The placeholder should become type MyRef'
  )
end

function octest.oc_placeholder_convert_my_with_no_indexing()
  local nerve = oc.nerve(oc.my)

  octester:eq(
    oc.type(nerve), 'oc.MyRef',
    'The placeholder should become type MyRef'
  )
end

function octest.oc_placeholder_super()
  local nerve = oc.nerve(oc.super.x)

  octester:eq(
    oc.type(nerve), 'oc.SuperRef',
    'The placeholder should become type SuperRef'
  )
end
