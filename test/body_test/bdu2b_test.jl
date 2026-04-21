# ver: 2026-04-21
# Test script for bdu2b.jl

using StrojniSoucasti, Unitful, Test

@testset "bdu2b" begin

    B = StrojniSoucasti.bdu2b((10, 20), 5, 30*pi/180)
    @test isa(B, Tuple)
    @test length(B) == 2
    @test B[1] ≈ 12.5 atol=1e-3
    @test B[2] ≈ 24.33 atol=1e-3

    B = StrojniSoucasti.bdu2b((0, 0), 10, 90*pi/180)
    @test B[1] ≈ 10.0 atol=1e-4
    @test B[2] ≈ 0.0 atol=1e-4
    
    B = StrojniSoucasti.bdu2b((5, 5), 7, 45*pi/180)
    @test B[1] ≈ 9.9497 atol=1e-4
    @test B[2] ≈ 9.9497 atol=1e-4

end