# ArrayPadding.jl

Pad arrays of any dimension with constant or edge-derived borders, with separate amounts for the left and right of each dimension. Works with Zygote and Flux for automatic differentiation.

```julia
using ArrayPadding
a = reshape(1:16, 4, 4)

pad(a, 0, 1)                    # 1 cell of zeros on every side
pad(a, :periodic, (1, 2), 0)    # left only: 1 cell in dim 1, 2 cells in dim 2
pad(a, :replicate, -1, 1, 1)    # left border :replicate, right border -1
pad!(copy(a), :mirror, 1)       # in place: overwrite the outer cells
diffpad(a, 0, nothing; dims=1)  # diff along dims=1 that keeps the size
```

## API
- `pad(a, border, l, r=l)` and `pad(a, left_border, right_border, l, r)` return a new, larger array. `l` and `r` are a number or one number per dimension.
- `pad!(a, border, l, r=l)` keeps the size of `a` and overwrites its outer `l`/`r` cells. The border is computed from the cells inside them. For AD, pass a `Zygote.Buffer`.
- `diffpad(a, vl, vr; dims)` computes `diff(a; dims)` and supplies the missing entry from the left border `vl`, or from the right border `vr` when `vl` is `nothing`.

## Borders
With core `a b c`, the right border is:

| border | right border |
|---|---|
| `:periodic` | `a b` |
| `:symmetric` | `c b` |
| `:antisymmetric` | `-c -b` |
| `:mirror` | `b a` |
| `:replicate` | `c c` |
| `:smooth` | `2c-b 3c-2b` (linear extrapolation) |
| function `f` | `max(f(1), c) max(f(2), c)` |
| value `v` | `v v` |

More examples are in `test/runtests.jl`.

## Contributors
Paul Shen <pxshen@alumni.stanford.edu>, Luminescent AI
