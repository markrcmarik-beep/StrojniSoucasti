# ver: 2026-08-04
using StrojniSoucasti, Test

#include("zavit.jl")
@testset "zavity" begin

    @testset "M8" begin
        A = zavity("M8")
        @test A[:name] == "M8"
        @test A[:d] == 8.0
        @test A[:p] == 1.25
        Ab = zavity("M8x1.25")
        @test Ab[:name] == "M8x1.25"
        @test Ab[:d] == 8.0
        @test Ab[:p] == 1.25

        @test A == zavity("m8")
        @test Ab == zavity("m8x1.25")
    end

    @testset "M8x1" begin
        A1 = zavity("M8x1")
        @test A1[:name] == "M8x1"
        @test A1[:d] == 8.0
        @test A1[:p] == 1
    end

    @testset "M10x1.25" begin
        A2 = zavity("M10x1.25")
        @test A2[:name] == "M10x1.25"
        @test A2[:d] == 10.0
        @test A2[:p] == 1.25
    end

    @testset "M6x0,5" begin
        A3 = zavity("M6x0,5")
        @test A3[:name] == "M6x0.5"
        @test A3[:d] == 6.0
        @test A3[:p] == 0.5
    end

    @testset "TR20x4" begin
        #A4 = zavity("TR20x4")
        #@test A4[:name] == "TR20x4"
        #@test A4[:d] == 20.0
        #@test A4[:p] == 4.0
    end

    @test_throws ErrorException zavity("M66")
    #@test zavity("M66") === nothing
    @test zavity("aa66x4") === nothing
    @test zavity("M8x0.25") === nothing

end

nothing
