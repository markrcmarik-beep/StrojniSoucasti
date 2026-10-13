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