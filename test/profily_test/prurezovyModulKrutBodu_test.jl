# ver: 2026-04-08
using Test
using StrojniSoucasti, Unitful

@testset "prurezovyModulKrutBodu" begin
    # Obdelnik 4 x 3
    # Jp_teiste = Ix + Iy = 9 + 16 = 25
    # rmax = sqrt((4/2)^2 + (3/2)^2) = 2.5
    # Wk = 25 / 2.5 = 10
    Wk1 = prurezovyModulKrutBodu([(0, 0), (4, 0), (4, 3), (0, 3)])
    @test Wk1 == 10.0

    # Opaecny smer bodu
    Wk2 = prurezovyModulKrutBodu([(0, 0), (0, 3), (4, 3), (4, 0)])
    @test Wk2 == 10.0

    # Uzavreny polygon (prvni bod zopakovany)
    Wk3 = prurezovyModulKrutBodu([(0, 0), (4, 0), (4, 3), (0, 3), (0, 0)])
    @test Wk3 == 10.0

    # Matice Nx2
    Wk4 = prurezovyModulKrutBodu([0 0; 4 0; 4 3; 0 3])
    @test Wk4 == 10.0

    # Unitful vstup
    body_u = [(0u"mm", 0u"mm"), (4u"mm", 0u"mm"), (4u"mm", 3u"mm"), (0u"mm", 3u"mm")]
    Wk5 = prurezovyModulKrutBodu(body_u)
    @test Wk5 == 10.0u"mm^3"

    # Neplatne vstupy
    @test_throws ArgumentError prurezovyModulKrutBodu([(0, 0), (1, 0)])
    @test_throws ArgumentError prurezovyModulKrutBodu([0 0 0; 1 1 1; 2 2 2])
    @test_throws ArgumentError prurezovyModulKrutBodu([(0, 0), (1, 0), (2, 0)])
end

