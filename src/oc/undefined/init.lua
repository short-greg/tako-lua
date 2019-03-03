-- t:rev() <- 
-- 1. T=declare
-- 2. T=member
-- 3. T=module
-- If 1, t should be able to reverse at that time??? <- depends on
-- the class
-- for some classes return Rev class.. for others (like Linear) return
-- 
-- If 2, defined by the user who passes something in... create
-- MemberReverse
-- nn.Linear:member('') <- creates reverse member 
-- nn.Linear:rev() <- does not point to a specific module to
-- reverse
-- 
-- If there is no reverse for that type of module
-- will just create a
--
-- 
-- don't want to have to pass a value through the network
-- ocnn.CheckTensor() .. nn.Linear:d(nil, 2)
-- :outputSize(inputSize) <- 
-- nn.Linear:outputSize(inputSize) <- need this output size 
-- method
-- outputSample() <- if check tensor
-- - conv - 28, 28 <- not specified in nn.Convolution
-- Another option... wait until use to update.. With this 
-- approach
-- t:rev(false) <- will not fix the nerve on update (
--    reverse the module each time based on the input)
--    the default is to fix it
-- with this approach we do not need to use a bot to update
-- it or anything
-- instead of replacing could just have ._module point to the
-- new module oc.Reverse() ._moduleToReverse, ._module
-- I like this approach instead of replacing
-- 

-- 1. Declaration
-- 3. Reverse
-- 4. ReverseType (set (the module to reverse)

require 'oc.undefined.base'
require 'oc.undefined.declaration'
require 'oc.undefined.reverse'
require 'oc.undefined.arg'
