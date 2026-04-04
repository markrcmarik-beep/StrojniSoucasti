# ver: 2026-04-05
using Test
using StrojniSoucasti

@testset "profilyvlcnIx - Ix, Iy, Ixy" begin

    PLO_01 = Dict(
        :info => "PLO",
        :a => 20,
        :b => 10
    )

    OBD_01 = Dict(
        :info => "OBD",
        :a => 30,
        :b => 12
    )

    KR_01 = Dict(
        :info => "KR",
        :D => 20
    )

    TRKR_01 = Dict(
        :info => "TRKR",
        :D => 20,
        :d => 10
    )

    _4HR_01 = Dict(
        :info => "4HR",
        :a => 20
    )

    _6HR_01 = Dict(
        :info => "6HR",
        :s => 20
    )

    TR4HR_01 = Dict(
        :info => "TR4HR",
        :a => 20,
        :b => 10,
        :t => 4
    )

    @testset "Ix pro vsechny tvary" begin
        Ix0, txt0 = StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, 0)
        @test Ix0 == 20 * 10^3 / 12
        @test txt0 == "a*b^3/12"

        Ix_obd, txt_obd = StrojniSoucasti.profilyvlcnIx(OBD_01, :Ix, 0)
        @test Ix_obd == 30 * 12^3 / 12
        @test txt_obd == "a*b^3/12"

        Ix_kr, txt_kr = StrojniSoucasti.profilyvlcnIx(KR_01, :Ix, 0)
        @test Ix_kr == pi / 64 * 20^4
        @test txt_kr == "pi/64*D^4"

        Ix_trkr, txt_trkr = StrojniSoucasti.profilyvlcnIx(TRKR_01, :Ix, 0)
        @test Ix_trkr == pi / 64 * (20^4 - 10^4)
        @test txt_trkr == "pi/64*(D^4 - d^4)"

        Ix_4hr, txt_4hr = StrojniSoucasti.profilyvlcnIx(_4HR_01, :Ix, pi/2)
        @test Ix_4hr == 20^4 / 12
        @test txt_4hr == "a^4/12"

        Ix_6hr_even, txt_6hr_even = StrojniSoucasti.profilyvlcnIx(_6HR_01, :Ix, 0)
        @test Ix_6hr_even == 5 * sqrt(3) / 144 * 20^4
        @test txt_6hr_even == "5*sqr(3)/144*s^4"

        Ix_6hr_odd, txt_6hr_odd = StrojniSoucasti.profilyvlcnIx(_6HR_01, :Ix, pi/6)
        @test Ix_6hr_odd == 5 / 96 * 20^4
        @test txt_6hr_odd == "5/96*s^4"

        Ix_tr4hr, txt_tr4hr = StrojniSoucasti.profilyvlcnIx(TR4HR_01, :Ix, 0)
        @test Ix_tr4hr == (20 * 10^3 / 12) - ((20 - 2 * 4) * (10 - 2 * 4)^3 / 12)
        @test txt_tr4hr == "(a*b^3/12)-((a-2t)*(b-2t)^3/12)"
    end

    @testset "Iy delegace" begin
        Iy0, txty = StrojniSoucasti.profilyvlcnIx(PLO_01, :Iy, 0)
        @test Iy0 == 10 * 20^3 / 12
        @test txty == "b*a^3/12"

        Iy_ref, _ = StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, pi/2)
        Iy_from_delegate, _ = StrojniSoucasti.profilyvlcnIx(PLO_01, :Iy, 0)
        @test Iy_from_delegate == Iy_ref
    end

    @testset "Ixy pro vsechny tvary" begin
        Ixy_plo, txt_plo = StrojniSoucasti.profilyvlcnIx(PLO_01, :Ixy, 0)
        @test Ixy_plo == 0
        @test txt_plo == "0"

        Ixy_kr, txt_kr = StrojniSoucasti.profilyvlcnIx(KR_01, :Ixy, 0)
        @test Ixy_kr == 0
        @test txt_kr == "0"

        Ixy_trkr, txt_trkr = StrojniSoucasti.profilyvlcnIx(TRKR_01, :Ixy, 0)
        @test Ixy_trkr == 0
        @test txt_trkr == "0"

        Ixy_4hr, txt_4hr = StrojniSoucasti.profilyvlcnIx(_4HR_01, :Ixy, 0)
        @test Ixy_4hr == 0
        @test txt_4hr == "0"

        Ixy_6hr, txt_6hr = StrojniSoucasti.profilyvlcnIx(_6HR_01, :Ixy, 0)
        @test Ixy_6hr == 0
        @test txt_6hr == "0"

        Ixy_tr4hr, txt_tr4hr = StrojniSoucasti.profilyvlcnIx(TR4HR_01, :Ixy, 0)
        @test Ixy_tr4hr == 0
        @test txt_tr4hr == "0"
    end

    @testset "normalizace uhlu" begin
        Ix_ref, _ = StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, 0)
        Ix_2pi, _ = StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, 2pi)
        Iy_2pi, _ = StrojniSoucasti.profilyvlcnIx(PLO_01, :Iy, 2pi)

        @test Ix_2pi == Ix_ref
        @test Iy_2pi == 10 * 20^3 / 12

        Ix_hex_ref, _ = StrojniSoucasti.profilyvlcnIx(_6HR_01, :Ix, pi/6)
        Ix_hex_shift, _ = StrojniSoucasti.profilyvlcnIx(_6HR_01, :Ix, 13pi/6)
        @test Ix_hex_ref == Ix_hex_shift
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, pi/4)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, -pi/4)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIx(_4HR_01, :Ix, pi/4)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIx(_6HR_01, :Ix, pi/5)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIx(Dict(:info => "XYZ"), :Ix, 0)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIx(PLO_01, :Wo, 0)
    end
end
