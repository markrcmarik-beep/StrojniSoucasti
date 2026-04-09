# ver: 2026-04-04
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
        @test isapprox(Wk1, pi/16 * 20^3)
        @test occursin("D", txt1)

        Wk2, txt2 = StrojniSoucasti.profilyvlcnWk(TRKR_01, :Wk)
        @test isapprox(Wk2, pi/16 * (20^4 - 10^4) / 20)
        @test occursin("D", txt2) && occursin("d", txt2)

        Wk3, txt3 = StrojniSoucasti.profilyvlcnWk(_4HR_01, :Wk)
        @test Wk3 == 0.208 * 20^3
        @test occursin("0.208", txt3)

        Wk4, txt4 = StrojniSoucasti.profilyvlcnWk(PLO_01, :Wk)
        @test isapprox(Wk4, 20 * 10^3 / 3 * (1 - 0.63 * (10 / 20) + 0.052 * (10 / 20)^5))
        @test occursin("a*b", txt4)

        Wk5, txt5 = StrojniSoucasti.profilyvlcnWk(OBD_01, :Wk)
        @test isapprox(Wk5, 30 * 12^3 / 3 * (1 - 0.63 * (12 / 30) + 0.052 * (12 / 30)^5))
        @test occursin("0.052", txt5)

        Wk6, txt6 = StrojniSoucasti.profilyvlcnWk(_6HR_01, :Wk)
        @test Wk6 == 0.17 * 20^3
        @test occursin("0.17", txt6)
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWk(Dict(:info => "TR4HR", :a => 20), :Wk)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWk(Dict(:info => "XYZ"), :Wk)
    end
end
