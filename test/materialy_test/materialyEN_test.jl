# ver: 2026-10-17
using Test
using StrojniSoucasti
using SQLite

@testset "materialyEN" begin
    db_path = joinpath(@__DIR__, "..", "..", "src", "materialy", "materialy.db")
    db = SQLite.DB(db_path)

    @testset "ocel podle značky a čísla EN" begin
        podle_znacky = StrojniSoucasti.materialyEN(db, "S235JRG1")
        podle_cisla = StrojniSoucasti.materialyEN(db, "1.0036")

        @test podle_znacky isa Dict{String,Any}
        @test Set(keys(podle_znacky)) == Set(keys(podle_cisla))
        @test all(
            k == "name" || isequal(podle_znacky[k], podle_cisla[k])
            for k in keys(podle_znacky)
        )
        @test podle_znacky["znacka_EN"] == "S235JRG1"
        @test podle_znacky["cislo_EN"] == "1.0036"
        @test podle_znacky["druh"] == "konstrukční ocel"
    end

    @testset "litina podle značky a čísla EN" begin
        podle_znacky = StrojniSoucasti.materialyEN(db, "EN-GJL-200")
        podle_cisla = StrojniSoucasti.materialyEN(db, "5.1300")

        @test podle_znacky isa Dict{String,Any}
        @test isequal(podle_znacky, podle_cisla)
        @test podle_znacky["znacka_EN"] == "EN-GJL-200"
        @test podle_znacky["cislo_EN"] == "5.1300"
        @test podle_znacky["druh"] == "šedá litina"
    end

    @testset "neželezné kovy" begin
        kov = StrojniSoucasti.materialyEN(db, "CW004A")

        @test kov isa Dict{String,Any}
        @test kov["znacka_EN"] == "CW004A"
        @test kov["druh"] == "Elektrolytická měď"
    end

    @testset "nenalezený materiál" begin
        @test StrojniSoucasti.materialyEN(db, "neexistujici_material") === nothing
    end

    SQLite.close(db)
end

nothing