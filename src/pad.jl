

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
function pad(a::T, v, l::Union{AbstractVector,Tuple}, r::Base.AbstractVecOrTuple=l) where {T}
    all(iszero, l) && all(iszero, r) && return a
    # N = ndims(a)
    # l, r = vec.((l, r), N)
    # for (dims, l, r) in zip(1:N, l, r)
    #     al, ar = lr(a, v, dims, l, r, 0, 0, true)
    #     if l > 0
    #         a = cat(al, a; dims)
    #     end
    #     if r > 0
    #         a = cat(a, ar; dims)
    #     end
    # end
    # a
    sz = Tuple(size(a) .+ l .+ r)
    _a = Buffer(a, sz)
    I = @ignore_derivatives range.(l .+ 1, sz .- r)
    _a[I...] = a
    pad!(_a, v, l, r)
    copy(_a)
end

function pad!(a, v, l, r=l)
    all(iszero, l) && all(iszero, r) && return a
    N = ndims(a)
    l, r = vec.((l, r), N)
    for (i, l, r) in zip(1:N, l, r)
        sel = i .== 1:N
        ax = axes(a, i)
        al, ar = lr(a, v, i, l, r, l, r, !isa(a, AbstractArray))
        if l > 0
            I = ifelse.(sel, (ax[begin:begin+l-1],), :)
            if !isa(a, AbstractArray)
                a[I...] = al
            else
                a[I...] .= al
            end
        end
        if r > 0
            I = ifelse.(sel, (ax[end-r+1:end],), :)
            if !isa(a, AbstractArray)
                a[I...] = ar
            else
                a[I...] .= ar
            end
        end
    end
    a
end

function pad(a::AbstractArray, v, l::Int, r::Base.AbstractVecOrTuple; kw...)
    N = ndims(a)
    pad(a, v, fill(l, N,), r)
end
function pad(a::AbstractArray, v, l::Base.AbstractVecOrTuple, r::Int; kw...)
    N = ndims(a)
    pad(a, v, l, fill(r, N,))
end
function pad(a::AbstractArray, v, l::Int=1, r::Int=l; dims=1:ndims(a))
    sel = in.(1:ndims(a), (dims,))
    pad(a, v, l * sel, r * sel)
end
