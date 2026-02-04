# ver: 2026-01-20
using StrojniSoucasti, Test

#include("zavit.jl")
@testset "zavity" begin

A = zavity("M8")
@test A.name == "M8"
@test A.d == 8.0
@test A.p == 1.25

A1 = zavity("M8x1")
@test A1.name == "M8x1"
@test A1.d == 8.0
@test A1.p == 1

A2 = zavity("M10x1.25")
@test A2.name == "M10x1.25"
@test A2.d == 10.0
@test A2.p == 1.25

A3 = zavity("M6x0,5")
@test A3.name == "M6x0.5"
@test A3.d == 6.0
@test A3.p == 0.5

end
