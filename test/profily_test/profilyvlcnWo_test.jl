# ver: 2026-02-27
using Test
using StrojniSoucasti
using Unitful

@testset "profilyvlcnWo - modul v ohybu" begin

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

    @testset "zakladni tvary" begin
        Wo1, txt1 = StrojniSoucasti.profilyvlcnWo(PLO_01, :Wo, 0)
        @test Wo1 == 20u"mm" * (10u"mm")^2 / 6
        @test txt1 == "a*b²/6"

        Wo2, txt2 = StrojniSoucasti.profilyvlcnWo(PLO_01, :Wo, pi/2)
        @test Wo2 == 10u"mm" * (20u"mm")^2 / 6
        @test txt2 == "b*a²/6"

        Wo3, txt3 = StrojniSoucasti.profilyvlcnWo(KR_01, :Wo)
        @test Wo3 ≈ pi/32*(20u"mm")^3
        @test txt3 == "π/32*D³"

        Wo4, txt4 = StrojniSoucasti.profilyvlcnWo(TRKR_01, :Wo)
        @test Wo4 ≈ pi/32*((20u"mm")^4 - (10u"mm")^4)/(20u"mm")
        @test txt4 == "π/32*(D⁴ - d⁴)/D"

        Wo5, txt5 = StrojniSoucasti.profilyvlcnWo(_4HR_01, :Wo, 0)
        @test Wo5 == (20u"mm")^3 / 6
        @test txt5 == "a³/6"

        Wo6, txt6 = StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, 0)
        @test Wo6 ≈ 5*sqrt(3)/72*(20u"mm")^3
        @test txt6 == "5√3/72*s³"

        Wo7, txt7 = StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, pi/6)
        @test Wo7 == 5/48*(20u"mm")^3
        @test txt7 == "5/48*s³"

        Wo8, txt8 = StrojniSoucasti.profilyvlcnWo(TR4HR_01, :Wo, 0)
        @test Wo8 == (20u"mm")*(10u"mm")^2/6 - ((20u"mm"-2*4u"mm")*(10u"mm"-2*4u"mm")^2/6)
        @test txt8 == "(a*b²/6)-((a-2t)*(b-2t)²/6)"
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(PLO_01, :Wo, pi/4)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(_4HR_01, :Wo, pi/4)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, pi/5)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(TR4HR_01, :Wo, pi/4)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(Dict(:info => "XYZ"), :Wo)
    end
end
