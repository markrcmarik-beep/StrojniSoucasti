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
    @test mat.standard == "ČSN 41 1373"
    @test mat.Re == 250
    @test mat.weldable == true
    @test mat.rho == 7850

    mat = materialy("42 3001")

    @test mat.name == "42 3001"
    @test mat.standard == "ČSN"
    @test mat.Re == 200
    @test mat.Rm_min == 250
    @test mat.Rm_max == 300
    @test mat.A == 20
    @test mat.E == 110
    @test mat.G == 42
    @test mat.ny == 0.34
    @test mat.rho == 8930

    mat = materialy("42 2420")

    @test mat isa StrojniSoucasti.MaterialLitina
    @test mat.name == "42 2420"
    @test mat.standard == "ČSN 42 2420"
    @test mat.druh == "šedá litina"
    @test mat.Rm_tah == 200
    @test mat.Rm_tlak == 800
    @test mat.A == 0.5
    @test mat.HB_min == 170
    @test mat.HB_max == 230
    @test mat.E == 110
    @test mat.G == 44
    @test mat.ny == 0.27
    @test mat.rho == 7200

    mat = materialy("nonexistent_material")
    @test mat === nothing

end
