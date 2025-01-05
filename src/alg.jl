function lr(a::S, v, i, l, r, ol=0, or=0, dofill=false) where {S}
    N = ndims(a)
    T = eltype(a)
    ax = axes(a, i)
    sel = (1:N) .== i
    al = ar = nothing
    if l > 0
        if v == :periodic
            I = ifelse.(sel, (ax[end-l+1:end],), :)
            al = a[I...]
        elseif v == :symmetric
            I = ifelse.(sel, (ax[begin+ol+l-1:-1:begin+ol],), :)
            al = a[I...]
        elseif v == :mirror
            I = ifelse.(sel, (ax[begin+ol+l:-1:begin+1+ol],), :)
            al = a[I...]
        elseif v == :replicate
            I = ifelse.(sel, (ax[begin+ol:begin+ol],), :)
            al = repeat(a[I...], (sel .* l .+ .!(sel))...)
        elseif v == :smooth
            # @ignore_derivatives I[i]=(begin+ol:begin+ol)
            # if size(a, i) == 1
            #     al = a[I...]
            # else
            #     I2 = [j == i ? (2+ol:2+ol)
            #     al = 2a[I...] - a[I2...]
            # end
        elseif isa(v, ReplicateRamp)
            # # @ignore_derivatives I[i]=((begin+ol):(begin+ol))
            # @ignore_derivatives I[i]=((begin+ol):(begin+ol)) : (1:size(a, j)) for j = 1:N]
            # v = a[I...]
            # Δ = (v.v .- v) / l
            # al = v .+ cat([c * Δ for c = l:-1:1]..., dims=i)
        else
            if dofill
                f = fillfunc(S)
                al = f(T(v), Tuple(sel .* l .+ .!(sel) .* size(a)))
                # al = fill(T(v), (sel .* l .+ .!(sel) .* size(a))...)
            else
                al = T(v)
            end
        end
    end
    if r > 0
        if v == :periodic
            I = ifelse.(sel, (1:r,), :)
            ar = a[I...]
        elseif v == :replicate
            I = ifelse.(sel, (ax[end-or:end-or],), :)
            ar = repeat(a[I...], (sel .* r .+ .!(sel))...)
        elseif v == :symmetric
            I = ifelse.(sel, (ax[end-or:-1:end-r+1-or],), :)
            ar = a[I...]
        elseif v == :mirror
            I = ifelse.(sel, (ax[end-1-or:-1:end-r-or],), :)
            ar = a[I...]
        elseif v == :smooth
            # @ignore_derivatives I[i]=ax[end-or:end-or]
            # if size(a, i) == 1
            #     ar = a[I...]
            # else
            #     I2 = [j == i ? ax[end-or-1:end-or-1]
            #     ar = 2a[I...] - a[I2...]
            # end
        elseif isa(v, ReplicateRamp)
            # @ignore_derivatives I[i]=ax[end-or:end-or]
            # v = a[I...]
            # Δ = (v.v .- v) / r
            # ar = v .+ cat([c * Δ for c = 1:r]..., dims=i)
        else
            if dofill
                f = fillfunc(S)
                ar = f(T(v), Tuple(sel .* r .+ .!(sel) .* size(a)))
                # ar = fill(T(v), (sel .* r .+ .!(sel) .* size(a))...)
            else
                ar = T(v)
            end
        end
    end
    return (al, ar)
end

Base.vec(x::Number, N) = fill(x, N)
Base.vec(v::Union{AbstractVector,Tuple}, N) = v

fillfunc(::Type{<:Array}) = (args...) -> Base.fill(args...)