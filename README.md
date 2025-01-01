# ArrayPadding.jl
 
Pads arrays of any dimension with various border options including constants, periodic, symmetric, mirror and smooth. Can control amount of padding applied to the left and right side of each dimension. Fully differentiable and GPU compatible (plays well with `Zygote.jl` `Flux.jl` `CUDA.jl` )

`pad` eagerly allocates new bigger array while `pad!` mutates original array in place.  `pad!` assumes argument to be the preallocated padded array so the effective border is set back by the padding amount when evaluating various border options. `pad` is AD (automatic differentiation) compatible while `pad!` requires `Zygote.Buffer` for AD (see usage )

See `test/runtests.jl` for examples of usage.

Consider starring or sponsoring us if you found this repo helpful. Feel free to request features or contribute PRs :)

## Contributors
Paul Shen  
<pxshen@alumni.stanford.edu>  
Luminescent AI
