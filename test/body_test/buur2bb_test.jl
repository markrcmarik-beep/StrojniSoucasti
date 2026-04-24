# ver: 2026-04-24
# Test script for buur2bb.jl

using StrojniSoucasti, Unitful, Test

@testset "buur2bb" begin

    B, C = StrojniSoucasti.buur2bb((10, 20), 30*pi/180, 45*pi/180, 5)
    @test isa(B, Tuple)
    @test isa(C, Tuple)
    @test length(B) == 2
    @test length(C) == 2
    @test B[1] ≈ 14.33 atol=1e-2
    @test B[2] ≈ 22.5 atol=1e-2
    @test C[1] ≈ 13.54 atol=1e-2
    @test C[2] ≈ 23.54 atol=1e-2

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
    @test B[1] ≈ 13.5 atol=1e-2
    @test B[2] ≈ 27.6 atol=1e-2
    @test C[1] ≈ 13.5 atol=1e-2
    @test C[2] ≈ 22.4 atol=1e-2

    B, C = StrojniSoucasti.buur2bb((15, 25), 20*pi/180, 300*pi/180, 7)
    @test B[1] ≈ 21.57 atol=1e-2
    @test B[2] ≈ 27.39 atol=1e-2
    @test C[1] ≈ 18.5 atol=1e-2
    @test C[2] ≈ 18.94 atol=1e-2

    B, C = StrojniSoucasti.buur2bb((10, 5), 330*pi/180, 20*pi/180, 10)
    @test B[1] ≈ 18.66 atol=1e-2
    @test B[2] ≈ 0 atol=1e-2
    @test C[1] ≈ 19.4 atol=1e-2
    @test C[2] ≈ 8.42 atol=1e-2


end
