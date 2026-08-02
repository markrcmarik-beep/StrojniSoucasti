# ver: 2026-07-18
using Test
using StrojniSoucasti, Unitful

@testset "polygon2eonatoceni" begin
    body = [(0, 0), (4, 0), (4, 3), (0, 3)]
    
    # Jednoduchy polygon (obdelnik)
    @test StrojniSoucasti.polygon2eonatoceni(body) == 1.5
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body, pi/2), 2.0; atol=1e-12)
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body, pi/4), 3.5 / sqrt(2); atol=1e-12)

    # Vstup jako matice
    @test StrojniSoucasti.polygon2eonatoceni([0 0; 4 0; 4 3; 0 3]) == 1.5

    # Vstup s jednotkami
    body_u = [(0u"mm", 0u"mm"), (4u"mm", 0u"mm"), (4u"mm", 3u"mm"), (0u"mm", 3u"mm")]
    @test StrojniSoucasti.polygon2eonatoceni(body_u) == 1.5u"mm"

    # Opacny smer bodu
    body_rev = [(0, 0), (0, 3), (4, 3), (4, 0)]
    @test StrojniSoucasti.polygon2eonatoceni(body_rev) == 1.5
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_rev, pi/2), 2.0; atol=1e-12)

    # Uzavreny polygon (prvni bod zopakovany)
    body_closed = [(0, 0), (4, 0), (4, 3), (0, 3), (0, 0)]
    @test StrojniSoucasti.polygon2eonatoceni(body_closed) == 1.5

    # Nekonvexni polygon (profil U)
    body_u_shape = [(0,0), (10,0), (10,10), (0,10), (0,8), (8,8), (8,2), (0,2)]
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_u_shape, 0), 5.0; atol=1e-12)
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_u_shape, pi/2), 77/13; atol=1e-12)

    # Polygon s otvory
    body_s_otvorem = (
        obrys = [(0, 0), (10, 0), (10, 10), (0, 10)],
        otvory = [[(7, 4), (9, 4), (9, 6), (7, 6)]],
    )
    @test StrojniSoucasti.polygon2eonatoceni(body_s_otvorem, 0) == 5.0
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_s_otvorem, pi/2), 41 / 8; atol=1e-12)

    # Polygon s vice otvory
    body_s_vice_otvory = (
        obrys = [(0, 0), (10, 0), (10, 8), (0, 8)],
        otvory = [
            [(1, 1), (3, 1), (3, 3), (1, 3)],
            [(7, 5), (9, 5), (9, 7), (7, 7)],
        ],
    )
    # teziste (5, 4)
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_s_vice_otvory, 0), 4.0; atol=1e-12)
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_s_vice_otvory, pi/2), 5.0; atol=1e-12)

    # Polygon s prazdnym seznamem otvoru
    body_s_prazdnym_otvorem = (
        obrys = [(0, 0), (4, 0), (4, 3), (0, 3)],
        otvory = [],
    )
    @test StrojniSoucasti.polygon2eonatoceni(body_s_prazdnym_otvorem) == 1.5

    # Komplexni profil (I-profil)
    prof = StrojniSoucasti.profil_I_CSN425550("I80")
    body_i = StrojniSoucasti.body_I_CSN425550(prof, "stred")
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_i, 0), prof.h / 2; atol=1e-6)
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_i, pi/2), prof.b / 2; atol=1e-6)
    body_i2 = StrojniSoucasti.body_I_CSN425550(prof, "ld")
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_i2, 0), prof.h / 2; atol=1e-6)
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_i2, pi/2), prof.b / 2; atol=1e-6)
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_i2, pi/4), 43.133513652379634; atol=1e-6)

    # Specialni pripady
    @test StrojniSoucasti.polygon2eonatoceni(nothing) === nothing
    @test StrojniSoucasti.polygon2eonatoceni(nothing, 0) === nothing
    
    # Neplatne vstupy
    @test_throws ArgumentError StrojniSoucasti.polygon2eonatoceni([(0, 0), (1, 0)])
    @test_throws ArgumentError StrojniSoucasti.polygon2eonatoceni([0 0 0; 1 1 1; 2 2 2])
    @test_throws ArgumentError StrojniSoucasti.polygon2eonatoceni([(0, 0), (1, 0), (2, 0)])
    body_bad_hole = (
        obrys = [(0, 0), (10, 0), (10, 10), (0, 10)],
        otvory = [1, 2, 3],
    )
    @test_throws ArgumentError StrojniSoucasti.polygon2eonatoceni(body_bad_hole)
    @test_throws ArgumentError StrojniSoucasti.polygon2eonatoceni("not a polygon")
end

nothing
