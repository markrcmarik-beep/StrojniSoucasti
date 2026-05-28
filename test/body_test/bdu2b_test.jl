# ver: 2026-04-22
# Test script for bdu2b.jl

using StrojniSoucasti, Unitful, Test

@testset "bdu2b" begin

    B = StrojniSoucasti.bdu2b((10, 20), 5, 30*pi/180)
    @test isa(B, Tuple)
    @test length(B) == 2
    @test B[1] ≈ 14.33 atol=1e-3
    @test B[2] ≈ 22.5 atol=1e-3

    B = StrojniSoucasti.bdu2b((1, 0.5), 10, 90*pi/180)
    @test B[1] ≈ 1 atol=1e-4
    @test B[2] ≈ 10.5 atol=1e-4
    
    B = StrojniSoucasti.bdu2b((5, 5), 7, 45*pi/180)
    @test B[1] ≈ 9.9497 atol=1e-4
    @test B[2] ≈ 9.9497 atol=1e-4

    B = StrojniSoucasti.bdu2b((15, 25), 3, 120*pi/180)
    @test B[1] ≈ 13.5 atol=1e-2
    @test B[2] ≈ 27.6 atol=1e-2

    B = StrojniSoucasti.bdu2b((15, 25), 7, 180*pi/180)
    @test B[1] ≈ 8 atol=1e-2
    @test B[2] ≈ 25 atol=1e-2

    B = StrojniSoucasti.bdu2b((10, 5), 10, 210*pi/180)
    @test B[1] ≈ 1.34 atol=1e-2
    @test B[2] ≈ 0 atol=1e-2

    B = StrojniSoucasti.bdu2b((11, 12), 10, 235*pi/180)
    @test B[1] ≈ 5.26 atol=1e-2
    @test B[2] ≈ 3.81 atol=1e-2

    B = StrojniSoucasti.bdu2b((10, 6), 10, 270*pi/180)
    @test B[1] ≈ 10 atol=1e-2
    @test B[2] ≈ -4 atol=1e-2

    B = StrojniSoucasti.bdu2b((8, 4), 10, 300*pi/180)
    @test B[1] ≈ 13 atol=1e-2
    @test B[2] ≈ -4.66 atol=1e-2

    B = StrojniSoucasti.bdu2b((5, 5), 10, 360*pi/180)
    @test B[1] ≈ 15 atol=1e-2
    @test B[2] ≈ 5 atol=1e-2

    B = StrojniSoucasti.bdu2b((10, 20), 5, 380*pi/180)
    @test B[1] ≈ 14.7 atol=1e-2
    @test B[2] ≈ 21.71 atol=1e-2

    B = StrojniSoucasti.bdu2b((10, 20), 5, -30*pi/180)
    @test B[1] ≈ 14.33 atol=1e-3
    @test B[2] ≈ 17.5 atol=1e-3

    B = StrojniSoucasti.bdu2b((10, 20), -5, 330*pi/180)
    @test B[1] ≈ 5.67 atol=1e-2
    @test B[2] ≈ 22.5 atol=1e-2

    B = StrojniSoucasti.bdu2b((10, -20), 5, 240*pi/180)
    @test B[1] ≈ 7.5 atol=1e-2
    @test B[2] ≈ -24.33 atol=1e-2

    B = StrojniSoucasti.bdu2b((-10, 20), -5, 240*pi/180)
    @test B[1] ≈ -7.5 atol=1e-2
    @test B[2] ≈ 24.33 atol=1e-2

end
