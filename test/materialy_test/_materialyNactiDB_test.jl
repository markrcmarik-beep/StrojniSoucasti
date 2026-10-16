# ver: 2026-10-12
using Test
using StrojniSoucasti
using SQLite

@testset "_materialyNactiDB" begin
    db_path = joinpath(@__DIR__, "..", "..", "src", "materialy", "materialy.db")
    db = SQLite.DB(db_path)

    @testset "ocel" begin
        ocel = StrojniSoucasti._materialyNactiDB(
            db, "name_CSN", "11373", "ČSN", "ocel")

        @test ocel isa Dict{String,Any}
    # names
    @test ocel["name"] isa AbstractString # název materiálu
    @test ocel["name_ISO"] isa AbstractString
    @test ocel["znacka_EN"] isa AbstractString
    @test ocel["cislo_EN"] isa AbstractString
    @test ocel["name_CSN"] isa AbstractString
    @test ocel["name_DIN"] isa AbstractString
    @test ocel["standard"] isa AbstractString
    @test ocel["norma_CSN"] isa AbstractString
    @test ocel["druh"] isa AbstractString
    # namesOcel
    @test ocel["stav"] isa AbstractString
    @test ocel["zpracovani"] isa AbstractString
    @test ocel["vlastnosti"] isa AbstractString
    @test ocel["pouziti"] isa AbstractString
    @test ocel["svaritelnost"] isa AbstractString
    @test ocel["obrobitelnost"] isa AbstractString
    @test ocel["k_cementovani"] isa AbstractString
    @test ocel["k_nitridovani"] isa AbstractString
    @test ocel["k_zuslechtovani"] isa AbstractString
    @test ocel["k_povrchovemu_kaleni"] isa AbstractString
    @test ocel["korozivzdorna"] isa AbstractString
    @test ocel["obvykla_jakost"] isa AbstractString
    # veliciny
    @test ocel["Re"] isa Float64 || ismissing(ocel["Re"])
    @test ocel["Re_unit"] isa AbstractString
    @test ocel["Re_min"] isa Float64 || ismissing(ocel["Re_min"])
    @test ocel["Re_min_unit"] isa AbstractString
    @test ocel["Rp0_2"] isa Float64 || ismissing(ocel["Rp0_2"])
    @test ocel["Rp0_2_unit"] isa AbstractString
    @test ocel["Rm_min"] isa Float64 || ismissing(ocel["Rm_min"])
    @test ocel["Rm_max"] isa Float64 || ismissing(ocel["Rm_max"])

    @test ocel["E"] isa Float64 || ismissing(ocel["E"])
    @test ocel["E_unit"] isa AbstractString

    @test ocel["Re_rozsahy"] isa AbstractVector{<:NamedTuple}

        @test ocel["name_CSN"] == "11373"
        @test ocel["standard"] == "ČSN"
        @test ocel["Re"] == 250
        @test ocel["Re_unit"] == "MPa"
        @test ocel["E"] == 210
        @test ocel["E_unit"] == "GPa"
        @test any(rozsah -> rozsah.rozsah_od_mm == 16 &&
            rozsah.rozsah_do_mm == 40 && rozsah.Re_min_MPa == 240,
            ocel["Re_rozsahy"])
    end

        @testset "litina" begin
            litina = StrojniSoucasti._materialyNactiDB(
                db, "name_CSN", "422420", "ČSN", "litina")

            @test litina isa Dict{String,Any}
            @test litina["name_CSN"] == "422420"
            @test litina["druh"] == "šedá litina"
            @test litina["Rm_tah"] == 200
            @test litina["Rm_tah_unit"] == "MPa"
            @test litina["rho"] == 7200
            @test litina["rho_unit"] == "kg/m^3"
        end

        @testset "neželezné kovy" begin
            kov = StrojniSoucasti._materialyNactiDB(
                db, "name_CSN", "423001", "ČSN", "nezelezne kovy")

            @test kov isa Dict{String,Any}
            @test kov["name_CSN"] == "423001"
            @test kov["druh"] == "Elektrolytická měď"
            @test kov["Rp0_2"] == 50
            @test kov["Rp0_2_unit"] == "MPa"
            @test kov["rho"] == 8930
            @test kov["rho_unit"] == "kg/m^3"
        end

        @testset "nenalezený a nepodporovaný materiál" begin
            @test StrojniSoucasti._materialyNactiDB(
                db, "name_CSN", "neexistuje", "ČSN", "ocel") === nothing
            @test_throws ErrorException StrojniSoucasti._materialyNactiDB(
                db, "name_CSN", "11373", "ČSN", "nepodporovaný typ")
        end

        SQLite.close(db)

end

nothing