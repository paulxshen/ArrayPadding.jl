module CUDAExt
using CUDA, ArrayPadding
ArrayPadding.fillfunc(::Type{<:CuArray}) = CUDA.fill
ArrayPadding.constructor(::Type{<:CuArray},) = cu


end
