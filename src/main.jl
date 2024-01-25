using Functors
using Lazy: @forward
using LazyArrays
include("types.jl")
include("alg.jl")
include("pad.jl")
export pad, pad!, Ramp, ReplicateRamp, PaddedArray