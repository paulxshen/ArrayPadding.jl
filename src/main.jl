"""
    pad(array, border, pad_amount)
    pad(array, border, left_pad_amount, right_pad_amount)
    pad(array, border, pad_amounts_for_dims)
    pad(array, border, left_pad_amount_for_dims, right_pad_amount_for_dims)

Pads arrays of any dimension with various border options including constants, periodic, symmetric, mirror and smooth. Can control amount of padding applied to the left and right side of each dimension. Fully differentiable (compatible with `Zygote.jl` `Flux.jl`)

## Border options
- `:periodic`: a b c | a
- `:symmetric`: a b c | c
- `:mirror`: a b c | b
- `:smooth`: a b c | 2c-b (Maintains C1 continuity)
- any other value `v`: a b c | v
"""
function pad(a::AbstractArray, b, l::Union{AbstractVector,Tuple}, r=l)
    # - `:C1`: a b c | 2c-b (Maintains C1 continuity)
    d = ndims(a)
    for (i, l, r) in zip(1:d, l, r)
        if l > 0
            if b == :periodic
                I = [j == i ? ((size(a, i)-l+1):size(a, i)) : (:) for j = 1:d]
                al = a[I...]
            elseif b == :symmetric
                I = [j == i ? (l:-1:1) : (:) for j = 1:d]
                al = a[I...]
            elseif b == :mirror
                I = [j == i ? (l+1:-1:2) : (:) for j = 1:d]
                al = a[I...]
            elseif b == :smooth
                I = [j == i ? (1:1) : (:) for j = 1:d]
                if size(a, i) == 1
                    al = a[I...]
                else
                    I2 = [j == i ? (2:2) : (:) for j = 1:d]
                    al = 2a[I...] - a[I2...]
                end
            else
                al = fill(b, [j == i ? l : size(a, j) for j = 1:d]...)
            end
        end
        if r > 0
            if b == :periodic
                I = [j == i ? (1:r) : (:) for j = 1:d]
                ar = a[I...]
            elseif b == :symmetric
                I = [j == i ? axes(a, i)[end:-1:end-r+1] : (:) for j = 1:d]
                ar = a[I...]
            elseif b == :mirror
                I = [j == i ? axes(a, i)[end-1:-1:end-r] : (:) for j = 1:d]
                ar = a[I...]
            elseif b == :smooth
                I = [j == i ? axes(a, i)[end:end] : (:) for j = 1:d]
                if size(a, i) == 1
                    ar = a[I...]
                else
                    I2 = [j == i ? axes(a, i)[end-1:end-1] : (:) for j = 1:d]
                    ar = 2a[I...] - a[I2...]
                end
            else
                ar = fill(b, [j == i ? r : size(a, j) for j = 1:d]...)
            end
        end

        if l > 0
            a = cat(al, a; dims=i)
        end
        if r > 0
            a = cat(a, ar; dims=i)
        end
    end
    a
end

function pad(a::AbstractArray, b, l::Int=1, r=l)
    d = ndims(a)
    pad(a, b, fill(l, d,), fill(r, d))
end

