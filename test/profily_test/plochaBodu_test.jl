# ver: 2026-04-08
using Test
using StrojniSoucasti, Unitful

@testset "plochaBodu" begin
    # Vektor bodu (tuples)
    S1 = StrojniSoucasti.plochaBodu([(0, 0), (4, 0), (4, 3), (0, 3)])
    @test S1 == 12.0

    # Opaecny smer bodu
    S2 = StrojniSoucasti.plochaBodu([(0, 0), (0, 3), (4, 3), (4, 0)])
    @test S2 == 12.0

    # Uzavreny polygon (prvni bod zopakovany)
    S3 = StrojniSoucasti.plochaBodu([(0, 0), (4, 0), (4, 3), (0, 3), (0, 0)])
    @test S3 == 12.0

    # profil IPE 200 bez R
    S6 = StrojniSoucasti.plochaBodu([(0, 0), (100, 0), (100, 8.5), (50+5.6/2, 8.5), 
        (50+5.6/2, 200-8.5), (100, 200-8.5), (100, 200), (0, 200), (0, 200-8.5), 
        (50-5.6/2, 200-8.5), (50-5.6/2, 8.5), (0, 8.5)])
    @test S6 == 2724.799999999999
    #print("S6 = ", S6, " mm^2\n")
    S6apo = [(100, 8.5), (50+5.6/2, 8.5), (50+5.6/2, 200-8.5)]
    S6a = StrojniSoucasti.plochaBodu([(0, 0), (100, 0), S6apo...
        , (100, 200-8.5), (100, 200), (0, 200), (0, 200-8.5), 
        (50-5.6/2, 200-8.5), (50-5.6/2, 8.5), (0, 8.5)])
    @test S6a == 2724.799999999999
    S6b = StrojniSoucasti.plochaBodu([(0, 0), (100, 0), (100, 8.5), 
        (50+5.6/2+12, 8.5), (50+5.6/2, 8.5+12),
        (50+5.6/2, 200-8.5-12), (50+5.6/2+12, 200-8.5), 
        (100, 200-8.5), (100, 200), (0, 200), (0, 200-8.5), 
        (50-5.6/2-12, 200-8.5), (50-5.6/2, 200-8.5-12),
        (50-5.6/2, 8.5+12), (50-5.6/2-12, 8.5),
        (0, 8.5)])
    #@test S6b == 2724.799999999999
    print("S6b = ", S6b, " mm^2\n")

    # Matice Nx2
    S4 = StrojniSoucasti.plochaBodu([0 0; 4 0; 4 3; 0 3])
    @test S4 == 12.0

    # Unitful vstup
    S5 = StrojniSoucasti.plochaBodu([(0u"mm", 0u"mm"), (4u"mm", 0u"mm"), (4u"mm", 3u"mm"), (0u"mm", 3u"mm")])
    @test S5 == 12.0u"mm^2"

    # Neplatne vstupy
    @test_throws ArgumentError StrojniSoucasti.plochaBodu([(0, 0), (1, 0)])
    @test_throws ArgumentError StrojniSoucasti.plochaBodu([0 0 0; 1 1 1; 2 2 2])
    @test_throws ArgumentError StrojniSoucasti.plochaBodu([(0, 0, 0), (1, 0, 0), (1, 1, 0)])
end

