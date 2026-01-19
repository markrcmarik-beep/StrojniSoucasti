# ver: 2026-01-16
using StrojniSoucasti
using Test

#include("zavit.jl")
@testset "zavity" begin

A = zavity("M8")

@test A.name == "M8"
@test A.d == 8.0
@test A.p == 1.25

println("Označení: ", A.name)
println("Průměr d = ", A.d)
println("Stoupání p = ", A.p)

A1 = zavity("M8x1")

@test A1.name == "M8x1"
@test A1.d == 8.0
@test A1.p == 1

println("Označení: ", A1.name)
println("Průměr d = ", A1.d)
println("Stoupání p = ", A1.p)

A2 = zavity("M10x1.25")
println(A2)

A3 = zavity("M6x0,5")
println(A3)

end
