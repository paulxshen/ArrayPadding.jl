using Functors
using Lazy: @forward
using LazyArrays
using Zygote: Buffer, bufferfrom
include("types.jl")
include("alg.jl")
include("pad.jl")
export pad, pad!, Ramp, ReplicateRamp, PaddedArray, left, right