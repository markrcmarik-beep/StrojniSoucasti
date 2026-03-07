# ver: 2026-02-28
using Test
using StrojniSoucasti
using Unitful

@testset "profilyvlcnIminImax" begin

    PLO_01 = Dict(
        :info => "PLO",
        :a => 20u"mm",
        :b => 10u"mm"
    )

    OBD_01 = Dict(
        :info => "OBD",
        :a => 30u"mm",
        :b => 12u"mm"
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

    _4HR_01 = Dict(
        :info => "4HR",
        :a => 20u"mm"
    )

    _6HR_01 = Dict(
        :info => "6HR",
        :s => 20u"mm"
    )

    TR4HR_01 = Dict(
        :info => "TR4HR",
        :a => 20u"mm",
        :b => 10u"mm",
        :t => 4u"mm"
    )

    @testset "PLO a OBD - Imin/Imax" begin
        Imin_plo, txtmin_plo = StrojniSoucasti.profilyvlcnIminImax(PLO_01, :Imin)
        Imax_plo, txtmax_plo = StrojniSoucasti.profilyvlcnIminImax(PLO_01, :Imax)

        Ix_plo = 20u"mm" * (10u"mm")^3 / 12
        Iy_plo = 10u"mm" * (20u"mm")^3 / 12

        @test isapprox(Imin_plo, min(Ix_plo, Iy_plo); rtol=1e-12)
        @test isapprox(Imax_plo, max(Ix_plo, Iy_plo); rtol=1e-12)
        @test Imin_plo <= Imax_plo
        @test txtmin_plo == "-sqrt((1//4)*((-(1//12)*(a^3)*b + (1//12)*a*(b^3))^2)) + (1//2)*((1//12)*(a^3)*b + (1//12)*a*(b^3))"
        @test txtmax_plo == "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"

        Imin_obd, _ = StrojniSoucasti.profilyvlcnIminImax(OBD_01, :Imin)
        Imax_obd, _ = StrojniSoucasti.profilyvlcnIminImax(OBD_01, :Imax)
        Ix_obd = 30u"mm" * (12u"mm")^3 / 12
        Iy_obd = 12u"mm" * (30u"mm")^3 / 12
        @test isapprox(Imin_obd, min(Ix_obd, Iy_obd); rtol=1e-12)
        @test isapprox(Imax_obd, max(Ix_obd, Iy_obd); rtol=1e-12)
    end

    @testset "symetricke tvary - Imin == Imax" begin
        Imin_kr, txt_kr = StrojniSoucasti.profilyvlcnIminImax(KR_01, :Imin)
        Imax_kr, _ = StrojniSoucasti.profilyvlcnIminImax(KR_01, :Imax)
        @test Imin_kr == Imax_kr
        @test Imin_kr == pi/64 * (20u"mm")^4
        @test txt_kr == "pi/64*D^4"

        Imin_trkr, txt_trkr = StrojniSoucasti.profilyvlcnIminImax(TRKR_01, :Imin)
        Imax_trkr, _ = StrojniSoucasti.profilyvlcnIminImax(TRKR_01, :Imax)
        @test Imin_trkr == Imax_trkr
        @test Imin_trkr == pi/64 * ((20u"mm")^4 - (10u"mm")^4)
        @test txt_trkr == "pi/64*(D^4 - d^4)"

        Imin_4hr, txt_4hr = StrojniSoucasti.profilyvlcnIminImax(_4HR_01, :Imin)
        Imax_4hr, _ = StrojniSoucasti.profilyvlcnIminImax(_4HR_01, :Imax)
        @test Imin_4hr == Imax_4hr
        @test Imin_4hr == (20u"mm")^4 / 12
        @test txt_4hr == "a^4/12"

        Imin_6hr, txt_6hr = StrojniSoucasti.profilyvlcnIminImax(_6HR_01, :Imin)
        Imax_6hr, _ = StrojniSoucasti.profilyvlcnIminImax(_6HR_01, :Imax)
        @test Imin_6hr == Imax_6hr
        @test Imin_6hr == (20u"mm")^4 / 6
        @test txt_6hr == "s^4/6"

        Imin_tr4hr, txt_tr4hr = StrojniSoucasti.profilyvlcnIminImax(TR4HR_01, :Imin)
        Imax_tr4hr, _ = StrojniSoucasti.profilyvlcnIminImax(TR4HR_01, :Imax)
        @test Imin_tr4hr == Imax_tr4hr
        @test Imin_tr4hr == ((20u"mm" * (10u"mm")^3) - ((20u"mm" - 2 * 4u"mm") * (10u"mm" - 2 * 4u"mm")^3)) / 12
        @test txt_tr4hr == "(a*b^3 - (a-2t)*(b-2t)^3)/12"
    end

    @testset "delegace pres profilyvlcn" begin
        Imin1, _ = StrojniSoucasti.profilyvlcn(TRKR_01, :Imin)
        Imax1, _ = StrojniSoucasti.profilyvlcn(TRKR_01, :Imax)
        @test Imin1 == Imax1

        Imin2, _ = StrojniSoucasti.profilyvlcn(PLO_01, :Imin)
        Imax2, _ = StrojniSoucasti.profilyvlcn(PLO_01, :Imax)
        @test Imin2 < Imax2
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIminImax(PLO_01, :Ix)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIminImax(PLO_01, :Wo)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIminImax(Dict(:info => "NEZNAMY"), :Imin)
    end
end
