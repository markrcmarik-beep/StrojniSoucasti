# ver: 2026-09-01
using Test
using StrojniSoucasti

@testset "materialyCSN" begin

    mat11 = StrojniSoucasti.materialyCSN("11 373")
    @test mat11.name == "11 373"
    @test mat11.standard == "ČSN 41 1373"
    @test mat11.Re == 250
    @test mat11.Re_unit == "MPa"
    @test mat11.Rm_min_unit == "MPa"
    @test mat11.Rm_max_unit == "MPa"
    @test mat11.A_unit == "%"
    @test mat11.KV_unit == "J"
    @test mat11.T_KV_unit == "°C"
    @test mat11.weldable == true
    @test mat11.thickness_max_unit == "mm"
    @test mat11.E_unit == "GPa"
    @test mat11.G_unit == "GPa"
    @test mat11.ny_unit == "-"
    @test mat11.rho == 7850
    @test mat11.rho_unit == "kg/m^3"

    mat12 = StrojniSoucasti.materialyCSN("11 373.1")
    mat13 = StrojniSoucasti.materialyCSN("11 373 žíhaný")
    mat14 = StrojniSoucasti.materialyCSN("11 373 žíhaný, broušeno")
    mat15 = StrojniSoucasti.materialyCSN("11 373.1 žíhaný, broušeno")

    ##mat21 = StrojniSoucasti.materialyCSN("42 3001")
    #@test mat21.name == "42 3001"
    #@test mat21.standard == "ČSN 42 3001"
    #@test mat21.Re == 200
    #@test mat21.Re_unit == "MPa"
    #@test mat21.Rm_min == 250
    #@test mat21.Rm_min_unit == "MPa"
    #@test mat21.Rm_max == 300
    #@test mat21.Rm_max_unit == "MPa"
    #@test mat21.A == 20
    #@test mat21.A_unit == "%"
    #@test mat21.E == 110
    #@test mat21.E_unit == "GPa"
    #@test mat21.G == 42
    #@test mat21.G_unit == "GPa"
    #@test mat21.ny == 0.34
    #@test mat21.ny_unit == "-"
    #@test mat21.rho == 8930
    #@test mat21.rho_unit == "kg/m^3"

    #mat31 = StrojniSoucasti.materialyCSN("42 2420")
    #@test mat31 isa StrojniSoucasti.MaterialLitina
    #@test mat31.name == "42 2420"
    #@test mat31.standard == "ČSN 42 2420"
    #@test mat31.druh == "šedá litina"
    #@test mat31.Rm_tah == 200
    #@test mat31.Rm_tah_unit == "MPa"
    #@test mat31.Rm_tlak == 800
    #@test mat31.Rm_tlak_unit == "MPa"
    #@test mat31.A == 0.5
    #@test mat31.A_unit == "%"
    #@test mat31.HB_min == 170
    #@test mat31.HB_min_unit == "HB"
    #@test mat31.HB_max == 230
    #@test mat31.HB_max_unit == "HB"
    #@test mat31.E == 110
    #@test mat31.E_unit == "GPa"
    #@test mat31.G == 44
    #@test mat31.G_unit == "GPa"
    #@test mat31.ny == 0.27
    #@test mat31.ny_unit == "-"
    #@test mat31.rho == 7200
    #@test mat31.rho_unit == "kg/m^3"

    #mat41 = StrojniSoucasti.materialyCSN("nonexistent_material")
    #@test mat41 === nothing

end

nothing
