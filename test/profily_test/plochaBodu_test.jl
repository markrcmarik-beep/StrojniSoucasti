# ver: 2026-04-08
using Test
using StrojniSoucasti, Unitful

@testset "plochaBodu" begin
    # Vektor bodu (tuples)
    S1 = plochaBodu([(0, 0), (4, 0), (4, 3), (0, 3)])
    @test S1 == 12.0

    # Opaecny smer bodu
    S2 = plochaBodu([(0, 0), (0, 3), (4, 3), (4, 0)])
    @test S2 == 12.0

    # Uzavreny polygon (prvni bod zopakovany)
    S3 = plochaBodu([(0, 0), (4, 0), (4, 3), (0, 3), (0, 0)])
    @test S3 == 12.0

    # Matice Nx2
    S4 = plochaBodu([0 0; 4 0; 4 3; 0 3])
    @test S4 == 12.0

    # Unitful vstup
    S5 = plochaBodu([(0u"mm", 0u"mm"), (4u"mm", 0u"mm"), (4u"mm", 3u"mm"), (0u"mm", 3u"mm")])
    @test S5 == 12.0u"mm^2"

    # Neplatne vstupy
    @test_throws ArgumentError plochaBodu([(0, 0), (1, 0)])
    @test_throws ArgumentError plochaBodu([0 0 0; 1 1 1; 2 2 2])
    @test_throws ArgumentError plochaBodu([(0, 0, 0), (1, 0, 0), (1, 1, 0)])
end

