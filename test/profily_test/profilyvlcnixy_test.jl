# ver: 2026-07-11
using Test
using StrojniSoucasti

@testset "profilyvlcnixy" begin

    @testset "PLO / OBD" begin
        tvar = Dict(:info => "PLO", :a => 20, :b => 10)
        S = 20 * 10
        Ix = 20 * 10^3 / 12 # a * b^3 / 12
        Iy = 10 * 20^3 / 12 # b * a^3 / 12

        ix, ix_str = StrojniSoucasti.profilyvlcnixy(tvar, :ix)
        @test ix ≈ sqrt(Ix / S)
        @test ix_str == "sqrt(Ix/S)"

        iy, iy_str = StrojniSoucasti.profilyvlcnixy(tvar, :iy)
        @test iy ≈ sqrt(Iy / S)
        @test iy_str == "sqrt(Iy/S)"

        # Test s natočením
        angle = pi/4
        I_45 = (Ix + Iy)/2 + (Ix - Iy)/2 * cos(2*angle) # Iu
        i_45, i_45_str = StrojniSoucasti.profilyvlcnixy(tvar, :i, angle)
        @test i_45 ≈ sqrt(I_45 / S)
        @test i_45_str == "sqrt(I/S)"
    end

    @testset "KR / TRKR (symmetrical)" begin
        tvar_kr = Dict(:info => "KR", :D => 30)
        ix_kr, _ = StrojniSoucasti.profilyvlcnixy(tvar_kr, :ix)
        iy_kr, _ = StrojniSoucasti.profilyvlcnixy(tvar_kr, :iy)
        @test ix_kr == iy_kr
        @test ix_kr ≈ 30/4

        tvar_trkr = Dict(:info => "TRKR", :D => 40, :d => 30) # t=5
        ix_trkr, _ = StrojniSoucasti.profilyvlcnixy(tvar_trkr, :ix)
        iy_trkr, _ = StrojniSoucasti.profilyvlcnixy(tvar_trkr, :iy)
        @test ix_trkr == iy_trkr
        @test ix_trkr ≈ sqrt(40^2 + 30^2) / 4
    end

    @testset "4HR / TR4HR" begin
        tvar = Dict(:info => "4HR", :a => 30, :b => 20)
        S = 30 * 20
        Ix = 30 * 20^3 / 12 # a * b^3 / 12
        Iy = 20 * 30^3 / 12 # b * a^3 / 12

        ix, _ = StrojniSoucasti.profilyvlcnixy(tvar, :ix)
        @test ix ≈ 4.714045207910317

        iy, _ = StrojniSoucasti.profilyvlcnixy(tvar, :iy)
        @test iy ≈ 7.0710678118654755
    end

    @testset "6HR (symmetrical)" begin
        tvar = Dict(:info => "6HR", :s => 30)
        ix, _ = StrojniSoucasti.profilyvlcnixy(tvar, :ix)
        iy, _ = StrojniSoucasti.profilyvlcnixy(tvar, :iy)
        @test ix ≈ 7.905694150420948
        @test iy ≈ 7.905694150420948

        s = 30
        Ix = 5 * sqrt(3) / 16 * s^4
        S = 3 * sqrt(3) / 2 * s^2
        @test ix ≈ 7.905694150420948
    end

    @testset "Error handling" begin
        tvar_bad = Dict(:info => "NEEXISTUJE", :a => 10)
        @test_throws ErrorException StrojniSoucasti.profilyvlcnixy(tvar_bad, :ix)

        tvar_plo = Dict(:info => "PLO", :a => 10) # Chybí 'b'
        @test_throws ErrorException StrojniSoucasti.profilyvlcnixy(tvar_plo, :ix)
    end

end

nothing
