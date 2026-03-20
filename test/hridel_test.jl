# ver: 2026-03-19
# Test script for hridel.jl

using StrojniSoucasti, Unitful, Test

@testset "hridel" begin
    @testset "basic hollow shaft" begin
        VV, txt = StrojniSoucasti.hridel(Mk=200, D=40, d=20, tauDk=120, return_text=true)
        @test isa(VV, Dict)
        @test haskey(VV, :tau)
        @test haskey(VV, :Wk)
        @test haskey(VV, :Ip)
        @test haskey(VV, :D)
        @test haskey(VV, :d)
        @test VV[:D] == 40u"mm"
        @test VV[:d] == 20u"mm"
        @test uconvert(u"N*m", VV[:Mk]) == 200u"N*m"
        @test VV[:tau] > 0u"MPa"
        @test VV[:bezpecnost] > 0
        @test isa(txt, String)
        @test !isempty(txt)
    end

    @testset "solid shaft" begin
        VV = StrojniSoucasti.hridel(Mk=150u"N*m", D=30u"mm", tauDk=100u"MPa", return_text=false)
        @test VV[:d] === nothing
        @test VV[:D] == 30u"mm"
        @test VV[:tau] > 0u"MPa"
    end

    @testset "angle of twist" begin
        VV = StrojniSoucasti.hridel(
            Mk=150u"N*m",
            D=50u"mm",
            d=30u"mm",
            tauDk=100u"MPa",
            G=80u"GPa",
            L=100u"mm",
            return_text=false,
        )
        @test VV[:phi] !== nothing
        @test VV[:theta] !== nothing
        @test uconvert(u"rad", VV[:phi]) isa Quantity
        @test uconvert(u"rad/m", VV[:theta]) isa Quantity
    end

    @testset "material input" begin
        VV = StrojniSoucasti.hridel(Mk=120u"N*m", D=45u"mm", d=25u"mm", mat="11373", return_text=false)
        @test VV[:mat] == "11373"
        @test VV[:Re] > 0u"MPa"
        @test VV[:G] > 0u"GPa"
        @test VV[:tauDk] > 0u"MPa"
    end

    @testset "input validation" begin
        @test_throws ErrorException StrojniSoucasti.hridel(D=40, d=20, tauDk=120, return_text=false) # missing Mk
        @test_throws ErrorException StrojniSoucasti.hridel(Mk=10, d=20, tauDk=120, return_text=false) # missing D
        @test_throws ErrorException StrojniSoucasti.hridel(Mk=-10, D=40, d=20, tauDk=120, return_text=false) # negative Mk
    end
end
