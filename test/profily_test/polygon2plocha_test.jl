# ver: 2026-04-28
using Test
using StrojniSoucasti, Unitful

@testset "polygon2plocha" begin
    # Vektor bodu (tuples)
    S1 = StrojniSoucasti.polygon2plocha([(0, 0), (4, 0), (4, 3), (0, 3)])
    @test S1 == 12.0

    # Opaecny smer bodu
    S2 = StrojniSoucasti.polygon2plocha([(0, 0), (0, 3), (4, 3), (4, 0)])
    @test S2 == 12.0

    # Uzavreny polygon (prvni bod zopakovany)
    S3 = StrojniSoucasti.polygon2plocha([(0, 0), (4, 0), (4, 3), (0, 3), (0, 0)])
    @test S3 == 12.0

    # profil IPE 200 bez R
    S6 = StrojniSoucasti.polygon2plocha([(0, 0), (100, 0), (100, 8.5), (50+5.6/2, 8.5), 
        (50+5.6/2, 200-8.5), (100, 200-8.5), (100, 200), (0, 200), (0, 200-8.5), 
        (50-5.6/2, 200-8.5), (50-5.6/2, 8.5), (0, 8.5)])
    @test isapprox(S6, 2724.799; atol=0.001)

    S6apo = [(100, 8.5), (50+5.6/2, 8.5), (50+5.6/2, 200-8.5)]
    S6a = StrojniSoucasti.polygon2plocha([(0, 0), (100, 0), S6apo...
        , (100, 200-8.5), (100, 200), (0, 200), (0, 200-8.5), 
        (50-5.6/2, 200-8.5), (50-5.6/2, 8.5), (0, 8.5)])
    @test isapprox(S6a, 2724.799; atol=0.001)
    
    R = 12
    b_plus = StrojniSoucasti.brsb2body((50+5.6/2+R, 8.5), R, "-", (50+5.6/2, 8.5+R), 0.8)
    b_plus1 = StrojniSoucasti.brsb2body((50+5.6/2+R, 8.5), R, "-", (50+5.6/2, 8.5+R), 0.01)
    b_plus2 = StrojniSoucasti.brsb2body((50+5.6/2, 200-8.5-R), R, "-", (50+5.6/2+R, 200-8.5), 0.01)
    b_plus3 = StrojniSoucasti.brsb2body((50-5.6/2-R, 200-8.5), R, "-", (50-5.6/2, 200-8.5-R), 0.01)
    b_plus4 = StrojniSoucasti.brsb2body((50-5.6/2, 8.5+R), R, "-", (50-5.6/2-R, 8.5), 0.01)
    S6b = StrojniSoucasti.polygon2plocha([(0, 0), (100, 0), (100, 8.5), 
        b_plus1..., b_plus2..., 
        (100, 200-8.5), (100, 200), (0, 200), (0, 200-8.5), 
        b_plus3..., b_plus4...,
        (0, 8.5)])
    @test isapprox(S6b, 2848.41; atol=0.001)

    # Matice Nx2
    S4 = StrojniSoucasti.polygon2plocha([0 0; 4 0; 4 3; 0 3])
    @test S4 == 12.0

    # Unitful vstup
    S5 = StrojniSoucasti.polygon2plocha([(0u"mm", 0u"mm"), (4u"mm", 0u"mm"), (4u"mm", 3u"mm"), (0u"mm", 3u"mm")])
    @test S5 == 12.0u"mm^2"

    # Obrys + otvor zadane v jedne promenne
    body7 = (
        obrys = [(0, 0), (10, 0), (10, 10), (0, 10)],
        otvory = [[(3, 3), (7, 3), (7, 7), (3, 7)]],
    )
    S7 = StrojniSoucasti.polygon2plocha(body7)
    @test S7 == 84.0

    # Jeden otvor lze zadat i primo jako polygon
    body8 = (
        obrys = [(0, 0), (10, 0), (10, 10), (0, 10)],
        otvory = [(3, 3), (7, 3), (7, 7), (3, 7)],
    )
    S8 = StrojniSoucasti.polygon2plocha(body8)
    @test S8 == 84.0

    # Vice otvoru (kolekce polygonu)
    body9 = (
        obrys = [(0, 0), (10, 0), (10, 10), (0, 10)],
        otvory = [
            [(1, 1), (3, 1), (3, 3), (1, 3)],   # 4
            [(5, 5), (9, 5), (9, 9), (5, 9)],   # 16
        ],
    )
    S9 = StrojniSoucasti.polygon2plocha(body9)
    @test S9 == 80.0

    # Vice otvoru lze zadat i jako tuple polygonu
    body10 = (
        obrys = [(0, 0), (10, 0), (10, 10), (0, 10)],
        otvory = (
            [(1, 1), (3, 1), (3, 3), (1, 3)],
            [(5, 5), (9, 5), (9, 9), (5, 9)],
        ),
    )
    S10 = StrojniSoucasti.polygon2plocha(body10)
    @test S10 == 80.0

    # Neplatne vstupy
    @test_throws ArgumentError StrojniSoucasti.polygon2plocha([(0, 0), (1, 0)])
    @test_throws ArgumentError StrojniSoucasti.polygon2plocha([0 0 0; 1 1 1; 2 2 2])
    @test_throws ArgumentError StrojniSoucasti.polygon2plocha([(0, 0, 0), (1, 0, 0), (1, 1, 0)])
end
