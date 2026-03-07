# ver: 2026-02-27
using Test
using StrojniSoucasti
using Unitful

@testset "profilyvlcnS - plocha prurezu" begin

    PLO_01 = Dict(
        :info => "PLO",
        :a => 20u"mm",
        :b => 10u"mm"
    )

    PLO_02 = Dict(
        :info => "PLO",
        :a => 20u"mm",
        :b => 10u"mm",
        :R => 2u"mm"
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

    _4HR_02 = Dict(
        :info => "4HR",
        :a => 20u"mm",
        :R => 3u"mm"
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
        S, txt = StrojniSoucasti.profilyvlcnS(PLO_01, :S)
        @test S == 200u"mm^2"
        @test txt == "a*b"

        S2, txt2 = StrojniSoucasti.profilyvlcnS(KR_01, :S)
        @test S2 ≈ pi*(20u"mm"/2)^2
        @test occursin("D", txt2)

        S3, txt3 = StrojniSoucasti.profilyvlcnS(TRKR_01, :S)
        @test S3 ≈ pi*((20u"mm")^2 - (10u"mm")^2)/4
        @test occursin("D", txt3) && occursin("d", txt3)

        S4, txt4 = StrojniSoucasti.profilyvlcnS(_4HR_01, :S)
        @test S4 == 400u"mm^2"
        @test txt4 == "a²"

        S5, txt5 = StrojniSoucasti.profilyvlcnS(_6HR_01, :S)
        @test S5 == 300u"mm^2"
        @test txt5 == "3/4*s²"

        S6, txt6 = StrojniSoucasti.profilyvlcnS(TR4HR_01, :S)
        @test S6 == 176u"mm^2"
        @test txt6 == "a*b - (a-2t)*(b-2t)"
    end

    @testset "tvary s hranou R" begin
        S, txt = StrojniSoucasti.profilyvlcnS(PLO_02, :S)
        @test ustrip(u"mm^2", S) >= 196.5 && ustrip(u"mm^2", S) <= 196.6
        @test txt == "a*b - 4*S(R)"

        S2, txt2 = StrojniSoucasti.profilyvlcnS(_4HR_02, :S)
        @test S2 < 400u"mm^2"
        @test txt2 == "a² - 4*S(R)"
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnS(Dict(:info => "XYZ"), :S)
    end
end
