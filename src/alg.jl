function lr(a::T, b, i, l, r, out=true, ol=0, or=ol) where {T}
    d = ndims(a)
    sel = (1:d) .== i
    al = ar = nothing
    if l > 0
        o = out ? 0 : l + ol
        if b == :periodic
            I = [j == i ? ((size(a, i)-l+1):size(a, i)) : (:) for j = 1:d]
            al = a[I...]
        elseif b == :symmetric
            I = [j == i ? (l+o:-1:1+o) : (:) for j = 1:d]
            al = a[I...]
        elseif b == :mirror
            I = [j == i ? (l+1+o:-1:2+o) : (:) for j = 1:d]
            al = a[I...]
        elseif b == :replicate
            I = [j == i ? ((1+o):(1+o)) : (:) for j = 1:d]
            # s = [j == i ? l : 1 for j = 1:d]
            # al = repeat(a[I...], s...)
            al = cat(fill(selectdim(a, i, o+1:o+1), l)..., dims=i)
            # al = repeat(selectdim(a, i, o+1:o+1), (l .* sel + (1 .- sel))...)
        elseif b == :smooth
            I = [j == i ? (1+o:1+o) : (:) for j = 1:d]
            if size(a, i) == 1
                al = a[I...]
            else
                I2 = [j == i ? (2+o:2+o) : (:) for j = 1:d]
                al = 2a[I...] - a[I2...]
            end
        elseif isa(b, ReplicateRamp)
            # I = [j == i ? ((1+o):(1+o)) : (:) for j = 1:d]
            I = [j == i ? ((1+o):(1+o)) : (1:size(a, j)) for j = 1:d]
            v = a[I...]
            Δ = (b.v .- v) / l
            al = v .+ cat([c * Δ for c = l:-1:1]..., dims=i)
        else
            al = fill(b, Tuple(sel .* l .+ (1 .- sel) .* size(a)))
        end
    end
    if r > 0
        o = out ? 0 : r + or
        if b == :periodic
            I = [j == i ? (1:r) : (:) for j = 1:d]
            ar = a[I...]
        elseif b == :replicate
            # I = [j == i ? axes(a, i)[end-o:end-o] : (:) for j = 1:d]
            # s = [j == i ? r : 1 for j = 1:d]
            # ar = repeat(a[I...], s...)
            j = size(a, i) - o
            ar = cat(fill(selectdim(a, i, j:j), r)..., dims=i)
            # ar = repeat(selectdim(a, i, j:j), (r .* sel + (1 .- sel))...)
        elseif b == :symmetric
            I = [j == i ? axes(a, i)[end-o:-1:end-r+1-o] : (:) for j = 1:d]
            ar = a[I...]
        elseif b == :mirror
            I = [j == i ? axes(a, i)[end-1-o:-1:end-r-o] : (:) for j = 1:d]
            ar = a[I...]
        elseif b == :smooth
            I = [j == i ? axes(a, i)[end-o:end-o] : (:) for j = 1:d]
            if size(a, i) == 1
                ar = a[I...]
            else
                I2 = [j == i ? axes(a, i)[end-o-1:end-o-1] : (:) for j = 1:d]
                ar = 2a[I...] - a[I2...]
            end
        elseif isa(b, ReplicateRamp)
            I = [j == i ? axes(a, i)[end-o:end-o] : (:) for j = 1:d]
            v = a[I...]
            Δ = (b.v .- v) / r
            ar = v .+ cat([c * Δ for c = 1:r]..., dims=i)
        else
            ar = fill(b, Tuple(sel .* r .+ (1 .- sel) .* size(a)))
        end
    end
    return (al, ar)
end

Base.vec(x::Number, d) = fill(x, d)
Base.vec(v::Union{AbstractVector,Tuple}, d) = v

