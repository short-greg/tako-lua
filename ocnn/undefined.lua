require 'oc.init'
require 'ocnn.pkg'


do
  local LinearDecl, parent = oc.class(
    'ocnn.LinearDecl', oc.Declaration
  )
  ocnn.LinearDecl = LinearDecl

  function LinearDecl:_define(input)
    if not self._arguments[1] then
      if input:dim() == 1 then
        self._arguments[1] = input:size(1)
      else
        self._arguments[1] = input:size(2)
      end
    end
    return parent._define(self, input)
  end

  function nn.Linear:d(size1, size2)
    return ocnn.LinearDecl(self, size1, size2)    
  end
end


do
  local SpatialConvolutionDecl, parent = oc.class(
    'ocnn.SpatialConvolutionDecl', oc.Declaration
  )
  ocnn.SpatialConvolutionDecl = SpatialConvolutionDecl

  function SpatialConvolutionDecl:_define(input)
    if not self._arguments[1] then
      if input:dim() == 3 then
        self._arguments[1] = input:size(1)
      elseif input:dim() == 4 then
        self._arguments[1] = input:size(2)
      else
        error(
          'Input should be of dimension 3 or 4'
        )
      end
    end
    return parent._define(self, input)
  end

  function nn.SpatialConvolution.d(cls, ...)
    return ocnn.SpatialConvolutionDecl(
      cls, ...
    )
  end
end

do
  local BatchNormalizationDecl, parent = oc.class(
    'ocnn.BatchNormalizationDecl', oc.Declaration
  )
  ocnn.BatchNormalizationDecl = BatchNormalizationDecl

  function BatchNormalizationDecl:_define(input)
    if not self._arguments[1] then
      if input:dim() == 1 then
        self._arguments[1] = input:size(1)
      elseif input:dim() == 2 then
        self._arguments[1] = input:size(2)
      else
        error(
          'Input should be of dimension 1 or 2'
        )
      end
    end
    return parent._define(self, input)
  end

  function nn.BatchNormalization.d(cls, ...)
    return ocnn.BatchNormalizationDecl(
      cls, ...
    )
  end
end
