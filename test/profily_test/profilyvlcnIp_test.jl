# ver: 2026-04-04
using Test
using StrojniSoucasti

@testset "profilyvlcnIp - polarni moment" begin

    PLO_01 = Dict(
        :info => "PLO",
        :a => 20,
        :b => 10
    )

    PLO_02 = Dict(
        :info => "PLO",
        :a => 120,
        :b => 10
    )

    PLO_03 = Dict(
        :info => "PLO",
        :a => 10,
        :b => 20
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
        :t => 1
    )

    TR4HR_02 = Dict(
        :info => "TR4HR",
        :a => 20,
        :b => 10,
        :t => 2
    )

    @testset "PLO/OBD" begin
        Ip1, txt1 = StrojniSoucasti.profilyvlcnIp(PLO_01)
        @test isapprox(Ip1, 20 * 10^3 * (1 / 3 - 0.21 * (10 / 20) * (1 - (10^4) / (12 * 20^4))))
        @test occursin("a", txt1) && occursin("b", txt1)

        Ip2, txt2 = StrojniSoucasti.profilyvlcnIp(PLO_02)
        @test Ip2 == 120 * 10^3 / 3
        @test occursin("/3", txt2)

        Ip3, txt3 = StrojniSoucasti.profilyvlcnIp(PLO_03)
        @test isapprox(Ip3, 20 * 10^3 * (1 / 3 - 0.21 * (10 / 20) * (1 - (10^4) / (12 * 20^4))))
        @test occursin("a", txt3) || occursin("b", txt3)

        Ip4, txt4 = StrojniSoucasti.profilyvlcnIp(OBD_01)
        @test isapprox(Ip4, 30 * 12^3 * (1 / 3 - 0.21 * (12 / 30) * (1 - (12^4) / (12 * 30^4))))
        @test occursin("0.21", txt4)
    end

    @testset "ostatni tvary" begin
        Ip_kr, txt_kr = StrojniSoucasti.profilyvlcnIp(KR_01)
        @test Ip_kr == pi / 32 * 20^4
        @test occursin("D", txt_kr)

        Ip_trkr, txt_trkr = StrojniSoucasti.profilyvlcnIp(TRKR_01)
        @test Ip_trkr == pi / 32 * (20^4 - 10^4)
        @test occursin("D", txt_trkr) && occursin("d", txt_trkr)

        Ip_4hr, txt_4hr = StrojniSoucasti.profilyvlcnIp(_4HR_01)
        @test Ip_4hr == 0.1406 * 20^4
        @test occursin("0.1406", txt_4hr)

        Ip_6hr, txt_6hr = StrojniSoucasti.profilyvlcnIp(_6HR_01)
        @test Ip_6hr == 0.133 * sqrt(3) / 2 * 20^4
        @test occursin("0.133", txt_6hr)
    end

    @testset "TR4HR - oblasti tloustky steny" begin
        Ip_tenk, txt_tenk = StrojniSoucasti.profilyvlcnIp(TR4HR_01, :Ip)
        @test Ip_tenk == 2 * (20 - 1)^2 * (10 - 1)^2 * 1 / ((20 - 1) + (10 - 1))
        @test occursin("(a-t)", txt_tenk)

        Ip_stred, txt_stred = StrojniSoucasti.profilyvlcnIp(TR4HR_02, :Ip)
        @test Ip_stred == 2 * (20 - 2)^2 * (10 - 2)^2 * 2 / ((20 - 2) + (10 - 2)) + 2 / 3 * (20 + 10) * 2^3
        @test occursin("+", txt_stred)
    end

    @testset "delegace pres profilyvlcn" begin
        Ip_d, _ = StrojniSoucasti.profilyvlcn(TRKR_01, :Ip)
        @test isapprox(Ip_d / oneunit(Ip_d), pi / 32 * (20^4 - 10^4))
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIp(Dict(:info => "XYZ"), :Ip)
    end
end
