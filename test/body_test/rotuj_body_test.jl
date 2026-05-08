# ver: 2026-05-08
# Test script for rotuj_body.jl

using StrojniSoucasti, Test

@testset "rotuj_body" begin

    body = [(1, 0), (0, 1), (-1, 0)]
    rotovane = StrojniSoucasti.rotuj_body(body, pi / 2)

    @test isa(rotovane, Vector{Tuple{Float64, Float64}})
    @test length(rotovane) == 3
    @test rotovane[1][1] ≈ 0.0 atol=1e-12
    @test rotovane[1][2] ≈ 1.0 atol=1e-12
    @test rotovane[2][1] ≈ -1.0 atol=1e-12
    @test rotovane[2][2] ≈ 0.0 atol=1e-12
    @test rotovane[3][1] ≈ 0.0 atol=1e-12
    @test rotovane[3][2] ≈ -1.0 atol=1e-12

    jeden_bod_ve_vektoru = [(3, 4)]
    rotovany = StrojniSoucasti.rotuj_body(jeden_bod_ve_vektoru, pi)
    @test rotovany[1][1] ≈ -3.0 atol=1e-12
    @test rotovany[1][2] ≈ -4.0 atol=1e-12

    kolem_stredu = StrojniSoucasti.rotuj_body([(2, 1)], pi / 2, S=(1, 1))
    @test kolem_stredu[1][1] ≈ 1.0 atol=1e-12
    @test kolem_stredu[1][2] ≈ 2.0 atol=1e-12

    @test_throws MethodError StrojniSoucasti.rotuj_body((3, 4), pi / 2)

    oblouk = StrojniSoucasti.brsb2body((0.0, 0.0), 10.0, "+", (10.0, 0.0), 0.5)
    rotovany_oblouk = StrojniSoucasti.rotuj_body(oblouk, pi / 3)
    @test length(rotovany_oblouk) == length(oblouk)

end
