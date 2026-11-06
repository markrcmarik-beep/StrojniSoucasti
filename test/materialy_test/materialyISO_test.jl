# ver: 2026-10-13
using Test
using StrojniSoucasti
using SQLite

@testset "materialyISO" begin
    db_path = joinpath(@__DIR__, "..", "..", "src", "materialy", "materialy.db")
    db = SQLite.DB(db_path)

    @testset "neželezné kovy podle názvu ISO" begin
        kov = StrojniSoucasti.materialyISO(db, "Cu-ETP")

        @test kov isa Dict{String,Any}
        @test kov["name_ISO"] == "Cu-ETP"
        @test kov["druh"] == "Elektrolytická měď"
        @test kov["rho"] == 8930
        @test kov["rho_unit"] == "kg/m^3"
    end

    @testset "plasty podle názvu ISO" begin
        plast = StrojniSoucasti.materialyISO(db, "PA 6-C/Oil")

        @test plast isa Dict{String,Any}
        @test plast["name_ISO"] == "PA 6-C/Oil"
        @test plast["druh"] == "Polyamid 6 odlévaný, modifikovaný olejem"
    end

    @testset "nenalezený materiál" begin
        @test StrojniSoucasti.materialyISO(db, "nenalezeny_ISO") === nothing
    end

    SQLite.close(db)
end

nothing