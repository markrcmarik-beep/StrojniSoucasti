# ver: 2026-07-03
using Test
using StrojniSoucasti

@testset "profilyvlcnWk - modul v krutu" begin

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

    @testset "zakladni tvary" begin
        Wk1, txt1 = StrojniSoucasti.profilyvlcnWk(KR_01, :Wk)
        @test isapprox(Wk1, pi/16 * 20^3, atol=1e-3)
        @test txt1 == "π/16*D³"

        Wk2, txt2 = StrojniSoucasti.profilyvlcnWk(TRKR_01, :Wk)
        @test isapprox(Wk2, pi/16 * (20^4 - 10^4) / 20, atol=1e-3)
        @test txt2 == "π/16*(D⁴ - d⁴)/D"

        Wk3, txt3 = StrojniSoucasti.profilyvlcnWk(_4HR_01, :Wk)
        @test isapprox(Wk3, 0.208 * 20^3, atol=1e-3)
        @test txt3 == "0.208*a³"

        Wk4, txt4 = StrojniSoucasti.profilyvlcnWk(PLO_01, :Wk)
        @test isapprox(Wk4, 500, atol=1e-3)
        @test txt4 == "0.25*a*b²"

        Wk5, txt5 = StrojniSoucasti.profilyvlcnWk(OBD_01, :Wk)
        @test isapprox(Wk5, 1080, atol=1e-3)
        @test txt5 == "0.25*a*b²"

        Wk6, txt6 = StrojniSoucasti.profilyvlcnWk(_6HR_01, :Wk)
        @test isapprox(Wk6, 0.17 * 20^3, atol=1e-3)
        @test txt6 == "0.17*s³"
    end

    @testset "kompatibilita :Wt" begin
        Wt1, txt1 = StrojniSoucasti.profilyvlcnWk(KR_01, :Wt)
        @test isapprox(Wt1, pi/16 * 20^3, atol=1e-3)
        @test txt1 == "π/16*D³"

        Wt2, txt2 = StrojniSoucasti.profilyvlcnWk(TRKR_01, :Wt)
        @test isapprox(Wt2, pi/16 * (20^4 - 10^4) / 20, atol=1e-3)
        @test txt2 == "π/16*(D⁴ - d⁴)/D"

        Wt3, txt3 = StrojniSoucasti.profilyvlcnWk(_4HR_01, :Wt)
        @test isapprox(Wt3, 0.25 * 20^3, atol=1e-3)
        @test txt3 == "0.25*a³"

        Wt4, txt4 = StrojniSoucasti.profilyvlcnWk(PLO_01, :Wt)
        @test isapprox(Wt4, 20 * 10^2 / 4 * (1 - 0.63 * 10 / 20 + 0.052 * (10 / 20)^5), atol=1e-3)
        @test txt4 == "a*b²/4*(1 - 0.63*b/a + 0.052*(b/a)^5)"

        Wt5, txt5 = StrojniSoucasti.profilyvlcnWk(OBD_01, :Wt)
        @test isapprox(Wt5, 30 * 12^2 / 4 * (1 - 0.63 * 12 / 30 + 0.052 * (12 / 30)^5), atol=1e-3)
        @test txt5 == "a*b²/4*(1 - 0.63*b/a + 0.052*(b/a)^5)"

        Wt6, txt6 = StrojniSoucasti.profilyvlcnWk(_6HR_01, :Wt)
        @test isapprox(Wt6, 0.17 * 20^3, atol=1e-3)
        @test txt6 == "0.17*s³"

        Wt_default, txt_default = StrojniSoucasti.profilyvlcnWk(KR_01)
        @test isapprox(Wt_default, pi/16 * 20^3, atol=1e-3)
        @test txt_default == "π/16*D³"
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWk(Dict(:info => "TR4HR", :a => 20), :Wk)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWk(Dict(:info => "XYZ"), :Wk)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWk(KR_01, :NeznamaVelicina)
    end
end

nothing
