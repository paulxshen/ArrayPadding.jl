function lr(a, b, i, l, r, out=true)
    d = ndims(a)
    al = ar = nothing
    if l > 0
        if b == :periodic
            I = [j == i ? ((size(a, i)-l+1):size(a, i)) : (:) for j = 1:d]
            al = view(a, I...)
        elseif b == :symmetric
            I = [j == i ? (l:-1:1) : (:) for j = 1:d]
            al = view(a, I...)
        elseif b == :mirror
            I = [j == i ? (l+1:-1:2) : (:) for j = 1:d]
            al = view(a, I...)
        elseif b == :replicate
            I = [j == i ? (out ? (1:1) : ((1+l):(1+l))) : (:) for j = 1:d]
            s = [j == i ? l : 1 for j = 1:d]
            al = repeat(view(a, I...), s...)
        elseif b == :smooth
            I = [j == i ? (1:1) : (:) for j = 1:d]
            if size(a, i) == 1
                al = view(a, I...)
            else
                I2 = [j == i ? (2:2) : (:) for j = 1:d]
                al = 2view(a, I...) - a[I2...]
            end
        elseif isa(b, ReplicateRamp)
            I = [j == i ? (out ? (1:1) : ((1+l):(1+l))) : (:) for j = 1:d]
            v = a[I...]
            Δ = (b.v .- v) / l
            al = v .+ cat([c * Δ for c = l-1:-1:0]..., dims=i)
        else
            al = fill(b, [j == i ? l : size(a, j) for j = 1:d]...)
        end
    end
    if r > 0
        if b == :periodic
            I = [j == i ? (1:r) : (:) for j = 1:d]
            ar = view(a, I...)
        elseif b == :replicate
            I = [j == i ? (out ? axes(a, i)[end:end] : axes(a, i)[end-r:end-r]) : (:) for j = 1:d]
            s = [j == i ? r : 1 for j = 1:d]
            ar = repeat(view(a, I...), s...)
        elseif b == :symmetric
            I = [j == i ? axes(a, i)[end:-1:end-r+1] : (:) for j = 1:d]
            ar = view(a, I...)
        elseif b == :mirror
            I = [j == i ? axes(a, i)[end-1:-1:end-r] : (:) for j = 1:d]
            ar = view(a, I...)
        elseif b == :smooth
            I = [j == i ? axes(a, i)[end:end] : (:) for j = 1:d]
            if size(a, i) == 1
                ar = view(a, I...)
            else
                I2 = [j == i ? axes(a, i)[end-1:end-1] : (:) for j = 1:d]
                ar = 2view(a, I...) - a[I2...]
            end
        elseif isa(b, ReplicateRamp)
            I = [j == i ? axes(a, i)[end:end] : (:) for j = 1:d]
            v = a[I...]
            Δ = (b.v .- v) / r
            ar = v .+ cat([c * Δ for c = (0:r-1)]..., dims=i)
        else
            ar = fill(b, [j == i ? r : size(a, j) for j = 1:d]...)
        end
    end
    al, ar
end



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