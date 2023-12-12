using LazyArrays
include("utils.jl")

"""
    pad(array, border, pad_amount)
    pad(array, border, left_pad_amount, right_pad_amount)
    pad(array, border, pad_amounts_for_dims)
    pad(array, border, left_pad_amount_for_dims, right_pad_amount_for_dims)

Pads arrays of any dimension with various border options including constants, periodic, replicate, symmetric, mirror and smooth. Can control amount of padding applied to the left and right side of each dimension. Fully differentiable (compatible with `Zygote.jl` `Flux.jl`)

## Border options
- `:periodic`: a b c | a b
- `:symmetric`: a b c | c b
- `:mirror`: a b c | b a
- `replicate`: a b c | c c
- `:smooth`: a b c | 2c-b (Maintains C1 continuity)
- any other value `v`: a b c | v
"""
function pad(a::AbstractArray, b, l::Union{AbstractVector,Tuple}, r=l; lazy=false)
    # - `:C1`: a b c | 2c-b (Maintains C1 continuity)
    d = ndims(a)
    for (i, l, r) in zip(1:d, l, r)
        if l > 0
            if b == :periodic
                I = [j == i ? ((size(a, i)-l+1):size(a, i)) : (:) for j = 1:d]
                al = view(a, I...)
            elseif b == :symmetric
                I = [j == i ? (l:-1:1) : (:) for j = 1:d]
                al = view(a, I...)
            elseif b == :mirror
                I = [j == i ? (l+1:-1:2) : (:) for j = 1:d]
                al = view(a, I...)
            elseif b == :replicate
                I = [j == i ? axes(a, i)[begin:begin] : (:) for j = 1:d]
                s = [j == i ? l : 1 for j = 1:d]
                al = repeat(view(a, I...), s...)
            elseif b == :smooth
                I = [j == i ? (1:1) : (:) for j = 1:d]
                if size(a, i) == 1
                    al = view(a, I...)
                else
                    I2 = [j == i ? (2:2) : (:) for j = 1:d]
                    al = 2view(a, I...) - a[I2...]
                end
            elseif isa(b, ReplicateRamp)
                I = [j == i ? (1:1) : (:) for j = 1:d]
                v = a[I...]
                Δ = (b.v .- v) / l
                al = v .+ cat([c * Δ for c = l-1:-1:0]..., dims=i)
            else
                al = fill(b, [j == i ? l : size(a, j) for j = 1:d]...)
            end
        end
        if r > 0
            if b == :periodic
                I = [j == i ? (1:r) : (:) for j = 1:d]
                ar = view(a, I...)
            elseif b == :replicate
                I = [j == i ? axes(a, i)[end:end] : (:) for j = 1:d]
                s = [j == i ? r : 1 for j = 1:d]
                ar = repeat(view(a, I...), s...)
            elseif b == :symmetric
                I = [j == i ? axes(a, i)[end:-1:end-r+1] : (:) for j = 1:d]
                ar = view(a, I...)
            elseif b == :mirror
                I = [j == i ? axes(a, i)[end-1:-1:end-r] : (:) for j = 1:d]
                ar = view(a, I...)
            elseif b == :smooth
                I = [j == i ? axes(a, i)[end:end] : (:) for j = 1:d]
                if size(a, i) == 1
                    ar = view(a, I...)
                else
                    I2 = [j == i ? axes(a, i)[end-1:end-1] : (:) for j = 1:d]
                    ar = 2view(a, I...) - a[I2...]
                end
            elseif isa(b, ReplicateRamp)
                I = [j == i ? axes(a, i)[end:end] : (:) for j = 1:d]
                v = a[I...]
                Δ = (b.v .- v) / r
                ar = v .+ cat([c * Δ for c = (0:r-1)]..., dims=i)
            else
                ar = fill(b, [j == i ? r : size(a, j) for j = 1:d]...)
            end
        end

        if l > 0
            a = cat(al, a; dims=i, lazy)
        end
        if r > 0
            a = cat(a, ar; dims=i, lazy)
        end
    end
    a
end

function pad(a::AbstractArray, b, l::Int=1, r=l; kw...)
    d = ndims(a)
    pad(a, b, fill(l, d,), fill(r, d); kw...)
end

function pad(a::PaddedArray, b, l=1, r=l; kw...)
    y = pad(a.a, b, l, r; kw...)
    PaddedArray(y, Int.(l .+ left(a)), Int.(r .+ right(a)))
end