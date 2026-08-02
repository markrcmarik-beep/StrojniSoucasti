# ver: 2026-06-22
using Test
using StrojniSoucasti

function _expected_iminmax(Ix, Iy, Ixy)
    Imin = (Ix + Iy) / 2 - sqrt(((Ix - Iy) / 2)^2 + Ixy^2)
    Imax = (Ix + Iy) / 2 + sqrt(((Ix - Iy) / 2)^2 + Ixy^2)
    return Imin, Imax
end

@testset "profilyIminmax" begin
    @testset "zakladni vypocet" begin
        cases = [
            (1000.0, 500.0, 200.0),
            (500.0, 1000.0, 200.0),
            (1000.0, 500.0, -200.0),
            (1000.0, 500.0, 0.0),
            (1000.0, 1000.0, 0.0),
            (1000.0, 1000.0, 100.0),
            (0.0, 0.0, 0.0),
        ]

        for (Ix, Iy, Ixy) in cases
            Imin, Imax = StrojniSoucasti.profilyIminmax(Ix, Iy, Ixy)
            exp_Imin, exp_Imax = _expected_iminmax(Ix, Iy, Ixy)

            @test isapprox(Imin, exp_Imin; rtol=1e-12, atol=1e-12)
            @test isapprox(Imax, exp_Imax; rtol=1e-12, atol=1e-12)
            @test Imin <= Imax
        end
    end

    @testset "nulove Ixy vraci mensi a vetsi hlavni moment" begin
        Imin, Imax = StrojniSoucasti.profilyIminmax(1000.0, 500.0, 0.0)

        @test Imin == 500.0
        @test Imax == 1000.0
    end

    @testset "stejne Ix a Iy s nenulovym Ixy" begin
        Imin, Imax = StrojniSoucasti.profilyIminmax(1000.0, 1000.0, 100.0)

        @test Imin == 900.0
        @test Imax == 1100.0
    end

    @testset "vystup s textem vzorcu" begin
        Imin, Imax, vzorecmin, vzorecmax = StrojniSoucasti.profilyIminmax(1000.0, 500.0, 200.0, true)
        exp_Imin, exp_Imax = _expected_iminmax(1000.0, 500.0, 200.0)

        @test isapprox(Imin, exp_Imin; rtol=1e-12, atol=1e-12)
        @test isapprox(Imax, exp_Imax; rtol=1e-12, atol=1e-12)
        @test vzorecmin == "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        @test vzorecmax == "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyIminmax()
        @test_throws ErrorException StrojniSoucasti.profilyIminmax(1000.0)
        @test_throws ErrorException StrojniSoucasti.profilyIminmax(1000.0, 500.0)
        @test_throws ErrorException StrojniSoucasti.profilyIminmax(1000.0, 500.0, nothing)
        @test_throws ErrorException StrojniSoucasti.profilyIminmax(1000.0, nothing, 0.0)
        @test_throws ErrorException StrojniSoucasti.profilyIminmax(nothing, 500.0, 0.0)
    end
end
