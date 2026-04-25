# ver: 2026-04-24
# Test script for buur2bb.jl

using StrojniSoucasti, Unitful, Test

@testset "buur2bb" begin

    B, C = StrojniSoucasti.buur2bb((10, 20), 30*pi/180, 45*pi/180, 5)
    @test isa(B, Tuple)
    @test isa(C, Tuple)
    @test length(B) == 2
    @test length(C) == 2
    @test B[1] ≈ 42.89 atol=1e-2
    @test B[2] ≈ 38.99 atol=1e-2
    @test C[1] ≈ 36.86 atol=1e-2
    @test C[2] ≈ 46.86 atol=1e-2

    B, C = StrojniSoucasti.buur2bb((1, 0.5), 90*pi/180, 180*pi/180, 10)
    @test B[1] ≈ 1 atol=1e-2
    @test B[2] ≈ 10.5 atol=1e-2
    @test C[1] ≈ -9 atol=1e-2
    @test C[2] ≈ 0.5 atol=1e-2

    B, C = StrojniSoucasti.buur2bb((5, 5), 45*pi/180, 135*pi/180, 7)
    @test B[1] ≈ 9.9497 atol=1e-2
    @test B[2] ≈ 9.9497 atol=1e-2
    @test C[1] ≈ 0.0503 atol=1e-2
    @test C[2] ≈ 9.9497 atol=1e-2

    B, C = StrojniSoucasti.buur2bb((15, 25), 120*pi/180, 240*pi/180, 3)
    @test B[1] ≈ 14.13 atol=1e-2
    @test B[2] ≈ 26.5 atol=1e-2
    @test C[1] ≈ 14.13 atol=1e-2
    @test C[2] ≈ 23.5 atol=1e-2

    B, C = StrojniSoucasti.buur2bb((15, 25), 20*pi/180, 300*pi/180, 7)
    @test B[1] ≈ 22.84 atol=1e-2
    @test B[2] ≈ 27.85 atol=1e-2
    @test C[1] ≈ 19.17 atol=1e-2
    @test C[2] ≈ 17.78 atol=1e-2

    B, C = StrojniSoucasti.buur2bb((10, 5), 330*pi/180, 20*pi/180, 10)
    @test B[1] ≈ 28.57 atol=1e-2
    @test B[2] ≈ -5.72 atol=1e-2
    @test C[1] ≈ 30.15 atol=1e-2
    @test C[2] ≈ 12.33 atol=1e-2


end
