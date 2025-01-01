using CUDA
using Zygote: Buffer
a = Buffer([1], 2, 2)
a[:, 1] .= 8
a

# @assert pad(a, :smooth, 1) == [
#     -4 0 4 8 12 16
#     -3 1 5 9 13 17
#     -2 2 6 10 14 18
#     -1 3 7 11 15 19
#     0 4 8 12 16 20
#     1 5 9 13 17 21
# ]

# @assert pad!(copy(a), :smooth, 1) == [
#     1 5 9 13
#     2 6 10 14
#     3 7 11 15
#     4 8 12 16
# ]

# a0 = copy(a)