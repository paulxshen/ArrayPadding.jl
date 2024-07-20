using Functors, Statistics, GPUArraysCore
using Lazy: @forward
# using Zygote: Buffer, bufferfrom
include("types.jl")
include("alg.jl")
include("pad.jl")
include("place.jl")