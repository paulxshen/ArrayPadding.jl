const at, bt = Float32.([1 / 16 1] / [0.75^2 1; 1.75^2 1])
const av, bv = Float32.([-0.25^3 -1 / 4] / [0.75^3 0.75; 1.75^3 1.75])

# indices selecting `J` along dim `i` and everything along the others
slabidx(a, i, J) = @ignore_derivatives Base.setindex(ntuple(_ -> (:), ndims(a)), J, i)
slab(a, i, J) = a[slabidx(a, i, J)...]

# indices `k` cells in from the edge of a core inset by `o` from the left/right end of `ax`
inward(ax, left, o, k) = left ? (first(ax) + o - 1) .+ k : (last(ax) - o + 1) .- k

# vector `x` laid out along dim `i`, on the same device as `a`
along(a, i, x) = reshape(constructor(typeof(a))(x), Base.setindex(ntuple(_ -> 1, ndims(a)), length(x), i))

"""
    block(a, v, i, n, left, o=0, o′=0)

Border block `v` of depth `n` on the `left` (else right) side of dim `i`, for a core inset by `o` on that side and `o′` on the other. Returns anything broadcastable to the block's shape.
"""
function block(a, v, i, n, left, o=0, o′=0)
    d = left ? (n:-1:1) : (1:n) # distance of each border cell from the core
    cells(k, left=left, o=o) = slab(a, i, @ignore_derivatives inward(axes(a, i), left, o, k))

    v == :periodic && return cells(d, !left, o′)
    v == :symmetric && return cells(d)
    v == :antisymmetric && return -cells(d)
    v == :mirror && return cells(d .+ 1)
    v == :replicate && return cells(1:1)
    v == :smooth && return cells(1:1) .+ along(a, i, d) .* (cells(1:1) - cells(2:2))
    v == :taper && return (4cells(1:1) - cells(2:2)) / 3
    v == :v0 && return av * cells(1:1) + bv * cells(2:2)
    v == :t0 && return at * cells(1:1) + bt * cells(2:2)
    v isa Function && return max.(along(a, i, v.(d)), cells(1:1))
    eltype(a)(v)
end
