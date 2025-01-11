tuplewrap(x::Tuple) = x
tuplewrap(x) = (x,)
Base.identity(x...) = x

fillfunc(::Type{<:Array}) = fill
constructor(::Type{<:Array}) = Array

# (f::Function)(::Type{Buffer{T,S}}) where {T,S} = f(S)
fillfunc(::Type{<:Buffer{T,S}}) where {T,S} = fillfunc(S)
constructor(::Type{<:Buffer{T,S}}) where {T,S} = constructor(S)

struct TanhRamp
    v
end