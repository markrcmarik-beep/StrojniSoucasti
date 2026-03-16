# ver: 2026-01-18
using Test
using StrojniSoucasti

@testset "materialy" begin

    mat = materialy("S235")

    @test mat.name == "S235"
    @test mat.standard == "EN 10025-2"
    @test mat.Re == 235
    @test mat.Re_unit == "MPa"
    @test mat.Rm_min == 360
    @test mat.Rm_min_unit == "MPa"
    @test mat.Rm_max == 510
    @test mat.Rm_max_unit == "MPa"
    @test mat.A == 26
    @test mat.A_unit == "%"
    @test mat.KV == 27
    @test mat.KV_unit == "J"
    @test mat.T_KV == 20
    @test mat.T_KV_unit == "°C"
    @test mat.weldable == true
    @test mat.thickness_max == 200
    @test mat.thickness_max_unit == "mm"
    @test mat.E == 210
    @test mat.E_unit == "GPa"
    @test mat.G == 81
    @test mat.G_unit == "GPa"
    @test mat.ny == 0.3
    @test mat.ny_unit == "-"
    @test mat.rho == 7850
    @test mat.rho_unit == "kg/m^3"

    mat = materialy("S235JR+N")
    
    @test mat.name == "S235JR+N"
    @test mat.standard == "EN 10025-2"
    @test mat.Re == 235
    @test mat.Re_unit == "MPa"
    @test mat.Rm_min_unit == "MPa"
    @test mat.Rm_max_unit == "MPa"
    @test mat.A_unit == "%"
    @test mat.KV_unit == "J"
    @test mat.T_KV_unit == "°C"
    @test mat.weldable == true
    @test mat.thickness_max == 200
    @test mat.thickness_max_unit == "mm"
    @test mat.E == 210
    @test mat.E_unit == "GPa"
    @test mat.rho == 7850
    @test mat.rho_unit == "kg/m^3"

    mat = materialy("11 373")

    @test mat.name == "11 373"
    @test mat.standard == "ČSN 41 1373"
    @test mat.Re == 250
    @test mat.Re_unit == "MPa"
    @test mat.Rm_min_unit == "MPa"
    @test mat.Rm_max_unit == "MPa"
    @test mat.A_unit == "%"
    @test mat.KV_unit == "J"
    @test mat.T_KV_unit == "°C"
    @test mat.weldable == true
    @test mat.thickness_max_unit == "mm"
    @test mat.E_unit == "GPa"
    @test mat.G_unit == "GPa"
    @test mat.ny_unit == "-"
    @test mat.rho == 7850
    @test mat.rho_unit == "kg/m^3"

    mat = materialy("42 3001")

    @test mat.name == "42 3001"
    @test mat.standard == "ČSN"
    @test mat.Re == 200
    @test mat.Re_unit == "MPa"
    @test mat.Rm_min == 250
    @test mat.Rm_min_unit == "MPa"
    @test mat.Rm_max == 300
    @test mat.Rm_max_unit == "MPa"
    @test mat.A == 20
    @test mat.A_unit == "%"
    @test mat.E == 110
    @test mat.E_unit == "GPa"
    @test mat.G == 42
    @test mat.G_unit == "GPa"
    @test mat.ny == 0.34
    @test mat.ny_unit == "-"
    @test mat.rho == 8930
    @test mat.rho_unit == "kg/m^3"

    mat = materialy("42 2420")

    @test mat isa StrojniSoucasti.MaterialLitina
    @test mat.name == "42 2420"
    @test mat.standard == "ČSN 42 2420"
    @test mat.druh == "šedá litina"
    @test mat.Rm_tah == 200
    @test mat.Rm_tah_unit == "MPa"
    @test mat.Rm_tlak == 800
    @test mat.Rm_tlak_unit == "MPa"
    @test mat.A == 0.5
    @test mat.A_unit == "%"
    @test mat.HB_min == 170
    @test mat.HB_min_unit == "HB"
    @test mat.HB_max == 230
    @test mat.HB_max_unit == "HB"
    @test mat.E == 110
    @test mat.E_unit == "GPa"
    @test mat.G == 44
    @test mat.G_unit == "GPa"
    @test mat.ny == 0.27
    @test mat.ny_unit == "-"
    @test mat.rho == 7200
    @test mat.rho_unit == "kg/m^3"

    mat = materialy("nonexistent_material")
    @test mat === nothing

end
