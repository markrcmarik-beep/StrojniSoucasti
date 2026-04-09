# ver: 2026-04-04
using Test
using StrojniSoucasti

@testset "profilyvlcnS - plocha prurezu" begin

    PLO_01 = Dict(
        :info => "PLO",
        :a => 20,
        :b => 10
    )

    PLO_02 = Dict(
        :info => "PLO",
        :a => 20,
        :b => 10,
        :R => 2
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

    _4HR_02 = Dict(
        :info => "4HR",
        :a => 20,
        :R => 3
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

    @testset "zakladni tvary" begin
        S, txt = StrojniSoucasti.profilyvlcnS(PLO_01)
        @test S == 200
        @test txt == "a*b"

        S2, txt2 = StrojniSoucasti.profilyvlcnS(KR_01)
        @test isapprox(S2, pi*(20/2)^2)
        @test occursin("D", txt2)

        S3, txt3 = StrojniSoucasti.profilyvlcnS(TRKR_01)
        @test isapprox(S3, pi*(20^2 - 10^2)/4)
        @test occursin("D", txt3) && occursin("d", txt3)

        S4, txt4 = StrojniSoucasti.profilyvlcnS(_4HR_01)
        @test S4 == 400
        @test occursin("a", txt4)

        S5, txt5 = StrojniSoucasti.profilyvlcnS(_6HR_01)
        @test S5 == 300
        @test occursin("3/4*s", txt5)

        S6, txt6 = StrojniSoucasti.profilyvlcnS(TR4HR_01, :S)
        @test S6 == 176
        @test txt6 == "a*b - (a-2t)*(b-2t)"
    end

    @testset "tvary s hranou R" begin
        S, txt = StrojniSoucasti.profilyvlcnS(PLO_02, :S)
        @test S >= 196.5 && S <= 196.6
        @test txt == "a*b - 4*S(R)"

        S2, txt2 = StrojniSoucasti.profilyvlcnS(_4HR_02, :S)
        @test S2 < 400
        @test occursin("4*S(R)", txt2)
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnS(Dict(:info => "XYZ"), :S)
    end
end
