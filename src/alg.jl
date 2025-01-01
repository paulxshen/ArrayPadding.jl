function lr(a::S, v, i, l, r) where {S}
    N = ndims(a)
    T = eltype(a)
    ax = axes(a, i)
    sel = (1:N) .== i
    al = ar = nothing
    if l > 0
        o = l
        if v == :periodic
            I = ifelse.(sel, (ax[end-l+1:end],), :)
            al = a[I...]
        elseif v == :symmetric
            I = ifelse.(sel, (ax[begin+o+l-1:-1:begin+o],), :)
            al = a[I...]
        elseif v == :mirror
            I = ifelse.(sel, (ax[begin+o+l:-1:begin+1+o],), :)
            al = a[I...]
        elseif v == :replicate
            I = ifelse.(sel, (ax[begin+o:begin+o],), :)
            al = repeat(a[I...], (sel .* l .+ .!(sel))...)
        elseif v == :smooth
            # @ignore_derivatives I[i]=(begin+o:begin+o)
            # if size(a, i) == 1
            #     al = a[I...]
            # else
            #     I2 = [j == i ? (2+o:2+o)
            #     al = 2a[I...] - a[I2...]
            # end
        elseif isa(v, ReplicateRamp)
            # # @ignore_derivatives I[i]=((begin+o):(begin+o))
            # @ignore_derivatives I[i]=((begin+o):(begin+o)) : (1:size(a, j)) for j = 1:N]
            # v = a[I...]
            # Δ = (v.v .- v) / l
            # al = v .+ cat([c * Δ for c = l:-1:1]..., dims=i)
        else
            if isa(a, Buffer)

                # al = fillfunc(S)(T(v), (sel .* l .+ .!(sel) .* size(a))...)
                al = fill(T(v), (sel .* l .+ .!(sel) .* size(a))...)
            else
                al = T(v)
            end
        end
    end
    if r > 0
        o = r
        if v == :periodic
            I = ifelse.(sel, (1:r,), :)
            ar = a[I...]
        elseif v == :replicate
            I = ifelse.(sel, (ax[end-o:end-o],), :)
            ar = repeat(a[I...], (sel .* r .+ .!(sel))...)
        elseif v == :symmetric
            I = ifelse.(sel, (ax[end-o:-1:end-r+1-o],), :)
            ar = a[I...]
        elseif v == :mirror
            I = ifelse.(sel, (ax[end-1-o:-1:end-r-o],), :)
            ar = a[I...]
        elseif v == :smooth
            # @ignore_derivatives I[i]=ax[end-o:end-o]
            # if size(a, i) == 1
            #     ar = a[I...]
            # else
            #     I2 = [j == i ? ax[end-o-1:end-o-1]
            #     ar = 2a[I...] - a[I2...]
            # end
        elseif isa(v, ReplicateRamp)
            # @ignore_derivatives I[i]=ax[end-o:end-o]
            # v = a[I...]
            # Δ = (v.v .- v) / r
            # ar = v .+ cat([c * Δ for c = 1:r]..., dims=i)
        else
            if isa(a, Buffer)
                # ar = fillfunc(S)(T(v), (sel .* r .+ .!(sel) .* size(a))...)
                ar = fill(T(v), (sel .* r .+ .!(sel) .* size(a))...)
            else
                ar = T(v)
            end
        end
    end
    return (al, ar)
end

Base.vec(x::Number, N) = fill(x, N)
Base.vec(v::Union{AbstractVector,Tuple}, N) = v

fillfunc(S) = (args...) -> Base.fill(args...)