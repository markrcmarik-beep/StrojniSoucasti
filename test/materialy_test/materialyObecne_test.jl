# ver: 2026-10-13
using Test
using StrojniSoucasti
using SQLite

@testset "materialyObecne" begin
    db_path = joinpath(@__DIR__, "..", "..", "src", "materialy", "materialy.db")
    db = SQLite.DB(db_path)

    @testset "nalezení materiálu podle názvu" begin
        pryz = StrojniSoucasti.materialyObecne(db, "NBR70")
        @test pryz isa Dict{String,Any}
        @test pryz["druh"] == "NBR"

        kov = StrojniSoucasti.materialyObecne(db, "CuCr")
        @test kov isa Dict{String,Any}
        @test kov["druh"] == "Slitina mědi"
    end

    @testset "nenalezený materiál" begin
        @test StrojniSoucasti.materialyObecne(db, "neexistujici_material") === nothing
    end

    SQLite.close(db)
end

nothing