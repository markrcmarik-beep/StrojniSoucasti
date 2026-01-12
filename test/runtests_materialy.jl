#!/usr/bin/env julia

using Test
using StrojniSoucasti

@testset "Materiály – databáze" begin

    mat = materialy("S235JR+N")

    @test mat.name == "S235JR+N"
    @test mat.standard == "EN 10025-2"
    @test mat.Re == 235.0
    @test mat.weldable == true
    @test mat.thickness_max == 200.0
end

@testset "Materiály – redukce podle tloušťky (S235)" begin

    mat = materialy("S235JR+N")

    @test Re_eff(mat, 10.0)  == 235.0
    @test Re_eff(mat, 20.0)  == 225.0
    @test Re_eff(mat, 50.0)  == 215.0
    @test Re_eff(mat, 90.0)  == 205.0
    @test Re_eff(mat, 160.0) == 185.0

    rm = Rm_eff(mat, 50.0)
    @test rm[1] == 360.0
    @test rm[2] == 510.0

    @test A_eff(mat, 10.0) == 26.0
    @test A_eff(mat, 90.0) == 22.0
end

@testset "Materiály – redukce podle tloušťky (S355)" begin

    mat = materialy("S355J2+N")

    @test Re_eff(mat, 10.0) == 355.0
    @test Re_eff(mat, 30.0) == 345.0
    @test Re_eff(mat, 70.0) == 325.0
    @test Re_eff(mat, 120.0) == 295.0

    rm = Rm_eff(mat, 30.0)
    @test rm == (470.0, 630.0)

    @test A_eff(mat, 10.0) == 22.0
end

@testset "Materiály – sjednocený výstup reduced_properties()" begin

    mat = materialy("S235J2+N")
    props = reduced_properties(mat, 45.0)

    @test props.Re == 215.0
    @test props.Rm_min == 360.0
    @test props.Rm_max == 510.0
    @test props.A == 24.0
end

@testset "Materiály – automatická volba" begin

    req = MaterialRequest(
        210.0,   # Re_req
        -10.0,   # Tmin
        true,    # svařování
        25.0     # tloušťka
    )

    mat = select_material(req)
    @test mat.name == "S235J2+N"
end

@testset "Materiály – volba vyšší pevnosti" begin

    req = MaterialRequest(
        300.0,
        -20.0,
        true,
        30.0
    )

    mat = select_material(req)
    @test mat.name == "S355J2+N"
end

@testset "Materiály – chybové stavy" begin

    mat = materialy("S235JR+N")

    @test_throws ErrorException Re_eff(mat, 300.0)

    bad_req = MaterialRequest(
        500.0,   # nesplnitelné Re
        0.0,
        true,
        20.0
    )

    @test_throws ErrorException select_material(bad_req)
end
