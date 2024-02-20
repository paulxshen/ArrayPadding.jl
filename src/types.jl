
struct PaddedArray
    a
    l
    r
    function PaddedArray(a, l=left(a), r=right(a))
        new(a, l, r)
    end
end
# struct PaddedArray{T,N} <: AbstractArray{T,N}
#     a
#     l
#     r
#     function PaddedArray(a, l=left(a), r=right(a))
#         new{eltype(a),ndims(a)}(collect(a), l, r)
#     end
# end
@functor PaddedArray


@forward PaddedArray.a Base.length, Base.size, Base.iterate, Base.getindex, Base.ndims, cat, Base.cat, Base.eltype
left(a::AbstractArray) = zeros(Int, ndims(a))
right(a::AbstractArray) = zeros(Int, ndims(a))
left(a::PaddedArray) = a.l
right(a::PaddedArray) = a.r
Base.Array(a::PaddedArray) = a.a
Base.collect(a::PaddedArray) = a.a
struct Ramp
    a
    b
end
struct ReplicateRamp
    v
end
