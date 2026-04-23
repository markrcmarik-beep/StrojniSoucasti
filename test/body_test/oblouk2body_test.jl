# ver: 2026-04-23
# Test script for oblouk2body.jl

using StrojniSoucasti, Test

@testset "oblouk2body" begin
    b_plus = StrojniSoucasti.oblouk2body((1, 0), (0, 1), 1.0, "+", 0.8)
    @test length(b_plus) == 3
    @test b_plus[1] == (1.0, 0.0)
    @test b_plus[end] == (0.0, 1.0)
    @test isapprox(b_plus[2][1], sqrt(2) / 2; atol=1e-12)
    @test isapprox(b_plus[2][2], sqrt(2) / 2; atol=1e-12)

    b_minus = StrojniSoucasti.oblouk2body((1, 0), (0, 1), 1.0, "-", 0.8)
    @test length(b_minus) == 3
    @test b_minus[1] == (1.0, 0.0)
    @test b_minus[end] == (0.0, 1.0)
    @test isapprox(b_minus[2][1], 1 - sqrt(2) / 2; atol=1e-12)
    @test isapprox(b_minus[2][2], 1 - sqrt(2) / 2; atol=1e-12)

    b_coarse = StrojniSoucasti.oblouk2body((1, 0), (0, 1), 1.0, "+", 1.0)
    b_fine = StrojniSoucasti.oblouk2body((1, 0), (0, 1), 1.0, "+", 0.2)
    @test length(b_fine) > length(b_coarse)

    @test_throws ArgumentError StrojniSoucasti.oblouk2body((0, 0), (0, 0), 1.0, "+", 0.5)
    @test_throws ArgumentError StrojniSoucasti.oblouk2body((0, 0), (1, 0), 0.0, "+", 0.5)
    @test_throws ArgumentError StrojniSoucasti.oblouk2body((0, 0), (2, 0), 0.5, "+", 0.5)
    @test_throws ArgumentError StrojniSoucasti.oblouk2body((0, 0), (1, 0), 1.0, "x", 0.5)
    @test_throws ArgumentError StrojniSoucasti.oblouk2body((0, 0), (1, 0), 1.0, "+", 0.0)
end
