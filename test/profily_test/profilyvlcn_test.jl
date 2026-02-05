# ver: 2026-01-31
using Test
using StrojniSoucasti
using Unitful

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

    # ------------------------------------------------------------
    # S – plocha průřezu
    # ------------------------------------------------------------
    @testset "S – plocha" begin
        S, txt = StrojniSoucasti.profilyvlcn(PLO_01, :S)
        @test ustrip(u"mm^2", S) == 200
        @test txt == "a*b"
 
        S, txt = StrojniSoucasti.profilyvlcn(PLO_02, :S)
        @test ustrip(u"mm^2", S) >= 196.5 && ustrip(u"mm^2", S) <= 196.6
        @test txt == "a*b - 4*S(R)"

        S2, txt2 = StrojniSoucasti.profilyvlcn(TRKR_01, :S)
        @test S2 ≈ pi*( (20u"mm")^2 - (10u"mm")^2 )/4
        @test txt2 == "π*(D² - d²)/4"
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
    # Wk – modul v krutu
    # ------------------------------------------------------------
    @testset "Wk – modul v krutu" begin
        Wk, txt = StrojniSoucasti.profilyvlcn(TRKR_01, :Wk)
        @test Wk ≈ pi/16 * ((20u"mm")^4 - (10u"mm")^4) / (20u"mm")
        @test txt == "π/16*(D⁴ - d⁴)/D"
    end

    # ------------------------------------------------------------
    # Ix – kvadratický moment
    # ------------------------------------------------------------
    @testset "Ix – kvadratický moment" begin
        Ix0, txt0 = StrojniSoucasti.profilyvlcn(PLO_01, :Ix, natoceni=0)
        Ix90, txt90 = StrojniSoucasti.profilyvlcn(PLO_01, :Ix, natoceni=pi/2)

        @test Ix0 == 20u"mm" * (10u"mm")^3 / 12
        @test Ix90 == 10u"mm" * (20u"mm")^3 / 12
        @test txt0 == "a*b³/12"
        @test txt90 == "b*a³/12"
    end

    # ------------------------------------------------------------
    # Iy – kvadratický moment
    # ------------------------------------------------------------
    @testset "Iy – kvadratický moment" begin
        Iy0, txt0 = StrojniSoucasti.profilyvlcn(PLO_01, :Iy)
        @test Iy0 == 10u"mm" * (20u"mm")^3 / 12
        @test txt0 == "b*a³/12"

        # Přímé volání profilyvlcnIx pro :Iy (delegace na :Ix s natočením)
        Iy_direct, txt_direct = StrojniSoucasti.profilyvlcnIx(PLO_01, :Iy)
        @test Iy_direct == 10u"mm" * (20u"mm")^3 / 12
        @test txt_direct == "b*a³/12"
    end

    # ------------------------------------------------------------
    # Symetrické tvary – ověření Ix == Iy a Ixy == 0
    # ------------------------------------------------------------
    @testset "Symetrické tvary" begin
        # Kruhová tyč (KR) – Ix == Iy a Ixy == 0
        Ix_k, _ = StrojniSoucasti.profilyvlcn(KR_01, :Ix)
        Iy_k, _ = StrojniSoucasti.profilyvlcn(KR_01, :Iy)
        Ixy_k, _ = StrojniSoucasti.profilyvlcn(KR_01, :Ixy)
        @test Ix_k == Iy_k
        @test Ixy_k == 0

        # Trubka kruhová (TRKR) – Ix == Iy a Ixy == 0
        Ix_tr, _ = StrojniSoucasti.profilyvlcn(TRKR_01, :Ix)
        Iy_tr, _ = StrojniSoucasti.profilyvlcn(TRKR_01, :Iy)
        Ixy_tr, _ = StrojniSoucasti.profilyvlcn(TRKR_01, :Ixy)
        @test Ix_tr == Iy_tr
        @test Ixy_tr == 0

        # Čtyřhranná tyč (4HR) – čtverec  (Ix == Iy a Ixy == 0)
        Ix_4, _ = StrojniSoucasti.profilyvlcn(_4HR_01, :Ix, natoceni=0)
        Iy_4, _ = StrojniSoucasti.profilyvlcn(_4HR_01, :Iy)
        Ixy_4, _ = StrojniSoucasti.profilyvlcn(_4HR_01, :Ixy)
        @test Ix_4 == Iy_4
        @test Ixy_4 == 0
    end

    # ------------------------------------------------------------
    # Imin – minimální kvadratický moment
    # ------------------------------------------------------------
    @testset "Imin – minimální kvadratický moment" begin
        Imin1, txt1 = StrojniSoucasti.profilyvlcn(TRKR_01, :Imin)
        @test Imin1 == pi/64 * ( (20u"mm")^4 - (10u"mm")^4 )
        @test txt1 == "π/64*(D⁴ - d⁴)"

        Imin2, txt2 = StrojniSoucasti.profilyvlcn(PLO_01, :Imin)
        @test Imin2 > 0u"mm^4"
        @test txt2 == "-sqrt((1//4)*((-(1//12)*(a^3)*b + (1//12)*a*(b^3))^2)) + (1//2)*((1//12)*(a^3)*b + (1//12)*a*(b^3))"
    end

    # ------------------------------------------------------------
    # Imax – minimální kvadratický moment
    # ------------------------------------------------------------
    @testset "Imax – minimální kvadratický moment" begin
        Imax1, txt1 = StrojniSoucasti.profilyvlcn(TRKR_01, :Imax)
        @test Imax1 == pi/64 * ( (20u"mm")^4 - (10u"mm")^4 )
        @test txt1 == "π/64*(D⁴ - d⁴)"

        Imax2, txt2 = StrojniSoucasti.profilyvlcn(PLO_01, :Imax)
        @test Imax2 > 0u"mm^4"
        @test txt2 == "(Ix + Iy)/2 + √( ((Ix - Iy)/2)² + Ixy² )"
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
    # Chybové stavy
    # ------------------------------------------------------------
    @testset "Chybové stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcn(PLO_01, :NeznamaVelicina)
        @test_throws ErrorException StrojniSoucasti.profilyvlcn(PLO_01, :Ix, natoceni=pi/4)
    end

    #S1 = StrojniSoucasti.profilyvlcn("PLO 20x30 R5", :S)
    #println(S1)

end
