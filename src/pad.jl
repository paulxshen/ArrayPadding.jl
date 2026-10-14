"""
    pad(array, border, pad_amount)
    pad(array, border, left_pad_amount, right_pad_amount)
    pad(array, border, pad_amounts_for_dims)
    pad(array, border, left_pad_amount_for_dims, right_pad_amount_for_dims)
    pad(array, left_border, right_border, left_pad_amount_for_dims, right_pad_amount_for_dims)

Pads arrays of any dimension with various border options including constants, periodic, replicate, symmetric, mirror and smooth. Can control amount of padding applied to the left and right side of each dimension. Fully differentiable (compatible with `Zygote.jl` `Flux.jl`)

## Border options
- `:periodic`: a b c | a b
- `:symmetric`: a b c | c b
- `:antisymmetric`: a b c | -c -b
- `:mirror`: a b c | b a
- `:replicate`: a b c | c c
- `:smooth`: a b c | 2c-b 3c-2b (linear extrapolation, maintains C1 continuity)
- function `f`: a b c | max(f(1), c) max(f(2), c)
- any other value `v`: a b c | v v
"""
function pad(a, vl, vr, l, r)
    all(iszero, l) && all(iszero, r) && return a
    b = Buffer(a, Tuple(size(a) .+ l .+ r))
    b[@ignore_derivatives(range.(l .+ 1, size(b) .- r))...] = a
    copy(pad!(b, vl, vr, l, r))
end
pad(a, v, l, r=l) = pad(a, v, v, l, r)

"""
    pad!(array, border, pad_amount...)

Like `pad` but overwrites the outer `pad_amount` cells of `array` in place, treating the rest as the core. Use `Zygote.Buffer` for AD.
"""
function pad!(a, vl, vr, l, r)
    for (i, vl, vr, l, r) in @ignore_derivatives tuple.(1:ndims(a), vl, vr, l, r)
        ax = axes(a, i)
        l > 0 && setslab!(a, i, first(ax, l), block(a, vl, i, l, true, l, r))
        r > 0 && setslab!(a, i, last(ax, r), block(a, vr, i, r, false, r, l))
    end
    a
end
pad!(a, v, l, r=l) = pad!(a, v, v, l, r)

# write `x` into `slab(a, i, J)`, broadcasting as needed
setslab!(a::AbstractArray, i, J, x) = view(a, slabidx(a, i, J)...) .= x
function setslab!(a::Buffer, i, J, x) # Buffer only takes exact fits
    sz = @ignore_derivatives Base.setindex(size(a), length(J), i)
    a[slabidx(a, i, J)...] = x isa AbstractArray ? repeat(x, (sz .÷ size(x))...) : fillfunc(typeof(a))(x, sz)
end

"""
    diffpad(a, vl, vr; dims)

`diff(a; dims)` with the missing entry supplied by a border `vl` on the left, or else `vr` on the right, so the size is preserved.
"""
function diffpad(a::AbstractArray, vl, vr; dims)
    left = !isnothing(vl)
    left || !isnothing(vr) || throw(ArgumentError("diffpad needs a left or right border"))
    edge = slab(a, dims, left ? (1:1) : (size(a, dims):size(a, dims)))
    left ? cat(edge .- block(a, vl, dims, 1, true), diff(a; dims); dims) :
           cat(diff(a; dims), block(a, vr, dims, 1, false) .- edge; dims)
end
diffpad(a, vl, vr, dims) = diffpad(a, vl, vr; dims)
