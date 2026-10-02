# ver: 2026-09-28
using Test
using StrojniSoucasti
using SQLite

@testset "materialyCSN" begin
    
    db_path = joinpath(StrojniSoucasti.cesta_materialy, "materialy.db")
    db = SQLite.DB(db_path) # Načte databázi závitů, pokud ještě nebyla načtena
    @testset "ocel" begin
        
    mat11 = StrojniSoucasti.materialyCSN(db, "11 373") # konstrukční ocel
    @test mat11["name_CSN"] == "11373"
    @test mat11["znacka_EN"] == "S235JRG1"
    @test mat11["cislo_EN"] == "1.0036"
    @test mat11["standard"] == "ČSN"
    @test mat11["norma"] == "ČSN 41 1373"
    @test mat11["druh"] == "konstrukční ocel"
    @test mat11["Re"] == 250
    @test mat11["Re_unit"] == "MPa"
    @test mat11["Re_min"] == 250
    @test mat11["Re_min_unit"] == "MPa"
    @test mat11["Rm_min"] == 340
    @test mat11["Rm_min_unit"] == "MPa"
    @test mat11["Rm_max"] == 440
    @test mat11["Rm_max_unit"] == "MPa"
    @test mat11["A"] == 7
    @test mat11["A_unit"] == "%"
    @test mat11["KV"] == 27
    @test mat11["KV_unit"] == "J"
    @test mat11["T_KV"] == 20
    @test mat11["T_KV_unit"] == "°C"
    @test mat11["svaritelnost"] == "zaručená"
    @test mat11["E"] == 210
    @test mat11["E_unit"] == "GPa"
    @test mat11["G"] == 81
    @test mat11["G_unit"] == "GPa"
    @test mat11["alfa"] == 1.2e-5
    @test mat11["alfa_unit"] == "1/K"
    @test mat11["ny"] == 0.3
    @test mat11["ny_unit"] == "-"
    @test mat11["rho"] == 7850
    @test mat11["rho_unit"] == "kg/m^3"
    @test mat11["stav"] == "tepelně nezpracováno"
    @test mat11["zpracovani"] == ""
    @test !isempty(mat11["vlastnosti"])
    @test !isempty(mat11["pouziti"])
    @test mat11["obrobitelnost"] == "dobrá"
    @test mat11["k_cementovani"] == "ne"
    @test mat11["k_nitridovani"] == "ne"
    @test mat11["k_zuslechtovani"] == "ne"
    @test mat11["k_povrchovemu_kaleni"] == "ne"
    @test mat11["korozivzdorna"] == "ne"
    @test mat11["obvykla_jakost"] == "ano"
    @test mat11["tvrdost_HB"] == 225
    @test mat11["tvrdost_HB_unit"] == "HB"
    @test mat11["tvrdost_HV"] == 0.0
    @test mat11["tvrdost_HV_unit"] == "HV"
    @test mat11["tvrdost_HRC"] == 0.0
    @test mat11["tvrdost_HRC_unit"] == "HRC"
    @test mat11["Rp0_2"] == 0.0
    @test mat11["Rp0_2_unit"] == "MPa"
    @test mat11["Rp0_1"] == 0.0
    @test mat11["Rp0_1_unit"] == "MPa"
    @test any(rozsah -> rozsah.rozsah_od_mm == 16 &&
        rozsah.rozsah_do_mm == 40 && rozsah.Re_min_MPa == 240,
        mat11["Re_rozsahy"])

    mat11_1 = StrojniSoucasti.materialyCSN(db, "11 352") # neexistuje
    @test mat11_1 === nothing

    mat12 = StrojniSoucasti.materialyCSN(db, "11 373.1")
    @test mat12 === nothing

    mat13 = StrojniSoucasti.materialyCSN(db, "11 373 žíhaný")
    @test mat13 === nothing

    mat14 = StrojniSoucasti.materialyCSN(db, "11 373.1 žíháno") # konstrukční ocel žíhaná
    @test mat14["name_CSN"] == "11373.1 žíháno"
    @test mat14["standard"] == "ČSN"
    @test mat14["norma"] == "ČSN 41 1373"
    @test mat14["Re"] == 220
    @test mat14["Re_unit"] == "MPa"
    @test mat14["Re_max"] == 280
    @test mat14["Re_max_unit"] == "MPa"
    @test mat14["Rm_min"] == 350
    @test mat14["Rm_min_unit"] == "MPa"
    @test mat14["Rm_max"] == 510
    @test mat14["Rm_max_unit"] == "MPa"
    @test mat14["A"] == 20
    @test mat14["A_unit"] == "%"
    @test mat14["KV"] == 35
    @test mat14["KV_unit"] == "J"
    @test mat14["T_KV"] == 20
    @test mat14["T_KV_unit"] == "°C"
    @test mat14["svaritelnost"] == "zaručená"
    @test mat14["E"] == 210
    @test mat14["E_unit"] == "GPa"
    @test mat14["G"] == 81
    @test mat14["G_unit"] == "GPa"
    @test mat14["ny"] == 0.3
    @test mat14["ny_unit"] == "-"
    @test mat14["rho"] == 7850
    @test mat14["rho_unit"] == "kg/m^3"

    mat15a = StrojniSoucasti.materialyCSN(db, "11 373 žíháno, z jedné strany broušeno")
    @test mat15a === nothing
    mat15b = StrojniSoucasti.materialyCSN(db, "11 373.1 kaleno")
    @test mat15b === nothing

    mat16 = StrojniSoucasti.materialyCSN(db, "11 373.1 žíháno, broušeno")
    @test mat16 == mat14

    mat17 = StrojniSoucasti.materialyCSN(db, "14 220.4")
    @test mat17["tvrdost_HV"] == 200
    @test mat17["tvrdost_HV_unit"] == "HV"

    end # konec ocel

    ##mat21 = StrojniSoucasti.materialyCSN(db, "42 3001")
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

    @testset "litina" begin

    mat31 = StrojniSoucasti.materialyCSN(db, "42 2420") # šedá litina
    #@test mat31 isa StrojniSoucasti.MaterialLitina
    @test mat31["name_CSN"] == "422420"
    @test mat31["standard"] == "ČSN"
    @test mat31["norma"] == "ČSN 42 2420"
    @test mat31["druh"] == "šedá litina"
    @test mat31["Rm_tah"] == 200
    @test mat31["Rm_tah_unit"] == "MPa"
    @test mat31["Rm_tlak"] == 800
    @test mat31["Rm_tlak_unit"] == "MPa"
    @test mat31["A"] == 0.5
    @test mat31["A_unit"] == "%"
    @test mat31["HB_min"] == 170
    @test mat31["HB_min_unit"] == "HB"
    @test mat31["HB_max"] == 230
    @test mat31["HB_max_unit"] == "HB"
    @test mat31["E"] == 110
    @test mat31["E_unit"] == "GPa"
    @test mat31["G"] == 44
    @test mat31["G_unit"] == "GPa"
    @test mat31["ny"] == 0.27
    @test mat31["ny_unit"] == "-"
    @test mat31["rho"] == 7200
    @test mat31["rho_unit"] == "kg/m^3"

    mat31b = StrojniSoucasti.materialyCSN(db, "42 2429") # neexistuje
    @test mat31b === nothing

    mat41 = StrojniSoucasti.materialyCSN(db, "nonexistent_material")
    @test mat41 === nothing

    end # konec litina
    SQLite.close(db)
end # konec materialyCSN

nothing
