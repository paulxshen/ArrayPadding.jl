function lblock(a::S, v, i, l, ol=0) where {S}
    N = ndims(a)
    sz = size(a)
    T = eltype(a)
    ax = axes(a, i)
    sel = (1:N) .== i
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
    elseif isa(v, Function) || isa(v, TanhRamp)
        x = T.(1:l)
        if isa(v, TanhRamp)
            x = T(v.v) * tanh.(2x / l)
        else
            x = v.(x)
        end
        b = reshape(constructor(S)(x), (l .* sel .+ .!(sel))...)
        al = repeat(b, (sel .+ .!(sel) .* sz)...)
    else
        if S <: AbstractArray
            al = T(v)
        else
            f = fillfunc(S)
            al = f(T(v), Tuple(sel .* l .+ .!(sel) .* size(a)))
        end
    end
    al
end
function rblock(a::S, v, i, r, or=0) where {S}
    N = ndims(a)
    sz = size(a)
    T = eltype(a)
    ax = axes(a, i)
    sel = (1:N) .== i
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
    elseif isa(v, Function) || isa(v, TanhRamp)
        x = T.(1:r)
        if isa(v, TanhRamp)
            x = T(v.v) * tanh.(2x / r)
        else
            x = v.(x)
        end
        b = reshape(constructor(S)(x), (r .* sel .+ .!(sel))...)
        ar = repeat(b, (sel .+ .!(sel) .* sz)...)
    else
        if S <: AbstractArray
            ar = T(v)
        else
            f = fillfunc(S)
            ar = f(T(v), Tuple(sel .* r .+ .!(sel) .* size(a)))
        end
    end
    ar
end
