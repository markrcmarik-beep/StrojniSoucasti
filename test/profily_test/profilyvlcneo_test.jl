# ver: 2026-07-11
using Test
using StrojniSoucasti, Unitful

@testset "profilyvlcneo" begin

    @testset "PLO / OBD" begin
        tvar = Dict(:info => "PLO", :a => ustrip(20u"mm"), :b => ustrip(10u"mm"))
        
        ex, ex_str = StrojniSoucasti.profilyvlcneo(tvar, :ex)
        @test ex ≈ 5.0
        @test ex_str == "b/2"

        ey, ey_str = StrojniSoucasti.profilyvlcneo(tvar, :ey)
        @test ey ≈ 10.0
        @test ey_str == "a/2"

        eo_0, _ = StrojniSoucasti.profilyvlcneo(tvar, :eo, 0)
        @test eo_0 ≈ 5.0

        eo_90, _ = StrojniSoucasti.profilyvlcneo(tvar, :eo, pi/2)
        @test eo_90 ≈ 10.0

        eo_45, eo_45_str = StrojniSoucasti.profilyvlcneo(tvar, :eo, pi/4)
        @test eo_45 ≈ 0.5 * (20 * sin(pi/4) + 10 * cos(pi/4))
        @test eo_45_str == "1/2 * (a * abs(sin(angle)) + b * abs(cos(angle)))"
    end

    @testset "KR / TRKR" begin
        tvar_kr = Dict(:info => "KR", :D => ustrip(30u"mm"))
        ex_kr, _ = StrojniSoucasti.profilyvlcneo(tvar_kr, :ex)
        ey_kr, _ = StrojniSoucasti.profilyvlcneo(tvar_kr, :ey)
        eo_kr, _ = StrojniSoucasti.profilyvlcneo(tvar_kr, :eo, pi/6) # arbitrary angle
        @test ex_kr == 15.0
        @test ey_kr == 15.0
        @test eo_kr == 15.0

        tvar_trkr = Dict(:info => "TRKR", :D => ustrip(40u"mm"), :t => ustrip(5u"mm"))
        ex_trkr, _ = StrojniSoucasti.profilyvlcneo(tvar_trkr, :ex)
        ey_trkr, _ = StrojniSoucasti.profilyvlcneo(tvar_trkr, :ey)
        eo_trkr, _ = StrojniSoucasti.profilyvlcneo(tvar_trkr, :eo, pi/3)
        @test ex_trkr == 20.0
        @test ey_trkr == 20.0
        @test eo_trkr == 20.0
    end

    @testset "4HR" begin
        # Square
        tvar_sq = Dict(:info => "4HR", :a => ustrip(20u"mm"), :b => ustrip(20u"mm"))
        ex_sq, _ = StrojniSoucasti.profilyvlcneo(tvar_sq, :ex)
        ey_sq, _ = StrojniSoucasti.profilyvlcneo(tvar_sq, :ey)
        @test ex_sq == 10.0
        @test ey_sq == 10.0

        eo_sq_45, _ = StrojniSoucasti.profilyvlcneo(tvar_sq, :eo, pi/4)
        @test eo_sq_45 ≈ 10.0 * sqrt(2)

        # Rectangle
        tvar_rect = Dict(:info => "4HR", :a => ustrip(30u"mm"), :b => ustrip(20u"mm"))
        ex_rect, _ = StrojniSoucasti.profilyvlcneo(tvar_rect, :ex)
        ey_rect, _ = StrojniSoucasti.profilyvlcneo(tvar_rect, :ey)
        @test ex_rect == 10.0
        @test ey_rect == 15.0
    end

    @testset "6HR" begin
        tvar = Dict(:info => "6HR", :s => ustrip(30u"mm"))

        ex, _ = StrojniSoucasti.profilyvlcneo(tvar, :ex)
        @test ex == 15.0

        ey, _ = StrojniSoucasti.profilyvlcneo(tvar, :ey)
        @test ey ≈ 30 / sqrt(3)

        eo_0, _ = StrojniSoucasti.profilyvlcneo(tvar, :eo, 0)
        @test eo_0 == 15.0

        eo_30, _ = StrojniSoucasti.profilyvlcneo(tvar, :eo, pi/6)
        @test eo_30 ≈ 30 / sqrt(3)

        eo_15, eo_15_str = StrojniSoucasti.profilyvlcneo(tvar, :eo, pi/12)
        @test eo_15 ≈ 30 / sqrt(3) * cos(abs(mod(pi/12 + pi/6, pi/3) - pi/6))
        @test eo_15_str == "s / √3 * cos(abs(mod(angle + π/6, π/3) - π/6))"
    end

    @testset "TR4HR" begin
        tvar = Dict(:info => "TR4HR", :a => ustrip(50u"mm"), :b => ustrip(30u"mm"), :t => ustrip(5u"mm"))

        ex, _ = StrojniSoucasti.profilyvlcneo(tvar, :ex)
        @test ex == 15.0

        ey, _ = StrojniSoucasti.profilyvlcneo(tvar, :ey)
        @test ey == 25.0

        eo_0, _ = StrojniSoucasti.profilyvlcneo(tvar, :eo, 0)
        @test eo_0 == 15.0

        eo_90, _ = StrojniSoucasti.profilyvlcneo(tvar, :eo, pi/2)
        @test eo_90 == 25.0

        eo_60, _ = StrojniSoucasti.profilyvlcneo(tvar, :eo, pi/3)
        @test eo_60 ≈ 0.5 * (50 * abs(sin(pi/3)) + 30 * abs(cos(pi/3)))
    end

    @testset "Error handling" begin
        tvar_bad = Dict(:info => "NEEXISTUJE", :a => ustrip(10u"mm"))
        @test_throws ErrorException StrojniSoucasti.profilyvlcneo(tvar_bad, :ex)

        tvar_plo = Dict(:info => "PLO", :a => ustrip(10u"mm")) # Missing 'b'
        @test_throws ErrorException StrojniSoucasti.profilyvlcneo(tvar_plo, :ex)
    end

end

nothing
