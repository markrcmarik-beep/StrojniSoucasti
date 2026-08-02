# ver: 2026-07-11
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

    KR_01a = Dict(
        :info => "KR",
        :D => 20,
        :d => 0
    )
    KR_01b = Dict(
        :info => "KR",
        :D => 20
    )
    KR_02 = Dict(
        :info => "KR",
        :D => 20,
        :d => 10
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
        :s => 20/sqrt(3) # s = 20
    )

    TR4HR_01 = Dict(
        :info => "TR4HR",
        :a => 20,
        :b => 10,
        :t => 4
    )

    @testset "zakladni tvary" begin
        S1, txt1 = StrojniSoucasti.profilyvlcnS(PLO_01)
        @test isapprox(S1, 200, atol=1e-3)
        @test txt1 == "a*b"

        S2, txt2 = StrojniSoucasti.profilyvlcnS(KR_01a)
        @test isapprox(S2, 314.1592653589793, atol=1e-3)
        @test txt2 == "π*(D/2)²"
        S2, txt2 = StrojniSoucasti.profilyvlcnS(KR_01b)
        @test isapprox(S2, 314.1592653589793, atol=1e-3)
        @test txt2 == "π*(D/2)²"

        S2, txt2 = StrojniSoucasti.profilyvlcnS(KR_02)
        @test isapprox(S2, 235.61944901923448, atol=1e-3)
        @test txt2 == "π*(D² - d²)/4"

        S3, txt3 = StrojniSoucasti.profilyvlcnS(TRKR_01)
        @test isapprox(S3, 235.61944901923448, atol=1e-3)
        @test occursin("D", txt3) && occursin("d", txt3)

        S4, txt4 = StrojniSoucasti.profilyvlcnS(_4HR_01)
        @test isapprox(S4, 400, atol=1e-3)
        @test txt4 == "a²"

        S5, txt5 = StrojniSoucasti.profilyvlcnS(_6HR_01)
        @test isapprox(S5, 115.47005383792518, atol=1e-3)
        @test txt5 == "sqrt(3)/2*s^2"

        S6, txt6 = StrojniSoucasti.profilyvlcnS(TR4HR_01, :S)
        @test isapprox(S6, 176, atol=1e-3)
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

nothing
