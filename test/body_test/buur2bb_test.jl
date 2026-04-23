# ver: 2026-04-23
# Test script for buur2bb.jl

using StrojniSoucasti, Unitful, Test

@testset "bdu2b" begin

    B, C = StrojniSoucasti.buur2bb((10, 20), 30*pi/180, 45*pi/180, 5)
    @test isa(B, Tuple)
    @test isa(C, Tuple)
    @test length(B) == 2
    @test length(C) == 2
    @test B[1] ≈ 14.33 atol=1e-2
    @test B[2] ≈ 22.5 atol=1e-2
    @test C[1] ≈ 13.54 atol=1e-2
    @test C[2] ≈ 23.54 atol=1e-2

end