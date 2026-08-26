# ver: 2026-08-25
# Test script for parse_numeric_smart.jl
using StrojniSoucasti, Test

@testset "parse_numeric_smart" begin
    @testset "Celá čísla" begin
        @test StrojniSoucasti.parse_numeric_smart("15") isa Int
        @test StrojniSoucasti.parse_numeric_smart("15") == 15
        @test StrojniSoucasti.parse_numeric_smart("15.0") == 15
        @test StrojniSoucasti.parse_numeric_smart("15,0") == 15
        @test StrojniSoucasti.parse_numeric_smart("-15") == -15
    end

    @testset "Desetinná čísla" begin
        @test StrojniSoucasti.parse_numeric_smart("15.2") isa Float64
        @test StrojniSoucasti.parse_numeric_smart("15.2") == 15.2
        @test StrojniSoucasti.parse_numeric_smart("15,2") == 15.2
        @test StrojniSoucasti.parse_numeric_smart("-15,2") == -15.2
    end

    @testset "Neplatný vstup" begin
        @test_throws ArgumentError StrojniSoucasti.parse_numeric_smart("abc")
    end
end

nothing
