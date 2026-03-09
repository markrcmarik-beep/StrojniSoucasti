# ver: 2026-02-27
using Test
using StrojniSoucasti
using Unitful

@testset "profilyvlcnWk - modul v krutu" begin

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

    @testset "zakladni tvary" begin
        Wk1, txt1 = StrojniSoucasti.profilyvlcnWk(KR_01, :Wk)
        @test Wk1 ≈ pi/16*(20u"mm")^3
        @test txt1 == "π/16*D³"

        Wk2, txt2 = StrojniSoucasti.profilyvlcnWk(TRKR_01, :Wk)
        @test Wk2 ≈ pi/16*((20u"mm")^4 - (10u"mm")^4)/(20u"mm")
        @test txt2 == "π/16*(D⁴ - d⁴)/D"

        Wk3, txt3 = StrojniSoucasti.profilyvlcnWk(_4HR_01, :Wk)
        @test Wk3 == 0.208*(20u"mm")^3
        @test txt3 == "0.208*a³"

        Wk4, txt4 = StrojniSoucasti.profilyvlcnWk(PLO_01, :Wk)
        @test Wk4 ≈ (20u"mm")*(10u"mm")^3/3*(1 - 0.63*(10/20) + 0.052*(10/20)^5)
        @test occursin("a*b", txt4)

        Wk5, txt5 = StrojniSoucasti.profilyvlcnWk(OBD_01, :Wk)
        @test Wk5 ≈ (30u"mm")*(12u"mm")^3/3*(1 - 0.63*(12/30) + 0.052*(12/30)^5)
        @test occursin("0.052", txt5)

        Wk6, txt6 = StrojniSoucasti.profilyvlcnWk(_6HR_01, :Wk)
        @test Wk6 == 0.17*(20u"mm")^3
        @test txt6 == "0.17*s³"
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWk(Dict(:info => "TR4HR", :a => 20u"mm"), :Wk)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWk(Dict(:info => "XYZ"), :Wk)
    end
end
