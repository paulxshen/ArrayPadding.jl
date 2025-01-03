module CUDAExt
using CUDA, ArrayPadding
ArrayPadding.fillfunc(::Type{CuArray}) = CUDA.fill
end
