# ver: 2026-07-11
using Test
using StrojniSoucasti

@testset "profilyvlcnrmax" begin

    @testset "PLO / OBD" begin
        tvar = Dict(:info => "PLO", :a => 20, :b => 10)
        rmax, rmax_str = StrojniSoucasti.profilyvlcnrmax(tvar)
        @test rmax ≈ sqrt(20^2 + 10^2) / 2
        @test rmax_str == "sqrt(a^2 + b^2)/2"
    end

    @testset "KR / TRKR" begin
        tvar_kr = Dict(:info => "KR", :D => 30)
        rmax_kr, rmax_kr_str = StrojniSoucasti.profilyvlcnrmax(tvar_kr)
        @test rmax_kr == 15.0
        @test rmax_kr_str == "D/2"

        tvar_trkr = Dict(:info => "TRKR", :D => 40, :t => 5)
        rmax_trkr, rmax_trkr_str = StrojniSoucasti.profilyvlcnrmax(tvar_trkr)
        @test rmax_trkr == 20.0
        @test rmax_trkr_str == "D/2"
    end

    @testset "4HR" begin
        # Square
        tvar_sq = Dict(:info => "4HR", :a => 20, :b => 20)
        rmax_sq, rmax_sq_str = StrojniSoucasti.profilyvlcnrmax(tvar_sq)
        @test rmax_sq ≈ sqrt(20^2 + 20^2) / 2
        @test rmax_sq_str == "sqrt(a^2 + b^2)/2"

        # Rectangle
        tvar_rect = Dict(:info => "4HR", :a => 30, :b => 20)
        rmax_rect, rmax_rect_str = StrojniSoucasti.profilyvlcnrmax(tvar_rect)
        @test rmax_rect ≈ sqrt(30^2 + 20^2) / 2
        @test rmax_rect_str == "sqrt(a^2 + b^2)/2"
    end

    @testset "6HR" begin
        tvar = Dict(:info => "6HR", :s => 30)
        rmax, rmax_str = StrojniSoucasti.profilyvlcnrmax(tvar)
        @test rmax ≈ 30 / sqrt(3)
        @test rmax_str == "s/sqrt(3)"
    end

    @testset "TR4HR" begin
        tvar = Dict(:info => "TR4HR", :a => 50, :b => 30, :t => 5)
        rmax, rmax_str = StrojniSoucasti.profilyvlcnrmax(tvar)
        @test rmax ≈ sqrt(50^2 + 30^2) / 2
        @test rmax_str == "sqrt(a^2 + b^2)/2"
    end

    @testset "Error handling" begin
        tvar_bad = Dict(:info => "NEEXISTUJE", :a => 10)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnrmax(tvar_bad)

        tvar_plo = Dict(:info => "PLO", :a => 10) # Missing 'b'
        @test_throws ErrorException StrojniSoucasti.profilyvlcnrmax(tvar_plo)
    end

end

nothing