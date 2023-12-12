using LazyArrays, Functors
# using Lazy: @forward

function cat(a...; lazy=false, dims)
    if lazy
        if dims == 1
            return ApplyArray(vcat, a...)
        elseif dims == 2
            return ApplyArray(hcat, a...)
        else
            error("lazy padding only supported up to dim 2")
        end
    end
    Base.cat(a...; dims)
end
# struct PaddedArray
struct PaddedArray
    a::AbstractArray
    l
    r
    function PaddedArray(a, l=left(a), r=right(a))
        new(Array(a), l, r)
    end
    # function PaddedArray(a::AbstractArray, l, r)
    #     new{eltype(a),ndims(a)}(a, l, r)
    # end
end
@functor PaddedArray
# struct PaddedArray{T,N} <: AbstractArray{T,N}
#     a::AbstractArray{T,N}
#     #     a
#     l
#     r
#     function PaddedArray(a::AbstractArray, l, r)
#         new{eltype(a),ndims(a)}(a, l, r)
#     end
# end
# @forward PaddedArray.a Base.length, Base.size, Base.iterate, Base.getindex, Base.ndims, cat, Base.cat
left(a::AbstractArray) = zeros(Int, ndims(a))
right(a::AbstractArray) = zeros(Int, ndims(a))
left(a::PaddedArray) = a.l
right(a::PaddedArray) = a.r
Base.Array(a::PaddedArray) = a.a
struct Ramp
    a
    b
end
struct ReplicateRamp
    v
end
