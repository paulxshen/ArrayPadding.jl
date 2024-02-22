function lr(a, b, i, l, r, out=true, ol=0, or=ol)
    d = ndims(a)
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
            s = [j == i ? l : 1 for j = 1:d]
            al = repeat(a[I...], s...)
        elseif b == :smooth
            I = [j == i ? (1+o:1+o) : (:) for j = 1:d]
            if size(a, i) == 1
                al = a[I...]
            else
                I2 = [j == i ? (2+o:2+o) : (:) for j = 1:d]
                al = 2a[I...] - a[I2...]
            end
        elseif isa(b, ReplicateRamp)
            I = [j == i ? ((1+o):(1+o)) : (:) for j = 1:d]
            v = a[I...]
            Δ = (b.v .- v) / l
            al = v .+ cat([c * Δ for c = l-1:-1:0]..., dims=i)
        else
            al = fill(b, [j == i ? l : size(a, j) for j = 1:d]...)
        end
    end
    if r > 0
        o = out ? 0 : r + or
        if b == :periodic
            I = [j == i ? (1:r) : (:) for j = 1:d]
            ar = a[I...]
        elseif b == :replicate
            I = [j == i ? axes(a, i)[end-o:end-o] : (:) for j = 1:d]
            s = [j == i ? r : 1 for j = 1:d]
            ar = repeat(a[I...], s...)
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
            ar = v .+ cat([c * Δ for c = (0:r-1)]..., dims=i)
        else
            ar = fill(b, [j == i ? r : size(a, j) for j = 1:d]...)
        end
    end
    al, ar
end

Base.vec(x::Number, d) = fill(x, d)
Base.vec(v::Union{AbstractVector,Tuple}, d) = v

# Base.view(b::Buffer, i...) = b[i...]

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