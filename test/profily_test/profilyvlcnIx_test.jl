# ver: 2026-02-26
using Test
using StrojniSoucasti
using Unitful

@testset "profilyvlcnIx - Ix, Iy" begin

    PLO_01 = Dict(
        :info => "PLO",
        :a => 20u"mm",
        :b => 10u"mm"
    )

    _6HR_01 = Dict(
        :info => "6HR",
        :s => 20u"mm"
    )

    @testset "zakladni vypocet" begin
        Ix0, txt0 = StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, 0)
        Iy0, txty = StrojniSoucasti.profilyvlcnIx(PLO_01, :Iy, 0)

        @test Ix0 == 20u"mm" * (10u"mm")^3 / 12
        @test Iy0 == 10u"mm" * (20u"mm")^3 / 12
        @test txt0 == "a*b^3/12"
        @test txty == "b*a^3/12"
    end

    @testset "normalizace uhlu" begin
        Ix_ref, _ = StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, 0)
        Ix_2pi, _ = StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, 2pi)
        Iy_2pi, _ = StrojniSoucasti.profilyvlcnIx(PLO_01, :Iy, 2pi)

        @test Ix_2pi == Ix_ref
        @test Iy_2pi == 10u"mm" * (20u"mm")^3 / 12

        Ix_hex_ref, _ = StrojniSoucasti.profilyvlcnIx(_6HR_01, :Ix, pi/6)
        Ix_hex_shift, _ = StrojniSoucasti.profilyvlcnIx(_6HR_01, :Ix, 13pi/6)
        @test Ix_hex_ref == Ix_hex_shift
    end

    @testset "chybove stavy" begin
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, pi/4) # Neplatný úhel pro obdélník
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, -pi/4) # Neplatný úhel pro obdélník
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, 3pi/4) # Neplatný úhel pro obdélník
        @test_throws ErrorException StrojniSoucasti.profilyvlcnIx(PLO_01, :Ix, -3pi/4) # Neplatný úhel pro obdélník
    end
end
