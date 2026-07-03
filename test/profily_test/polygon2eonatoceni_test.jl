# ver: 2026-07-03
using Test
using StrojniSoucasti, Unitful

@testset "polygon2eonatoceni" begin
    body = [(0, 0), (4, 0), (4, 3), (0, 3)]

    @test StrojniSoucasti.polygon2eonatoceni(body) == 1.5
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body, pi/2), 2.0; atol=1e-12)
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body, pi/4), 3.5 / sqrt(2); atol=1e-12)

    @test StrojniSoucasti.polygon2eonatoceni([0 0; 4 0; 4 3; 0 3]) == 1.5

    body_u = [(0u"mm", 0u"mm"), (4u"mm", 0u"mm"), (4u"mm", 3u"mm"), (0u"mm", 3u"mm")]
    @test StrojniSoucasti.polygon2eonatoceni(body_u) == 1.5u"mm"

    body_s_otvorem = (
        obrys = [(0, 0), (10, 0), (10, 10), (0, 10)],
        otvory = [[(7, 4), (9, 4), (9, 6), (7, 6)]],
    )
    @test StrojniSoucasti.polygon2eonatoceni(body_s_otvorem, 0) == 5.0
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_s_otvorem, pi/2), 41 / 8; atol=1e-12)

    prof = StrojniSoucasti.profil_I_CSN425550("I80")
    body_i = StrojniSoucasti.body_I_CSN425550(prof, "stred")
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_i, 0), prof.h / 2; atol=1e-6)
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_i, pi/2), prof.b / 2; atol=1e-6)
    body_i2 = StrojniSoucasti.body_I_CSN425550(prof, "ld")
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_i2, 0), prof.h / 2; atol=1e-6)
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_i2, pi/2), prof.b / 2; atol=1e-6)
    @test isapprox(StrojniSoucasti.polygon2eonatoceni(body_i2, pi/4), 43.133513652379634; atol=1e-6)

    @test StrojniSoucasti.polygon2eonatoceni(nothing) === nothing
    @test StrojniSoucasti.polygon2eonatoceni(nothing, 0) === nothing
    
    @test_throws ArgumentError StrojniSoucasti.polygon2eonatoceni([(0, 0), (1, 0)])
    @test_throws ArgumentError StrojniSoucasti.polygon2eonatoceni([0 0 0; 1 1 1; 2 2 2])
    @test_throws ArgumentError StrojniSoucasti.polygon2eonatoceni([(0, 0), (1, 0), (2, 0)])
end

nothing
