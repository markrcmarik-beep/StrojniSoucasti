# ver: 2026-04-26
using StrojniSoucasti, Test

@testset "uu2u - základní funkčnost" begin
    
    u = StrojniSoucasti.uu2u(0, 0)
    @test u ≈ 0 atol=1e-12

    u = StrojniSoucasti.uu2u(pi/4, pi/4)
    @test u ≈ 0 atol=1e-12

    u = StrojniSoucasti.uu2u(pi/2, pi/4)
    @test u ≈ 7*pi/4 atol=1e-12

    u = StrojniSoucasti.uu2u(pi, pi/2)
    @test u ≈ 3*pi/2 atol=1e-12

    u = StrojniSoucasti.uu2u(3*pi/2, pi)
    @test u ≈ 3*pi/2 atol=1e-12

    u = StrojniSoucasti.uu2u(2*pi, 3*pi/2)
    @test u ≈ 3*pi/2 atol=1e-12

    u = StrojniSoucasti.uu2u(5*pi/4, 7*pi/4)
    @test u ≈ pi/2 atol=1e-12

    u = StrojniSoucasti.uu2u(315*pi/180, 20*pi/180)
    @test u ≈ 65*pi/180 atol=1e-12

end

#-------------------------------------------------------------

@testset "uu2u - normalizace úhlů" begin

    # záporné úhly
    @test StrojniSoucasti.uu2u(-pi/2, pi/2) ≈ pi atol=1e-12
    @test StrojniSoucasti.uu2u(-pi, 0) ≈ pi atol=1e-12

    # úhly > 2π
    @test StrojniSoucasti.uu2u(3*pi, 4*pi) ≈ pi atol=1e-12
    @test StrojniSoucasti.uu2u(10*pi, 10*pi + pi/3) ≈ pi/3 atol=1e-12

end

#-------------------------------------------------------------

@testset "uu2u - hraniční stavy" begin

    # přechod přes 0
    @test StrojniSoucasti.uu2u(3*pi/2, pi/2) ≈ pi atol=1e-12

    # téměř 2π
    ε = 1e-10
    u = StrojniSoucasti.uu2u(0, 2*pi - ε)
    @test u ≈ 2*pi - ε atol=1e-10

    # téměř 0
    u = StrojniSoucasti.uu2u(0, ε)
    @test u ≈ ε atol=1e-12

end

#-------------------------------------------------------------

@testset "uu2u - vlastnosti" begin

    # rozsah <0, 2π)
    for (u1, u2) in [(0.3, 1.2), (5.0, 1.0), (-2.0, 3.0)]
        u = StrojniSoucasti.uu2u(u1, u2)
        @test 0 ≤ u < 2*pi
    end

    # invariance na posunutí o 2π
    u1 = 0.7
    u2 = 2.3

    u_ref = StrojniSoucasti.uu2u(u1, u2)

    @test StrojniSoucasti.uu2u(u1 + 2*pi, u2) ≈ u_ref atol=1e-12
    @test StrojniSoucasti.uu2u(u1, u2 + 2*pi) ≈ u_ref atol=1e-12
    @test StrojniSoucasti.uu2u(u1 + 4*pi, u2 + 6*pi) ≈ u_ref atol=1e-12

end