# ver: 2026-04-25
# Test script for uu2u.jl

using StrojniSoucasti, Unitful, Test

@testset "uu2u" begin
    
    u = StrojniSoucasti.uu2u(0, 0)
    @test isa(u, Number)
    @test u ≈ 0 atol=1e-4

    u = StrojniSoucasti.uu2u(pi/4, pi/4)
    @test u ≈ 0 atol=1e-4

    u = StrojniSoucasti.uu2u(pi/2, pi/4)
    @test u ≈ 7*pi/4 atol=1e-2

    u = StrojniSoucasti.uu2u(pi, pi/2)
    @test u ≈ 3*pi/2 atol=1e-4

    u = StrojniSoucasti.uu2u(3*pi/2, pi)
    @test u ≈ 3*pi/2 atol=1e-4

    u = StrojniSoucasti.uu2u(2*pi, 3*pi/2)
    @test u ≈ 3*pi/2 atol=1e-4

    u = StrojniSoucasti.uu2u(5*pi/4, 7*pi/4)
    @test u ≈ pi/2 atol=1e-4

    u = StrojniSoucasti.uu2u(315*pi/180, 20*pi/180)
    @test u ≈ 65*pi/180 atol=1e-2

end
