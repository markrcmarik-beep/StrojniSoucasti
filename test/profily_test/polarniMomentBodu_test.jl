# ver: 2026-04-08
using Test
using StrojniSoucasti, Unitful

@testset "polarniMomentBodu" begin
    # Obdelnik 4 x 3
    # Jp_teiste = Ix + Iy = 9 + 16 = 25
    Jp1 = polarniMomentBodu([(0, 0), (4, 0), (4, 3), (0, 3)])
    @test Jp1 == 25.0

    # Opaecny smer bodu
    Jp2 = polarniMomentBodu([(0, 0), (0, 3), (4, 3), (4, 0)])
    @test Jp2 == 25.0

    # Uzavreny polygon (prvni bod zopakovany)
    Jp3 = polarniMomentBodu([(0, 0), (4, 0), (4, 3), (0, 3), (0, 0)])
    @test Jp3 == 25.0

    # Matice Nx2
    Jp4 = polarniMomentBodu([0 0; 4 0; 4 3; 0 3])
    @test Jp4 == 25.0

    # Unitful vstup
    body_u = [(0u"mm", 0u"mm"), (4u"mm", 0u"mm"), (4u"mm", 3u"mm"), (0u"mm", 3u"mm")]
    Jp5 = polarniMomentBodu(body_u)
    @test Jp5 == 25.0u"mm^4"

    # Neplatne vstupy
    @test_throws ArgumentError polarniMomentBodu([(0, 0), (1, 0)])
    @test_throws ArgumentError polarniMomentBodu([0 0 0; 1 1 1; 2 2 2])
    @test_throws ArgumentError polarniMomentBodu([(0, 0), (1, 0), (2, 0)])
end
