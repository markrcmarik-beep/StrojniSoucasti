# ver: 2026-07-07
using Test
using StrojniSoucasti

@testset "profilyvlcnIx - Ix, Iy, I, Ixy, Imin, Imax" begin

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
        :D => 20,
        :d => 0
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
        Ix0, txt0 = StrojniSoucasti.profilyvlcnI(PLO_01, :Ix, 0)
        @test isapprox(Ix0, 1666.6666666666667, atol=1e-3)
        @test txt0 == "a*b^3/12"

        Ix_obd, txt_obd = StrojniSoucasti.profilyvlcnI(OBD_01, :Ix, 0)
        @test isapprox(Ix_obd, 4320, atol=1e-3)
        @test txt_obd == "a*b^3/12"

        Ix_kr, txt_kr = StrojniSoucasti.profilyvlcnI(KR_01, :Ix)
        @test isapprox(Ix_kr, 7853.981633974482, atol=1e-3)
        @test txt_kr == "pi/64*D^4"

        Ix_trkr, txt_trkr = StrojniSoucasti.profilyvlcnI(TRKR_01, :Ix)
        @test isapprox(Ix_trkr, 7363.107781851078, atol=1e-3)
        @test txt_trkr == "pi/64*(D^4 - d^4)"

        Ix_4hr, txt_4hr = StrojniSoucasti.profilyvlcnI(_4HR_01, :Ix)
        @test isapprox(Ix_4hr, 13333.333333333334, atol=1e-3)
        @test txt_4hr == "a^4/12"

        Ix_6hr_even, txt_6hr_even = StrojniSoucasti.profilyvlcnI(_6HR_01, :Ix)
        @test isapprox(Ix_6hr_even, 86602.54037844385, atol=1e-3)
        @test txt_6hr_even == "5*sqrt(3)/16*s^4"

        Ix_6hr_odd, txt_6hr_odd = StrojniSoucasti.profilyvlcnI(_6HR_01, :Ix)
        @test isapprox(Ix_6hr_odd, 86602.54037844385, atol=1e-3)
        @test txt_6hr_odd == "5*sqrt(3)/16*s^4"

        Ix_6hr_any, txt_6hr_any = StrojniSoucasti.profilyvlcnI(_6HR_01, :Ix)
        @test isapprox(Ix_6hr_any, 86602.54037844385, atol=1e-3)
        @test txt_6hr_any == "5*sqrt(3)/16*s^4"

        Ix_tr4hr, txt_tr4hr = StrojniSoucasti.profilyvlcnI(TR4HR_01, :Ix)
        @test isapprox(Ix_tr4hr, 1658.6666666666667, atol=1e-3)
        @test txt_tr4hr == "(a*b^3/12)-((a-2t)*(b-2t)^3/12)"
    end

    @testset "Iy pro vsechny tvary" begin
        Iy0, txty = StrojniSoucasti.profilyvlcnI(PLO_01, :Iy)
        @test isapprox(Iy0, 6666.666666666667, atol=1e-3)
        @test txty == "b*a^3/12"

        Iy_obd, txt_obd = StrojniSoucasti.profilyvlcnI(OBD_01, :Iy)
        @test isapprox(Iy_obd, 27000.0, atol=1e-3)
        @test txt_obd == "b*a^3/12"

        Iy_kr, txt_kr = StrojniSoucasti.profilyvlcnI(KR_01, :Iy)
        @test isapprox(Iy_kr, 7853.981633974483, atol=1e-3)
        @test txt_kr == "pi/64*D^4"

        Iy_trkr, txt_trkr = StrojniSoucasti.profilyvlcnI(TRKR_01, :Iy)
        @test isapprox(Iy_trkr, 7363.107781851078, atol=1e-3)
        @test txt_trkr == "pi/64*(D^4 - d^4)"

        Iy_4hr, txt_4hr = StrojniSoucasti.profilyvlcnI(_4HR_01, :Iy)
        @test isapprox(Iy_4hr, 13333.333333333334, atol=1e-3)
        @test txt_4hr == "a^4/12"

        Iy_6hr, txt_6hr = StrojniSoucasti.profilyvlcnI(_6HR_01, :Iy)
        @test isapprox(Iy_6hr, 8333.333333333334, atol=1e-3)
        @test txt_6hr == "5/96*s^4"

        Iy_tr4hr, txt_tr4hr = StrojniSoucasti.profilyvlcnI(TR4HR_01, :Iy)
        @test isapprox(Iy_tr4hr, 6378.666666666667, atol=1e-3)
        @test txt_tr4hr == "(b*a^3/12)-((b-2t)*(a-2t)^3/12)"

        Iy_ref, _ = StrojniSoucasti.profilyvlcnI(PLO_01, :Ix)
        Iy_from_delegate, _ = StrojniSoucasti.profilyvlcnI(PLO_01, :Iy)
        #@test isapprox(Iy_from_delegate, Iy_ref)
    end

    @testset "Ixy pro vsechny tvary" begin
        Ixy_plo, txt_plo = StrojniSoucasti.profilyvlcnI(PLO_01, :Ixy, 0)
        @test Ixy_plo == 0
        @test txt_plo == "0"

        Ixy_kr, txt_kr = StrojniSoucasti.profilyvlcnI(KR_01, :Ixy, 0)
        @test Ixy_kr == 0
        @test txt_kr == "0"

        Ixy_trkr, txt_trkr = StrojniSoucasti.profilyvlcnI(TRKR_01, :Ixy, 0)
        @test Ixy_trkr == 0
        @test txt_trkr == "0"

        Ixy_4hr, txt_4hr = StrojniSoucasti.profilyvlcnI(_4HR_01, :Ixy, 0)
        @test Ixy_4hr == 0
        @test txt_4hr == "0"

        Ixy_6hr, txt_6hr = StrojniSoucasti.profilyvlcnI(_6HR_01, :Ixy, 0)
        @test Ixy_6hr == 0
        @test txt_6hr == "0"

        Ixy_tr4hr, txt_tr4hr = StrojniSoucasti.profilyvlcnI(TR4HR_01, :Ixy, 0)
        @test Ixy_tr4hr == 0
        @test txt_tr4hr == "0"
    end

    @testset "Imin a Imax pro vsechny tvary" begin
        Imin_plo, txt_min_plo = StrojniSoucasti.profilyvlcnI(PLO_01, :Imin, 0)
        Imax_plo, txt_max_plo = StrojniSoucasti.profilyvlcnI(PLO_01, :Imax, 0)
        @test isapprox(Imin_plo, 1666.666666666667, atol=1e-3)
        @test isapprox(Imax_plo, 6666.666666666667, atol=1e-3)
        @test txt_min_plo == "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        @test txt_max_plo == "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"

        Imin_obd, txt_min_obd = StrojniSoucasti.profilyvlcnI(OBD_01, :Imin, 0)
        Imax_obd, txt_max_obd = StrojniSoucasti.profilyvlcnI(OBD_01, :Imax, 0)
        @test isapprox(Imin_obd, 4320.0, atol=1e-3)
        @test isapprox(Imax_obd, 27000.0, atol=1e-3)
        @test txt_min_obd == "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        @test txt_max_obd == "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"

        Imin_kr, txt_min_kr = StrojniSoucasti.profilyvlcnI(KR_01, :Imin, 0)
        Imax_kr, txt_max_kr = StrojniSoucasti.profilyvlcnI(KR_01, :Imax, 0)
        @test isapprox(Imin_kr, 7853.981633974483, atol=1e-3)
        @test isapprox(Imax_kr, 7853.981633974483, atol=1e-3)
        @test txt_min_kr == "pi/64*D^4"
        @test txt_max_kr == "pi/64*D^4"

        Imin_trkr, txt_min_trkr = StrojniSoucasti.profilyvlcnI(TRKR_01, :Imin, 0)
        Imax_trkr, txt_max_trkr = StrojniSoucasti.profilyvlcnI(TRKR_01, :Imax, 0)
        @test isapprox(Imin_trkr, 7363.107781851078, atol=1e-3)
        @test isapprox(Imax_trkr, 7363.107781851078, atol=1e-3)
        @test txt_min_trkr == "pi/64*(D^4 - d^4)"
        @test txt_max_trkr == "pi/64*(D^4 - d^4)"

        Imin_4hr, txt_min_4hr = StrojniSoucasti.profilyvlcnI(_4HR_01, :Imin, 0)
        Imax_4hr, txt_max_4hr = StrojniSoucasti.profilyvlcnI(_4HR_01, :Imax, 0)
        @test isapprox(Imin_4hr, 13333.333333333334, atol=1e-3)
        @test isapprox(Imax_4hr, 13333.333333333334, atol=1e-3)
        @test txt_min_4hr == "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        @test txt_max_4hr == "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"

        Imin_6hr, txt_min_6hr = StrojniSoucasti.profilyvlcnI(_6HR_01, :Imin, 0)
        Imax_6hr, txt_max_6hr = StrojniSoucasti.profilyvlcnI(_6HR_01, :Imax, 0)
        @test isapprox(Imin_6hr, 8333.333333333334, atol=1e-3)
        @test isapprox(Imax_6hr, 86602.54037844385, atol=1e-3)
        @test txt_min_6hr == "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        @test txt_max_6hr == "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"

        Imin_tr4hr, txt_min_tr4hr = StrojniSoucasti.profilyvlcnI(TR4HR_01, :Imin, 0)
        Imax_tr4hr, txt_max_tr4hr = StrojniSoucasti.profilyvlcnI(TR4HR_01, :Imax, 0)
        @test isapprox(Imin_tr4hr, 1658.666666666667, atol=1e-3)
        @test isapprox(Imax_tr4hr, 6378.666666666667, atol=1e-3)
        @test txt_min_tr4hr == "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        @test txt_max_tr4hr == "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
    end

    @testset "normalizace uhlu" begin
        Ix_ref, _ = StrojniSoucasti.profilyvlcnI(PLO_01, :Ix, 0)
        Ix_2pi, _ = StrojniSoucasti.profilyvlcnI(PLO_01, :Ix, 2pi)
        Iy_2pi, _ = StrojniSoucasti.profilyvlcnI(PLO_01, :Iy, 2pi)

        @test isapprox(Ix_2pi, Ix_ref)
        @test isapprox(Iy_2pi, 10 * 20^3 / 12)

        Ix_hex_ref, _ = StrojniSoucasti.profilyvlcnI(_6HR_01, :Ix, pi/6)
        Ix_hex_shift, _ = StrojniSoucasti.profilyvlcnI(_6HR_01, :Ix, pi/6 + 2*pi)
        @test isapprox(Ix_hex_ref, Ix_hex_shift)
    end

    @testset "chybove stavy" begin
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnI(PLO_01, :Ix, pi/4)
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnI(PLO_01, :Ix, -pi/4)
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnI(_4HR_01, :Ix, pi/4)
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnI(_6HR_01, :Ix, pi/5)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnI(Dict(:info => "XYZ"), :Ix, 0)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnI(PLO_01, :Wo, 0)
    end
end

nothing
