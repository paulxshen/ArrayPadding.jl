
Base.vec(x::Number, N) = fill(x, N)
Base.vec(v::Union{AbstractVector,Tuple}, N) = v

fillfunc(::Type{<:Array}) = fill
constructor(::Type{<:Array}) = Array

# (f::Function)(::Type{Buffer{T,S}}) where {T,S} = f(S)
fillfunc(::Type{<:Buffer{T,S}}) where {T,S} = fillfunc(S)
constructor(::Type{<:Buffer{T,S}}) where {T,S} = constructor(S)