# ver: 2026-10-22
using Test
using StrojniSoucasti
using SQLite

@testset "materialyDIN" begin
    db_path = joinpath(@__DIR__, "..", "..", "src", "materialy", "materialy.db")
    db = SQLite.DB(db_path)

    @testset "ocel" begin
        ocel = StrojniSoucasti.materialyDIN(db, "C45")

        @test ocel isa Dict{String,Any}
        @test ocel["name_DIN"] == "C45"
        @test ocel["VVnormy"] == "DIN"
        @test ocel["VVdruh"] == "ocel"
        @test ocel["druh"] == "nelegovaná zušlechťovací ocel"
    end

    @testset "litina" begin
        litina = StrojniSoucasti.materialyDIN(db, "GG25")

        @test litina isa Dict{String,Any}
        @test litina["name_DIN"] == "GG25"
        @test litina["VVnormy"] == "DIN"
        @test litina["VVdruh"] == "litina"
        @test litina["druh"] == "šedá litina s lupínkovým grafitem"
    end

    @testset "nenalezený materiál" begin
        @test StrojniSoucasti.materialyDIN(db, "neexistujici_DIN") === nothing
    end

    SQLite.close(db)
end

nothing
