# ver: 2026-02-26
using Test
using StrojniSoucasti
using Unitful

@testset "profilyvlcnIminImax" begin

    PLO_01 = Dict(
        :info => "PLO",
        :a => 20u"mm",
        :b => 10u"mm"
    )

    KR_01 = Dict(
        :info => "KR",
        :D => 20u"mm"
    )

    TRKR_01 = Dict(
        :info => "TRKR",
        :D => 20u"mm",
        :d => 10u"mm"
    )

    @testset "PLO - Imin Imax" begin
        Imin, _ = StrojniSoucasti.profilyvlcnIminImax(PLO_01, :Imin)
        Imax, _ = StrojniSoucasti.profilyvlcnIminImax(PLO_01, :Imax)

        Ix = 20u"mm" * (10u"mm")^3 / 12
        Iy = 10u"mm" * (20u"mm")^3 / 12

        @test isapprox(Imin, min(Ix, Iy); rtol=1e-12)
        @test Imax == max(Ix, Iy)
        @test Imin <= Imax
    end

    @testset "kruhove tvary" begin
        Imin_kr, txt_kr = StrojniSoucasti.profilyvlcnIminImax(KR_01, :Imin)
        Imax_kr, _ = StrojniSoucasti.profilyvlcnIminImax(KR_01, :Imax)
        @test Imin_kr == Imax_kr
        @test txt_kr == "pi/64*D^4"

        Imin_tr, txt_tr = StrojniSoucasti.profilyvlcnIminImax(TRKR_01, :Imin)
        Imax_tr, _ = StrojniSoucasti.profilyvlcnIminImax(TRKR_01, :Imax)
        @test Imin_tr == Imax_tr
        @test txt_tr == "pi/64*(D^4 - d^4)"
    end

    @testset "delegace pres profilyvlcn" begin
        Imin, _ = StrojniSoucasti.profilyvlcn(TRKR_01, :Imin)
        Imax, _ = StrojniSoucasti.profilyvlcn(TRKR_01, :Imax)
        @test Imin == Imax
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIminImax(PLO_01, :Ix)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIminImax(Dict(:info => "NEZNAMY"), :Imin)
    end
end
