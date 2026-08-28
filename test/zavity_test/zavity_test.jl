# ver: 2026-08-07
using StrojniSoucasti, Test

#include("zavit.jl")
@testset "zavity" begin

    @testset "M8" begin
        A = zavity("M8")
        @test A[:name] == "M8"
        @test isa(A[:name_info], String)
        @test A[:d] == 8.0
        @test isa(A[:d_info], String)
        @test A[:p] == 1.25
        @test isa(A[:p_info], String)

        Ab = zavity("M8x1.25")
        @test Ab[:name] == "M8x1.25"
        @test Ab[:d] == 8.0
        @test Ab[:p] == 1.25

        @test A == zavity("m8")
        @test Ab == zavity("m8x1.25")

        Ac = zavity("M8x1")
        @test Ac[:name] == "M8x1"
        @test Ac[:d] == 8.0
        @test Ac[:p] == 1
    end

    @testset "M10" begin
        A2 = zavity("M10")
        @test A2[:name] == "M10"
        @test A2[:d] == 10.0
        @test A2[:p] == 1.5
        
        A2a = zavity("M10x1.25")
        @test A2a[:name] == "M10x1.25"
        @test A2a[:d] == 10.0
        @test A2a[:p] == 1.25

        A2b = zavity("M10x1.5")
        @test A2b[:name] == "M10x1.5"
        @test A2b[:d] == 10.0
        @test A2b[:p] == 1.5
    end

    @testset "M6x0,5" begin
        A3 = zavity("M6x0,5")
        @test A3[:name] == "M6x0.5"
        @test A3[:d] == 6.0
        @test A3[:p] == 0.5
    end

    @testset "Tr20x4" begin
        A4 = zavity("Tr20x4")
        @test A4[:name] == "Tr20x4"
        @test A4[:d] == 20.0
        @test A4[:p] == 4.0

        A4b = zavity("tr20x4")
        @test A4b == A4
        A4c = zavity("TR20x4")
        @test A4c == A4
    end

    @test zavity("M66.2") === nothing
    @test zavity("aa66x4") === nothing
    @test zavity("M8x0.25") === nothing

end

nothing
