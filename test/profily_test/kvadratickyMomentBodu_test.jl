# ver: 2026-04-19
using Test
using StrojniSoucasti, Unitful

@testset "kvadratickyMomentBodu" begin
    # Obdelnik 4 x 3 -> Ix = 4*3^3/12 = 9, Iy = 3*4^3/12 = 16
    M1 = StrojniSoucasti.kvadratickyMomentBodu([(0, 0), (4, 0), (4, 3), (0, 3)])
    @test M1.Ix == 9.0
    @test M1.Iy == 16.0

    # Opaecny smer bodu
    M2 = StrojniSoucasti.kvadratickyMomentBodu([(0, 0), (0, 3), (4, 3), (4, 0)])
    @test M2.Ix == 9.0
    @test M2.Iy == 16.0

    # Uzavreny polygon (prvni bod zopakovany)
    M3 = StrojniSoucasti.kvadratickyMomentBodu([(0, 0), (4, 0), (4, 3), (0, 3), (0, 0)])
    @test M3.Ix == 9.0
    @test M3.Iy == 16.0

    # Matice Nx2
    M4 = StrojniSoucasti.kvadratickyMomentBodu([0 0; 4 0; 4 3; 0 3])
    @test M4.Ix == 9.0
    @test M4.Iy == 16.0

    # Unitful vstup
    body_u = [(0u"mm", 0u"mm"), (4u"mm", 0u"mm"), (4u"mm", 3u"mm"), (0u"mm", 3u"mm")]
    M5 = StrojniSoucasti.kvadratickyMomentBodu(body_u)
    @test M5.Ix == 9.0u"mm^4"
    @test M5.Iy == 16.0u"mm^4"

    # Obrys + jeden otvor (soustredny ctverec)
    body6 = (
        obrys = [(0, 0), (10, 0), (10, 10), (0, 10)],
        otvory = [[(3, 3), (7, 3), (7, 7), (3, 7)]],
    )
    M6 = StrojniSoucasti.kvadratickyMomentBodu(body6)
    @test isapprox(M6.Ix, 812.0; atol=1e-9)
    @test isapprox(M6.Iy, 812.0; atol=1e-9)

    # Obrys + vice otvoru
    body7 = (
        obrys = [(0, 0), (10, 0), (10, 8), (0, 8)],
        otvory = [
            [(1, 1), (3, 1), (3, 3), (1, 3)],
            [(7, 5), (9, 5), (9, 7), (7, 7)],
        ],
    )
    M7 = StrojniSoucasti.kvadratickyMomentBodu(body7)
    @test isapprox(M7.Ix, 392.0; atol=1e-9)
    @test isapprox(M7.Iy, 592.0; atol=1e-9)

    # Neplatne vstupy
    @test_throws ArgumentError StrojniSoucasti.kvadratickyMomentBodu([(0, 0), (1, 0)])
    @test_throws ArgumentError StrojniSoucasti.kvadratickyMomentBodu([0 0 0; 1 1 1; 2 2 2])
    @test_throws ArgumentError StrojniSoucasti.kvadratickyMomentBodu([(0, 0), (1, 0), (2, 0)])
end
