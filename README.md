# ArrayPadding.jl
 
Pads arrays of any dimension with various border options including constants, periodic, symmetric, mirror and smooth. Can control amount of padding applied to the left and right side of each dimension. Fully differentiable (compatible with `Zygote.jl` `Flux.jl`)

Default behavior is to eagerly allocate new array. You can avoid allocation by using `lazy=true` resulting in a virtually indexed `LazyArrays.jl` type, but this isn't fully tested and not recommended for most users.

```julia
pad(array, border, pad_amount)
pad(array, border, left_pad_amount, right_pad_amount)
pad(array, border, pad_amounts_for_dims)
pad(array, border, left_pad_amount_for_dims, right_pad_amount_for_dims)
```

## Border options
- `:periodic`: a b c | a
- `:symmetric`: a b c | c
- `:mirror`: a b c | b
- `:smooth`: a b c | 2c-b (Maintains C1 continuity)
- any other value `v`: a b c | v

## Usage
```julia
using ArrayPadding

a = [1 2; 3 4]

@test pad(a, -1, 1) == [
    -1 -1 -1 -1
    -1 1 2 -1
    -1 3 4 -1
    -1 -1 -1 -1
]

@test pad(a, -1, 1, 0) == [
    -1 -1 -1
    -1 1 2
    -1 3 4
]

@test pad(a, -1, (0, 1), (1, 0)) == [
    -1 1 2
    -1 3 4
    -1 -1 -1
]

@test pad(a, :periodic, (1, 0)) == [
    3 4
    1 2
    3 4
    1 2
]

@test pad(a, :symmetric, 1) == [
    1 1 2 2
    1 1 2 2
    3 3 4 4
    3 3 4 4
]

@test pad(a, :mirror, 1) == [
    4 3 4 3
    2 1 2 1
    4 3 4 3
    2 1 2 1
]

@test pad(a, :replicate, 1) == [
    1 1 2 2
    1 1 2 2
    3 3 4 4
    3 3 4 4
]

@test pad(a, :smooth, 1) == [
    -2 -1 0 1
    0 1 2 3
    2 3 4 5
    4 5 6 7
]
```
