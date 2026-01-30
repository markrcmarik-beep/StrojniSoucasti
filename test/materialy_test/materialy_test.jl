# ver: 2026-01-18
using Test
using StrojniSoucasti

@testset "materialy" begin

    mat = materialy("S235")

    @test mat.name == "S235"
    @test mat.standard == "EN 10025-2"
    @test mat.Re == 235
    @test mat.Rm_min == 360
    @test mat.Rm_max == 510
    @test mat.A == 26
    @test mat.KV == 27
    @test mat.T_KV == 20
    @test mat.weldable == true
    @test mat.thickness_max == 200
    @test mat.E == 210
    @test mat.G == 81
    @test mat.ny == 0.3
    @test mat.rho == 7850

    mat = materialy("S235JR+N")
    
    @test mat.name == "S235JR+N"
    @test mat.standard == "EN 10025-2"
    @test mat.Re == 235
    @test mat.weldable == true
    @test mat.thickness_max == 200
    @test mat.E == 210
    @test mat.rho == 7850

    mat = materialy("11 373")

    @test mat.name == "11 373"
    @test mat.standard == "ČSN"
    @test mat.Re == 250
    @test mat.weldable == true
    @test mat.rho == 7850

    mat = materialy("nonexistent_material")
    @test mat === nothing

end
