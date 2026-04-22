# ver: 2026-04-22
# Test script for bux2b.jl

using StrojniSoucasti, Unitful, Test

@testset "bux2b" begin

    B = StrojniSoucasti.bux2b((10, 20), 30*pi/180, 5)
    @test isa(B, Tuple)
    @test length(B) == 2
    @test B[1] ≈ 15 atol=1e-2
    @test B[2] ≈ 22.89 atol=1e-2

    B = StrojniSoucasti.bux2b((1, 0.5), 90*pi/180, 10)
    @test B === nothing

    B = StrojniSoucasti.bux2b((10, 5), 45*pi/180, -10)
    @test B[1] ≈ 0 atol=1e-2
    @test B[2] ≈ -5 atol=1e-2

    B = StrojniSoucasti.bux2b((15, 25), 0*pi/180, 3)
    @test B[1] ≈ 18 atol=1e-2
    @test B[2] ≈ 25 atol=1e-2

    B = StrojniSoucasti.bux2b((15, 25), 120*pi/180, 3)
    @test B[1] ≈ 18 atol=1e-2
    @test B[2] ≈ 19.8 atol=1e-2

    B = StrojniSoucasti.bux2b((5, 5), 120*pi/180, -3)
    @test B[1] ≈ 2 atol=1e-2
    @test B[2] ≈ 10.19 atol=1e-2

    B = StrojniSoucasti.bux2b((15, 25), 180*pi/180, 7)
    @test B[1] ≈ 22 atol=1e-2
    @test B[2] ≈ 25 atol=1e-2

    B = StrojniSoucasti.bux2b((10, 5), 210*pi/180, 10)
    @test B[1] ≈ 20 atol=1e-2
    @test B[2] ≈ 10.77 atol=1e-2

    B = StrojniSoucasti.bux2b((11, 12), 270*pi/180, 10)
    @test B === nothing

    B = StrojniSoucasti.bux2b((8, 4), 300*pi/180, 10)
    @test B[1] ≈ 18 atol=1e-2
    @test B[2] ≈ -13.32 atol=1e-2

end
