# ver: 2026-10-10
using Test
using StrojniSoucasti
using SQLite

@testset "materialyCSN" begin
    
    db_path = joinpath(@__DIR__, "..", "..", "src", "materialy", "materialy.db")
    db = SQLite.DB(db_path) # Načte databázi
    @testset "ocel" begin
        
    mat11 = StrojniSoucasti.materialyCSN(db, "11 373") # konstrukční ocel
    # names
    @test mat11["name"] isa AbstractString # název materiálu
    @test mat11["name_ISO"] isa AbstractString
    @test mat11["znacka_EN"] isa AbstractString
    @test mat11["cislo_EN"] isa AbstractString
    @test mat11["name_CSN"] isa AbstractString
    @test mat11["name_DIN"] isa AbstractString
    @test mat11["VVnormy"] isa AbstractString
    @test mat11["norma_CSN"] isa AbstractString
    @test mat11["druh"] isa AbstractString
    # namesOcel
    @test mat11["stav"] isa AbstractString
    @test mat11["zpracovani"] isa AbstractString
    @test mat11["vlastnosti"] isa AbstractString
    @test mat11["pouziti"] isa AbstractString
    @test mat11["svaritelnost"] isa AbstractString


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
    @test mat11["ny_unit"] == "1"
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
    @test mat11["tvrdost_HB"] isa Float64 || ismissing(mat11["tvrdost_HB"])
    @test mat11["tvrdost_HB_unit"] == "HB"
    @test mat11["tvrdost_HV"] isa Float64 || ismissing(mat11["tvrdost_HV"])
    @test mat11["tvrdost_HV_unit"] == "HV"
    @test mat11["tvrdost_HRC"] isa Float64 || ismissing(mat11["tvrdost_HRC"])
    @test mat11["tvrdost_HRC_unit"] == "HRC"
    @test mat11["Rp0_2"] isa Float64 || ismissing(mat11["Rp0_2"])
    @test mat11["Rp0_2_unit"] == "MPa"
    @test mat11["Rp0_1"] isa Float64 || ismissing(mat11["Rp0_1"])
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
    #@test mat14["name"] ==
    @test mat14["name"] isa AbstractString
    @test mat14["name_ISO"] isa AbstractString
    @test mat14["znacka_EN"] == ""
    @test mat14["cislo_EN"] == ""
    @test mat14["name_CSN"] == "11373.1 žíháno"
    @test mat14["name_DIN"] == ""
    @test mat14["VVnormy"] == "ČSN"
    @test mat14["norma_CSN"] == "ČSN 41 1373"
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
    @test mat14["ny_unit"] == "1"
    @test mat14["rho"] == 7850
    @test mat14["rho_unit"] == "kg/m^3"

    mat15a = StrojniSoucasti.materialyCSN(db, "11 373 žíháno, z jedné strany broušeno")
    @test mat15a === nothing
    mat15b = StrojniSoucasti.materialyCSN(db, "11 373.1 kaleno")
    @test mat15b === nothing

    mat16 = StrojniSoucasti.materialyCSN(db, "11 373.1 žíháno, broušeno")
    @test isequal(mat16, mat14)

    mat17 = StrojniSoucasti.materialyCSN(db, "14 220.4")
    @test mat17["tvrdost_HV"] == 200
    @test mat17["tvrdost_HV_unit"] == "HV"

    end # konec ocel

    mat21 = StrojniSoucasti.materialyCSN(db, "42 3001")
    @test mat21["name_CSN"] == "423001"
    #@test mat21["VVnormy"] == "ČSN"
    @test mat21["Rp0_2"] == 50
    @test mat21["Rp0_2_unit"] == "MPa"
    #@test mat21["Rm_min"] == 250
    #@test mat21["Rm_min_unit"] == "MPa"
    #@test mat21["Rm_max"] == 300
    #@test mat21["Rm_max_unit"] == "MPa"
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
    @test mat31["name_ISO"] == ""
    @test mat31["znacka_EN"] == "EN-GJL-200"
    @test mat31["cislo_EN"] == "5.1300"
    @test mat31["name_CSN"] == "422420"
    @test mat31["name_DIN"] == ""
    #@test mat31["VVnormy"] == "ČSN"
    @test mat31["norma_CSN"] == "ČSN 42 2420"
    @test mat31["druh"] == "šedá litina"
    @test mat31["Rm"] == 200
    @test mat31["Rm_unit"] == "MPa"
    @test mat31["Rm_tlak"] == 800
    @test mat31["Rm_tlak_unit"] == "MPa"
    @test mat31["A"] == 0.5
    @test mat31["A_unit"] == "%"
    @test mat31["tvrdost_HB_min"] == 170
    @test mat31["tvrdost_HB_min_unit"] == "HB"
    @test mat31["tvrdost_HB_max"] == 230
    @test mat31["tvrdost_HB_max_unit"] == "HB"
    @test mat31["E"] == 110
    @test mat31["E_unit"] == "GPa"
    @test mat31["G"] == 44
    @test mat31["G_unit"] == "GPa"
    @test mat31["ny"] == 0.27
    @test mat31["ny_unit"] == "1"
    @test mat31["rho"] == 7200
    @test mat31["rho_unit"] == "kg/m^3"

    mat31b = StrojniSoucasti.materialyCSN(db, "42 2429") # neexistuje
    @test mat31b === nothing

    mat41 = StrojniSoucasti.materialyCSN(db, "nonexistent_material")
    @test mat41 === nothing

    end # konec litina

    @testset "neželezné kovy" begin
        mat_kov = StrojniSoucasti.materialyCSN(db, "42 3001")
        @test mat_kov["name_CSN"] == "423001"
        @test mat_kov["name_ISO"] == "Cu-ETP"
        @test mat_kov["znacka_EN"] == "CW004A"
        @test mat_kov["druh"] == "Elektrolytická měď"
        @test mat_kov["Rp0_2"] == 50
        @test mat_kov["Rp0_2_unit"] == "MPa"
        @test mat_kov["Rm_min"] == 200
        @test mat_kov["Rm_min_unit"] == "MPa"
        @test mat_kov["Rm_max"] == 280
        @test mat_kov["Rm_max_unit"] == "MPa"
        @test mat_kov["A"] == 30
        @test mat_kov["A_unit"] == "%"
        @test mat_kov["E"] == 115
        @test mat_kov["E_unit"] == "GPa"
        @test mat_kov["G"] == 42
        @test mat_kov["G_unit"] == "GPa"
        @test mat_kov["ny"] == 0.35
        @test mat_kov["ny_unit"] == "1"
        @test mat_kov["rho"] == 8930
        @test mat_kov["rho_unit"] == "kg/m^3"
        @test mat_kov["stav"] == "žíhaný; mechanické hodnoty orientační"
    end # konec neželezné kovy

    SQLite.close(db)
end # konec materialyCSN

nothing
