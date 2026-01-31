# ver: 2026-01-31
using Test
using StrojniSoucasti
using Unitful
using Unitful.DefaultSymbols

@testset "profilyvlcn – základní geometrické veličiny" begin

    # ------------------------------------------------------------
    # Definice testovacích tvarů
    # ------------------------------------------------------------
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

    TRKR_01 = Dict(
        :info => "TRKR",
        :D => 20u"mm",
        :d => 10u"mm"
    )

    TR4HR_01 = Dict(
        :info => "TR4HR",
        :a => 20u"mm",
        :b => 10u"mm",
        :t => 4u"mm"
    )

    # ------------------------------------------------------------
    # S – plocha průřezu
    # ------------------------------------------------------------
    @testset "S – plocha" begin
        S, txt = StrojniSoucasti.profilyvlcn(PLO_01, :S)
        @test ustrip(u"mm^2", S) == 200
        @test txt == "a*b"

        S2, txt2 = StrojniSoucasti.profilyvlcn(TRKR_01, :S)
        @test S2 ≈ π*( (20u"mm")^2 - (10u"mm")^2 )/4
        @test txt2 == "π*(D² - d²)/4"
    end

    # ------------------------------------------------------------
    # Ix – kvadratický moment
    # ------------------------------------------------------------
    @testset "Ix – kvadratický moment" begin
        Ix0, txt0 = StrojniSoucasti.profilyvlcn(PLO_01, :Ix, natoceni=0)
        Ix90, txt90 = StrojniSoucasti.profilyvlcn(PLO_01, :Ix, natoceni=π/2)

        @test Ix0 == 20u"mm" * (10u"mm")^3 / 12
        @test Ix90 == 10u"mm" * (20u"mm")^3 / 12
        @test txt0 == "a*b³/12"
        @test txt90 == "b*a³/12"
    end

    # ------------------------------------------------------------
    # Wo – průřezový modul v ohybu
    # ------------------------------------------------------------
    @testset "Wo – modul v ohybu" begin
        Wo, txt = StrojniSoucasti.profilyvlcn(PLO_01, :Wo)
        @test Wo == 20u"mm" * (10u"mm")^2 / 6
        @test txt == "a*b²/6"
    end

    # ------------------------------------------------------------
    # Wk – modul v krutu
    # ------------------------------------------------------------
    @testset "Wk – modul v krutu" begin
        Wk, txt = StrojniSoucasti.profilyvlcn(TRKR_01, :Wk)
        @test Wk ≈ π/16 * ((20u"mm")^4 - (10u"mm")^4) / (20u"mm")
        @test txt == "π/16*(D⁴ - d⁴)/D"
    end

    # ------------------------------------------------------------
    # Ip – polární moment
    # ------------------------------------------------------------
    @testset "Ip – polární moment" begin
        Ip1, txt1 = StrojniSoucasti.profilyvlcn(PLO_02, :Ip)
        @test Ip1 > 0u"mm^4"
        @test occursin("a*b³", txt1)

        Ip2, txt2 = StrojniSoucasti.profilyvlcn(TR4HR_01, :Ip)
        @test Ip2 > 0u"mm^4"
        @test isa(txt2, String)
    end

    # ------------------------------------------------------------
    # Imin – minimální kvadratický moment
    # ------------------------------------------------------------
    @testset "Imin – minimální kvadratický moment" begin
        Imin1, txt1 = StrojniSoucasti.profilyvlcn(TRKR_01, :Imin)
        @test Imin1 == π/64 * ( (20u"mm")^4 - (10u"mm")^4 )
        @test txt1 == "π/64*(D⁴ - d⁴)"

        Imin2, txt2 = StrojniSoucasti.profilyvlcn(PLO_01, :Imin)
        @test Imin2 > 0u"mm^4"
        @test txt2 == "-sqrt((1//4)*((-(1//12)*(a^3)*b + (1//12)*a*(b^3))^2)) + (1//2)*((1//12)*(a^3)*b + (1//12)*a*(b^3))"
    end

    # ------------------------------------------------------------
    # Chybové stavy
    # ------------------------------------------------------------
    @testset "Chybové stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcn(PLO_01, :NeznamaVelicina)
        @test_throws ErrorException StrojniSoucasti.profilyvlcn(PLO_01, :Ix, natoceni=π/4)
    end

end
