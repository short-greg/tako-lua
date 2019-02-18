require 'oc.emission'

function octest.oc_emission_init_with_one_value()
  local value = 1
  local emission = oc.Emission(value)
  octester:eq(
    emission[1], value,
    string.format('Index should equal %s', value)
  )  
end

function octest.oc_emission_init_with_two_values()
  local value = 1
  local value2 = 2
  local emission = oc.Emission(value, value2)
  octester:eq(
    emission[1], value,
    string.format('Index should equal %s', value)
  )  
  octester:eq(
    emission[2], value2,
    string.format('Index should equal %s', value2)
  )  
end

function octest.oc_emission_len()
  local value1 = 1
  local value2 = 2
  local value3 = 2
  local emission = oc.Emission()
  octester:eq(
    #emission, 0,
    string.format('There should be no values in the emission')
  )
  emission:pushBack(value1)
  octester:eq(
    #emission, 1,
    string.format('The length of the emission should be 1')
  )
  emission:pushBack(value2)
  octester:eq(
    #emission, 2,
    string.format('The length of the emission should be 3')
  )
  emission:pushBack(value3)
  octester:eq(
    #emission, 3,
    string.format('The length of the emission should be 3')
  )
end

function octest.oc_emission_mergeRight_table()
  local emission1 = oc.Emission(1, 2, 3)
  local value = {1,2}
  
	emission1:mergeRight(value)
	octester:eq(
	  emission1[#emission1 - 1], value[1],
	  string.format('The value at position %d should equal %d', #emission1 - 1, value[1])
	)
	octester:eq(
	  emission1[#emission1], value[2],
	  string.format('The value at position %d should equal %d', #emission1, value[2])
	)
end

function octest.oc_emission_mergeRight_scalar()
  local emission1 = oc.Emission(1, 2, 3)
  local value = 1
  
	emission1:mergeRight(value)
	octester:eq(
	  #emission1, 4,
	  'There should be 5 elements after the merge'
	)
	octester:eq(
	  emission1[#emission1], value,
	  string.format('The value at position %d should equal %d', #emission1, value)
	)
end

--[[
function octest.oc_emission_merge()
  local emission1 = oc.Emission(1, 2, 3)
  local emission2 = oc.Emission(3, 4)
  
	emission = emission1:merge(emission2)
	octester:eq(
	  #emission, 5,
	  'There should be 5 elements after the merge'
	)
	
	octester:eq(
	  emission[4], 3,
	  'The fourth element of emission should be 3'
	)
	
	octester:eq(
	  emission[5], 4,
	  'The fifth element of the emission should be 4'
	)
end
--]]

function octest.oc_emission_add()
  local emission1 = oc.Emission(1, 2, 3, nil)
  local emission2 = oc.Emission(4, 1, nil, 4)
  local emission3 = emission1 + emission2
  
  octester:eq(
    emission3, oc.Emission(5, 3, 3, 4),
    'The emissions should be added together with nil emissions not being added.'
  )
end

function octest.oc_emission_sub()
  local emission1 = oc.Emission(1, 2, 3, nil)
  local emission2 = oc.Emission(4, 1, nil, 4)
  local emission3 = emission1 - emission2
  octester:eq(
    emission3, oc.Emission(-3, 1, 3, 4),
    'Emission2 should be subtracted from emission2 '..
    'with nil emissions not being subtracted.'
  )
end

function octest.oc_emission_mul()
  local emission1 = oc.Emission(1, 2, 3, nil)
  local emission2 = oc.Emission(4, 1, nil, 4)
  
  local emission3 = emission1 * emission2
  octester:eq(
    emission3, oc.Emission(4, 2, 3, 4),
    'Emission1 and 2 should be multiplied '..
    'with nil emissions not being multiplied.'
  )
end

function octest.oc_emission_div()
  local emission1 = oc.Emission(1, 2, 3, nil)
  local emission2 = oc.Emission(4, 1, nil, 4)
  local emission3 = emission1 / emission2
  
  octester:eq(
    emission3, oc.Emission(1 / 4, 2, 3, nil),
    'Emission1 and 2 should be multiplied '..
    'with nil emissions not being divided.'
  )
end

function octest.oc_emission_eq_with_equal()
  local emission1 = oc.Emission(1, 2, 3, 4)
  local emission2 = oc.Emission(1, 2, 3, 4)
  local emission3 = emission1 == emission2
  
  octester:eq(
    emission3, true,
    'Emission1 and 2 should be multiplied '..
    'with nil emissions not being divided.'
  )
end

function octest.oc_emission_eq_with_equal_nil()
  local emission1 = oc.Emission()
  local emission2 = oc.Emission()
  local emission3 = emission1 == emission2
  
  octester:eq(
    emission3, true,
    'Emission1 and 2 should be multiplied '..
    'with nil emissions not being divided.'
  )
end

function octest.oc_emission_eq_with_unequal_length()
  local emission1 = oc.Emission(1, 2)
  local emission2 = oc.Emission(1)
  local emission3 = emission1 ~= emission2
  
  octester:eq(
    emission3, true,
    'Emission1 and 2 should not be equal as their sizes '..
    'are different'
  )
end

function octest.oc_emission_eq_with_unequal_values()
  local emission1 = oc.Emission(1, 2, 3)
  local emission2 = oc.Emission(1, 3, 2)
  local emission3 = emission1 ~= emission2
  
  octester:eq(
    emission3, true,
    'Emission1 and 2 should not be equal as their values '..
    'are different'
  )
end

function octest.oc_emission_newindex()
  local emission1 = oc.Emission(1, 2, 3)
  local value = 2
  local pos = 4
  emission1[pos] = value
  
  octester:eq(
    #emission1, pos,
    'Size of emission is not correct'
  )
  
  octester:eq(
    emission1[4], value,
    'Value of emission is not correct'
  )
end
