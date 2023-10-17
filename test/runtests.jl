using Test
using ArrayPadding
# include("../src/main.jl")

a = [1 2; 3 4]

@test pad(a, -1, 1) == [
    -1 -1 -1 -1
    -1 1 2 -1
    -1 3 4 -1
    -1 -1 -1 -1
]

@test pad(a, -1, 1, 0) == [
    -1 -1 -1
    -1 1 2
    -1 3 4
]

@test pad(a, -1, (0, 1), (1, 0)) == [
    -1 1 2
    -1 3 4
    -1 -1 -1
]

@test pad(a, :periodic, (1, 0)) == [
    3 4
    1 2
    3 4
    1 2
]

@test pad(a, :symmetric, 1) == [
    1 1 2 2
    1 1 2 2
    3 3 4 4
    3 3 4 4
]

@test pad(a, :mirror, 1) == [
    4 3 4 3
    2 1 2 1
    4 3 4 3
    2 1 2 1
]
@test pad(a, :replicate, 1; lazy=true) == [
    1 1 2 2
    1 1 2 2
    3 3 4 4
    3 3 4 4
]

@test pad(a, :smooth, 1) == [
    -2 -1 0 1
    0 1 2 3
    2 3 4 5
    4 5 6 7
]