# ver: 2026-05-20
using Test
using StrojniSoucasti

@testset "profilyvlcnJp - polarni moment" begin

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
        Ip1, txt1 = StrojniSoucasti.profilyvlcnJp(PLO_01, :Jp)
        @test isapprox(Ip1, 4577.500000000001, atol=1e-3)
        @test txt1 == "a*b³/3*(1 - 0.63*b/a + 0.052*(b/a)^5)"

        Ip2, txt2 = StrojniSoucasti.profilyvlcnJp(PLO_02, :Jp)
        @test isapprox(Ip2, 40000.0, atol=1e-3)
        @test txt2 == "a*b³ /3"

        Ip3, txt3 = StrojniSoucasti.profilyvlcnJp(PLO_03, :Jp)
        @test isapprox(Ip3, 4577.604166666666, atol=1e-3)
        @test txt3 == "b*a³ *(1/3 - 0.21*a/b*(1 - a⁴/12/b⁴))"

        Ip4, txt4 = StrojniSoucasti.profilyvlcnJp(OBD_01, :Jp)
        @test isapprox(Ip4, 12934.6412544, atol=1e-3)
        @test txt4 == "a*b³/3*(1 - 0.63*b/a + 0.052*(b/a)^5)"
    end

    @testset "ostatni tvary" begin
        Ip_kr, txt_kr = StrojniSoucasti.profilyvlcnJp(KR_01, :Jp)
        @test isapprox(Ip_kr, 15707.963267948966, atol=1e-3)
        @test txt_kr == "π/32*D⁴"

        Ip_trkr, txt_trkr = StrojniSoucasti.profilyvlcnJp(TRKR_01, :Jp)
        @test isapprox(Ip_trkr, 14726.215563702155, atol=1e-3)
        @test txt_trkr == "π/32*(D⁴ - d⁴)"

        Ip_4hr, txt_4hr = StrojniSoucasti.profilyvlcnJp(_4HR_01, :Jp)
        @test isapprox(Ip_4hr, 22496.0, atol=1e-3)
        @test txt_4hr == "0.1406*a⁴"

        Ip_6hr, txt_6hr = StrojniSoucasti.profilyvlcnJp(_6HR_01, :Jp)
        @test isapprox(Ip_6hr, 18429.020592532856, atol=1e-3)
        @test txt_6hr == "0.133*sqrt(3)/2*s⁴"
    end

    @testset "TR4HR - oblasti tloustky steny" begin
        Ip_tenk, txt_tenk = StrojniSoucasti.profilyvlcnJp(TR4HR_01, :Jp)
        @test isapprox(Ip_tenk, 2088.6428571428573, atol=1e-3)
        @test txt_tenk == "2*(a-t)²*(b-t)²*t/((a-t)+(b-t))"

        Ip_stred, txt_stred = StrojniSoucasti.profilyvlcnJp(TR4HR_02, :Jp)
        @test isapprox(Ip_stred, 3350.153846153846, atol=1e-3)
        @test txt_stred == "2*(a-t)²*(b-t)²*t/((a-t)+(b-t))+2/3*(a+b)*t³"
    end

    @testset "delegace pres profilyvlcn" begin
        #Ip_d, _ = StrojniSoucasti.profilyvlcn(TRKR_01)
        #@test isapprox(Ip_d / oneunit(Ip_d), pi / 32 * (20^4 - 10^4))
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnJp(Dict(:info => "XYZ"), :Jp)
    end
end
