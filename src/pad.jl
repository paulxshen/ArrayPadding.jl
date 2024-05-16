

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
function pad(a, b, l::Union{AbstractVector,Tuple}, r::Base.AbstractVecOrTuple=l; lazy=false)
    # - `:C1`: a b c | 2c-b (Maintains C1 continuity)
    d = ndims(a)
    for (i, l, r) in zip(1:d, l, r)
        al, ar = lr(a, b, i, l, r)

        if l > 0
            a = cat(al, a; dims=i, lazy)
        end
        if r > 0
            a = cat(a, ar; dims=i, lazy)
        end
    end
    a
end
# function pad!(a::PaddedArray, b, l::Union{AbstractVector,Tuple}, r=l)
#     y = pad!(a.a, b, l, r)
#     PaddedArray(y, Int.(l .+ left(a)), Int.(r .+ right(a)))
# end

function pad!(a, b, l, r=l, ol=0, or=ol)
    d = ndims(a)
    l, r, ol, or = vec.((l, r, ol, or), d)
    for (i, l, r, ol, or) in zip(1:d, l, r, ol, or)
        al, ar = lr(a, b, i, l, r, false, ol, or)

        if l > 0
            a[[j == i ? (1+ol:l+ol) : (:) for j = 1:d]...] = al
        end
        if r > 0
            a[[j == i ? (size(a, i)-r-or+1:size(a, i)-or) : (:) for j = 1:d]...] = ar
        end
    end
    a
end

function pad(a::AbstractArray, b, l::Int=1, r::Base.AbstractVecOrTuple; kw...)
    d = ndims(a)
    pad(a, b, fill(l, d,), r; kw...)
end
function pad(a::AbstractArray, b, l::Base.AbstractVecOrTuple=1, r::Int; kw...)
    d = ndims(a)
    pad(a, b, l, fill(r, d,); kw...)
end
function pad(a::AbstractArray, b, l::Int=1, r::Int=l; kw...)
    d = ndims(a)
    pad(a, b, fill(l, d,), fill(r, d); kw...)
end

function pad(a::PaddedArray, b, l=1, r=l; kw...)
    y = pad(a.a, b, l, r; kw...)
    PaddedArray(y, Int.(l .+ left(a)), Int.(r .+ right(a)))
end
