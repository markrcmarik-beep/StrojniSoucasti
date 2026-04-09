# ver: 2026-04-04
using Test
using StrojniSoucasti

@testset "profilyvlcnWo - modul v ohybu" begin

    PLO_01 = Dict(
        :info => "PLO",
        :a => 20,
        :b => 10
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
        :t => 4
    )

    @testset "zakladni tvary" begin
        Wo1, txt1 = StrojniSoucasti.profilyvlcnWo(PLO_01, :Wo, 0)
        @test Wo1 == 20 * 10^2 / 6
        @test occursin("a*b", txt1)

        Wo2, txt2 = StrojniSoucasti.profilyvlcnWo(PLO_01, :Wo, pi/2)
        @test Wo2 == 10 * 20^2 / 6
        @test occursin("b*a", txt2)

        Wo3, txt3 = StrojniSoucasti.profilyvlcnWo(KR_01, :Wo)
        @test isapprox(Wo3, pi/32 * 20^3)
        @test occursin("D", txt3)

        Wo4, txt4 = StrojniSoucasti.profilyvlcnWo(TRKR_01, :Wo)
        @test isapprox(Wo4, pi/32 * (20^4 - 10^4) / 20)
        @test occursin("D", txt4) && occursin("d", txt4)

        Wo5, txt5 = StrojniSoucasti.profilyvlcnWo(_4HR_01, :Wo, 0)
        @test Wo5 == 20^3 / 6
        @test occursin("a", txt5)

        Wo6, txt6 = StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, 0)
        @test isapprox(Wo6, 5 * sqrt(3) / 72 * 20^3)
        @test occursin("s", txt6)

        Wo7, txt7 = StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, pi/6)
        @test isapprox(Wo7, 5 / 48 * 20^3)
        @test occursin("5/48", txt7)

        Wo8, txt8 = StrojniSoucasti.profilyvlcnWo(TR4HR_01, :Wo, 0)
        @test Wo8 == (20 * 10^2 / 6) - ((20 - 2 * 4) * (10 - 2 * 4)^2 / 6)
        @test occursin("a-2t", txt8)
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(PLO_01, :Wo, pi/4)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(_4HR_01, :Wo, pi/4)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, pi/5)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(TR4HR_01, :Wo, pi/4)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(Dict(:info => "XYZ"), :Wo)
    end
end
