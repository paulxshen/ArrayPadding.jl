function lblock(a::S, v, i, l, ol=0) where {S}
    N = ndims(a)
    sz = size(a)
    T = eltype(a)
    ax = axes(a, i)
    sel = (1:N) .== i

    depth_counts = sel .* l .+ .!(sel)
    breadth_counts = sel .+ .!(sel) .* sz
    counts = sel .* l .+ .!(sel) .* sz
    depth_counts, breadth_counts, counts = @ignore_derivatives Tuple.((depth_counts, breadth_counts, counts))

    if v == :periodic
        I = ifelse.(sel, (ax[end-l+1:end],), :)
        I = @ignore_derivatives I
        al = a[I...]
    elseif v == :symmetric
        I = ifelse.(sel, (ax[begin+ol+l-1:-1:begin+ol],), :)
        I = @ignore_derivatives I
        al = a[I...]
    elseif v == :mirror
        I = ifelse.(sel, (ax[begin+ol+l:-1:begin+1+ol],), :)
        I = @ignore_derivatives I
        al = a[I...]
    elseif v == :replicate
        I = ifelse.(sel, (ax[begin+ol:begin+ol],), :)
        I = @ignore_derivatives I
        al = repeat(a[I...], depth_counts...)
    elseif v == :smooth
        # @ignore_derivatives I[i]=(begin+ol:begin+ol)
        # if size(a, i) == 1
        #     al = a[I...]
        # else
        #     I2 = [j == i ? (2+ol:2+ol)
        #     al = 2a[I...] - a[I2...]
        # end
    elseif isa(v, Function) || isa(v, TanhRamp)
        x = T.(l:-1:1)
        if isa(v, TanhRamp)
            x = T(v.v) * tanh.(2x / l)
        else
            x = v.(x)
        end
        b = reshape(constructor(S)(x), depth_counts...)
        al = repeat(b, breadth_counts...)

        # al = max.(al, selectdim(a, i, 1))
        I = ifelse.(sel, (ax[begin+ol:begin+ol],), :)
        edge = a[I...]
        al = max.(al, edge)
    else
        if S <: AbstractArray
            al = T(v)
        else
            f = fillfunc(S)
            al = f(T(v), counts)
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

    depth_counts = sel .* r .+ .!(sel)
    breadth_counts = sel .+ .!(sel) .* sz
    counts = sel .* r .+ .!(sel) .* sz
    depth_counts, breadth_counts, counts = @ignore_derivatives Tuple.((depth_counts, breadth_counts, counts))

    if v == :periodic
        I = ifelse.(sel, (1:r,), :)
        I = @ignore_derivatives I
        ar = a[I...]
    elseif v == :replicate
        I = ifelse.(sel, (ax[end-or:end-or],), :)
        I = @ignore_derivatives I
        ar = repeat(a[I...], depth_counts...)
    elseif v == :symmetric
        I = ifelse.(sel, (ax[end-or:-1:end-r+1-or],), :)
        I = @ignore_derivatives I
        ar = a[I...]
    elseif v == :mirror
        I = ifelse.(sel, (ax[end-1-or:-1:end-r-or],), :)
        I = @ignore_derivatives I
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
        b = reshape(constructor(S)(x), depth_counts...)
        ar = repeat(b, breadth_counts...)
        # ar = max.(ar, selectdim(a, i, size(a, i)))

        I = ifelse.(sel, (ax[end-or:end-or],), :)
        edge = a[I...]
        ar = max.(ar, edge)
    else
        if S <: AbstractArray
            ar = T(v)
        else
            f = fillfunc(S)
            ar = f(T(v), counts)
        end
    end
    ar
end
