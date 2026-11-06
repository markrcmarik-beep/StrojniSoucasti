# ver: 2026-10-15
using Test
using StrojniSoucasti

@testset "materialy" begin

    mat = materialy("S235")

    #@test mat isa StrojniSoucasti.MaterialOcel
    #@test mat.name == "S235"

    mat = materialy("S235JR+N")

    #@test mat isa StrojniSoucasti.MaterialOcel
    #@test mat.name == "S235JR+N"

    mat = materialy("11 373")

    @test mat.name == "11373"
    @test mat.standard == "ČSN 41 1373"
    @test mat.Re == 250
    @test mat.Re_unit == "MPa"
    @test mat.thickness_max == 0
    @test mat.Rm_min_unit == "MPa"
    @test mat.Rm_max_unit == "MPa"
    @test mat.A == 7
    @test mat.A_unit == "%"
    @test mat.KV_unit == "J"
    @test mat.T_KV_unit == "°C"
    @test mat.svaritelnost == "zaručená"
    @test mat.thickness_max_unit == "mm"
    @test mat.E_unit == "GPa"
    @test mat.G_unit == "GPa"
    @test mat.ny_unit == "-"
    @test mat.rho == 7850
    @test mat.rho_unit == "kg/m^3"

    mat = materialy("42 3001")

    @test mat isa StrojniSoucasti.MaterialNezelezneKovy
    @test mat.name == "423001"
    @test mat.standard == ""
    @test mat.Rp0_2 == 50
    @test mat.Rp0_2_unit == "MPa"
    @test mat.Rm_min == 200
    @test mat.Rm_min_unit == "MPa"
    @test mat.Rm_max == 280
    @test mat.Rm_max_unit == "MPa"
    @test mat.A == 30
    @test mat.A_unit == "%"
    @test mat.E == 115
    @test mat.E_unit == "GPa"
    @test mat.G == 42
    @test mat.G_unit == "GPa"
    @test mat.ny == 0.35
    @test mat.ny_unit == "-"
    @test mat.rho == 8930
    @test mat.rho_unit == "kg/m^3"

    mat = materialy("42 2420")

    @test mat isa StrojniSoucasti.MaterialLitina
    @test mat.name == "422420"
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

    mat = materialy("NBR70")

    @test mat isa StrojniSoucasti.MaterialPryz
    @test mat.name == "NBR70"
    @test mat.hardness == 70
    @test mat.hardness_unit == "ShA"
    @test mat.E == 0.00552
    @test mat.E_unit == "GPa"
    @test mat.rho == 1300
    @test mat.rho_unit == "kg/m^3"
    mat = materialy("nonexistent_material")
    @test mat === nothing

end

nothing
