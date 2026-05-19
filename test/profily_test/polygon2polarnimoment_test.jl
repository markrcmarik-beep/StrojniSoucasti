# ver: 2026-04-24
using Test
using StrojniSoucasti, Unitful

@testset "polygon2polarnimoment" begin
    # Obdelnik 4 x 3
    # Jp_teiste = Ix + Iy = 9 + 16 = 25
    Jp1 = StrojniSoucasti.polygon2polarnimoment([(0, 0), (4, 0), (4, 3), (0, 3)])
    @test Jp1 == 25.0

    # Opaecny smer bodu
    Jp2 = StrojniSoucasti.polygon2polarnimoment([(0, 0), (0, 3), (4, 3), (4, 0)])
    @test Jp2 == 25.0

    # Uzavreny polygon (prvni bod zopakovany)
    Jp3 = StrojniSoucasti.polygon2polarnimoment([(0, 0), (4, 0), (4, 3), (0, 3), (0, 0)])
    @test Jp3 == 25.0

    # Matice Nx2
    Jp4 = StrojniSoucasti.polygon2polarnimoment([0 0; 4 0; 4 3; 0 3])
    @test Jp4 == 25.0

    # Unitful vstup
    body_u = [(0u"mm", 0u"mm"), (4u"mm", 0u"mm"), (4u"mm", 3u"mm"), (0u"mm", 3u"mm")]
    Jp5 = StrojniSoucasti.polygon2polarnimoment(body_u)
    @test Jp5 == 25.0u"mm^4"

    # Obrys + prazdne otvory (NamedTuple)
    body6 = (
        obrys = [(0, 0), (4, 0), (4, 3), (0, 3)],
        otvory = (),
    )
    Jp6 = StrojniSoucasti.polygon2polarnimoment(body6)
    @test Jp6 == 25.0

    # Obrys + jeden otvor (soustredny ctverec)
    body7 = (
        obrys = [(0, 0), (10, 0), (10, 10), (0, 10)],
        otvory = [[(3, 3), (7, 3), (7, 7), (3, 7)]],
    )
    Jp7 = StrojniSoucasti.polygon2polarnimoment(body7)
    @test isapprox(Jp7, 1624.0; atol=1e-9)

    # Neplatne vstupy
    @test_throws ArgumentError StrojniSoucasti.polygon2polarnimoment([(0, 0), (1, 0)])
    @test_throws ArgumentError StrojniSoucasti.polygon2polarnimoment([0 0 0; 1 1 1; 2 2 2])
    @test_throws ArgumentError StrojniSoucasti.polygon2polarnimoment([(0, 0), (1, 0), (2, 0)])
end
