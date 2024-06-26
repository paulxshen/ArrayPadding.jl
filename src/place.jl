
function place(a, o, b; replace=false)
    # if replace
    #     l, r = round(o) - 1, size(a) .- size(b) .- round(o) .+ 1
    #     a = a .* pad(zeros(Bool, size(b)), true, l, r)
    # end
    i = floor(o)
    w = 1 - mean(abs.(o - i))
    w = (w, 1 - w)
    i = (i, i + 1)
    for (w, i) = zip(w, i)
        l, r = Tuple(i) .- 1, size(a) .- size(b) .- Tuple(i) .+ 1

        if w > 0
            a += eltype(a)(w) * pad(b, 0, l, r)
        end
    end
    a
end
# function place!(a::AbstractArray, b, o)
#     buf = bufferfrom(a)
#     buf = place!(buf, b, o)
#     copy(buf)
# end
function place!(a, o, b)
    a[[i:j for (i, j) = zip(o, o .+ size(b) .- 1)]...] = b
    a
end

function place!(a, b; center)
    # @show size(a), size(b), o
    place!(a, b, center .- floor.((size(b) .- 1) .÷ 2))
end
