require 'ocnn.data.index'


function octest.oc_data_index_expand()
  local index = oc.data.index.Index(1)
  local expanded = index:expand(2)
  octester:eq(
    expanded._startingVal, 1,
    ''
  )
  octester:eq(
    expanded._frameSize, 2,
    ''
  )
end


function octest.oc_data_index_expand_from_2()
  local index = oc.data.index.Index(2)
  local expanded = index:expand(3)
  octester:eq(
    expanded._frameSize, 3,
    ''
  )
  octester:eq(
    expanded._startingVal, 4,
    ''
  )
end


function octest.oc_data_index_increment_from_3()
  local index = oc.data.index.Index(3)
  index:incr()
  octester:eq(
    index._index, 4,
    ''
  )
end


function octest.oc_data_index_rev_from_4()
  local index = oc.data.index.Index(1)
  local rev = index:rev(4)
  
  octester:eq(
    rev._index, 4,
    ''
  )
end


function octest.oc_data_index_incr_from_1()
  local index = oc.data.index.Index(1)
  index:incr()
  octester:eq(
    index[1], 2,
    ''
  )
end


function octest.oc_data_index_decr_from_1()
  local index = oc.data.index.Index(1)
  index:decr()
  octester:eq(
    index[1], 0,
    ''
  )
end
