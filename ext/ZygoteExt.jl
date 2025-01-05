module ZygoteExt
using Zygote, ArrayPadding
using Zygote: Buffer
ArrayPadding.fillfunc(::Type{Buffer{T,S}}) where {T,S} = ArrayPadding.fillfunc(S)
end
