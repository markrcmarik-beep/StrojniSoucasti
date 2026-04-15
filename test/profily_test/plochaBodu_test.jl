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
    @test isapprox(S6, 2724.799; atol=0.001)

    S6apo = [(100, 8.5), (50+5.6/2, 8.5), (50+5.6/2, 200-8.5)]
    S6a = StrojniSoucasti.plochaBodu([(0, 0), (100, 0), S6apo...
        , (100, 200-8.5), (100, 200), (0, 200), (0, 200-8.5), 
        (50-5.6/2, 200-8.5), (50-5.6/2, 8.5), (0, 8.5)])
    @test isapprox(S6a, 2724.799; atol=0.001)
    
    R = 12
    b_plus = StrojniSoucasti.obloukBodu((50+5.6/2+R, 8.5), (50+5.6/2, 8.5+R), R, "-", 0.8)
    b_plus1 = StrojniSoucasti.obloukBodu((50+5.6/2+R, 8.5), (50+5.6/2, 8.5+R), R, "-", 0.01)
    b_plus2 = StrojniSoucasti.obloukBodu((50+5.6/2, 200-8.5-R), (50+5.6/2+R, 200-8.5), R, "-", 0.01)
    b_plus3 = StrojniSoucasti.obloukBodu((50-5.6/2-R, 200-8.5), (50-5.6/2, 200-8.5-R), R, "-", 0.01)
    b_plus4 = StrojniSoucasti.obloukBodu((50-5.6/2, 8.5+R), (50-5.6/2-R, 8.5), R, "-", 0.01)
    S6b = StrojniSoucasti.plochaBodu([(0, 0), (100, 0), (100, 8.5), 
        b_plus1..., b_plus2..., 
        (100, 200-8.5), (100, 200), (0, 200), (0, 200-8.5), 
        b_plus3..., b_plus4...,
        (0, 8.5)])
    @test isapprox(S6b, 2848.41; atol=0.001)

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

