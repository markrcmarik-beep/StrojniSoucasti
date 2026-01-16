# ver: 2026-01-16
using StrojniSoucasti
using Test

#include("zavit.jl")

A = zavity("M8")

@test A.name == "M8"
@test A.d == 8.0
@test A.pitch == 1.25

println("Označení: ", A.name)
println("Průměr d = ", A.d)
println("Stoupání p = ", A.pitch)
