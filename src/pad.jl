

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
function pad(a::T, vl, vr, l, r) where {T}
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
    pad!(_a, vl, vr, l, r)
    copy(_a)
end
pad(a, v, l, r=l) = pad(a, v, v, l, r)

function pad!(a, vl, vr, l, r)
    all(iszero, l) && all(iszero, r) && return a
    N = ndims(a)
    S = typeof(a)
    for (i, vl, vr, l, r) in broadcast(identity, 1:N, vl, vr, l, r)
        sel = i .== 1:N
        ax = axes(a, i)
        if l > 0
            al = lblock(a, vl, i, l, l)
            I = ifelse.(sel, (ax[begin:begin+l-1],), :)
            if !isa(a, AbstractArray)
                a[I...] = al
            else
                a[I...] .= al
            end
        end
        if r > 0
            ar = rblock(a, vr, i, r, r)
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
pad!(a, v, l, r=l) = pad!(a, v, v, l, r)
# function pad(a::AbstractArray, v, l::Int=1, r::Int=l; dims=1:ndims(a))
#     sel = in.(1:ndims(a), (dims,))
#     pad(a, v, l * sel, r * sel)
# end
