# ver: 2026-05-21
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
        @test isapprox(Wo1, 333.3333333333333, atol=1e-3)
        @test occursin("a*b", txt1)

        Wo2, txt2 = StrojniSoucasti.profilyvlcnWo(PLO_01, :Wo, pi/2)
        @test isapprox(Wo2, 666.6666666666666, atol=1e-3)
        @test occursin("b*a", txt2)

        Wo3, txt3 = StrojniSoucasti.profilyvlcnWo(KR_01, :Wo)
        @test isapprox(Wo3, 785.3981633974482, atol=1e-3)
        @test occursin("D", txt3)

        Wo4, txt4 = StrojniSoucasti.profilyvlcnWo(TRKR_01, :Wo)
        @test isapprox(Wo4, 736.3107781851078, atol=1e-3)
        @test occursin("D", txt4) && occursin("d", txt4)

        Wo5, txt5 = StrojniSoucasti.profilyvlcnWo(_4HR_01, :Wo, 0)
        @test isapprox(Wo5, 1333.3333333333333, atol=1e-3)
        @test occursin("a", txt5)

        Wo6, txt6 = StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, 0)
        @test isapprox(Wo6, 962.2504486493762, atol=1e-3)
        @test occursin("s", txt6)

        Wo7, txt7 = StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, pi/6)
        @test isapprox(Wo7, 833.3333333333334, atol=1e-3)
        @test occursin("5/48", txt7)
        Wo6, txt6 = StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, pi/5)
        @test isapprox(Wo6, 837.9235663029301, atol=1e-3)
        @test occursin("Ix / ymax", txt6)

        Wo8, txt8 = StrojniSoucasti.profilyvlcnWo(TR4HR_01, :Wo, 0)
        @test isapprox(Wo8, 325.3333333333333, atol=1e-3)
        @test occursin("a-2t", txt8)
    end

    @testset "chybove stavy" begin
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnWo(PLO_01, :Wo, pi/4)
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnWo(_4HR_01, :Wo, pi/4)
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, pi/5)
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnWo(TR4HR_01, :Wo, pi/4)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(Dict(:info => "XYZ"), :Wo)
    end
end
