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
        @test txt1 == "a*b²/6"

        Wo2, txt2 = StrojniSoucasti.profilyvlcnWo(PLO_01, :Wo, pi/2)
        @test isapprox(Wo2, 666.6666666666666, atol=1e-3)
        @test txt2 == "b*a²/6"

        Wo3, txt3 = StrojniSoucasti.profilyvlcnWo(KR_01, :Wo)
        @test isapprox(Wo3, 785.3981633974482, atol=1e-3)
        @test txt3 == "π/32*D³"

        Wo4, txt4 = StrojniSoucasti.profilyvlcnWo(TRKR_01, :Wo)
        @test isapprox(Wo4, 736.3107781851078, atol=1e-3)
        @test txt4 == "π/32*(D⁴ - d⁴)/D"

        Wo5, txt5 = StrojniSoucasti.profilyvlcnWo(_4HR_01, :Wo, 0)
        @test isapprox(Wo5, 1333.3333333333333, atol=1e-3)
        @test txt5 == "a³/6"

        Wo6, txt6 = StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, 0)
        @test isapprox(Wo6, 962.2504486493762, atol=1e-3)
        @test txt6 == "5√3/72*s³"

        Wo7, txt7 = StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, pi/6)
        @test isapprox(Wo7, 833.3333333333334, atol=1e-3)
        @test txt7 == "5/48*s³"
        Wo6, txt6 = StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, pi/5)
        @test isapprox(Wo6, 837.9235663029301, atol=1e-3)
        @test txt6 == "Ix / ymax, kde Ix = 5*sqrt(3)/144*s^4 a ymax = max_i|x_i*sin(angle) + y_i*cos(angle)|"

        Wo8, txt8 = StrojniSoucasti.profilyvlcnWo(TR4HR_01, :Wo, 0)
        @test isapprox(Wo8, 325.3333333333333, atol=1e-3)
        @test txt8 == "(a*b²/6)-((a-2t)*(b-2t)²/6)"
    end

    @testset "chybove stavy" begin
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnWo(PLO_01, :Wo, pi/4)
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnWo(_4HR_01, :Wo, pi/4)
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnWo(_6HR_01, :Wo, pi/5)
        #@test_throws ErrorException StrojniSoucasti.profilyvlcnWo(TR4HR_01, :Wo, pi/4)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnWo(Dict(:info => "XYZ"), :Wo)
    end
end
