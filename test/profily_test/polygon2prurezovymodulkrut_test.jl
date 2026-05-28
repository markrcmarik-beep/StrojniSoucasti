# ver: 2026-04-24
using Test
using StrojniSoucasti, Unitful

@testset "polygon2prurezovymodulkrut" begin
    # Obdelnik 4 x 3
    # Jp_teiste = Ix + Iy = 9 + 16 = 25
    # rmax = sqrt((4/2)^2 + (3/2)^2) = 2.5
    # Wk = 25 / 2.5 = 10
    Wk1 = StrojniSoucasti.polygon2prurezovymodulkrut([(0, 0), (4, 0), (4, 3), (0, 3)])
    @test Wk1 == 10.0

    # Opaecny smer bodu
    Wk2 = StrojniSoucasti.polygon2prurezovymodulkrut([(0, 0), (0, 3), (4, 3), (4, 0)])
    @test Wk2 == 10.0

    # Uzavreny polygon (prvni bod zopakovany)
    Wk3 = StrojniSoucasti.polygon2prurezovymodulkrut([(0, 0), (4, 0), (4, 3), (0, 3), (0, 0)])
    @test Wk3 == 10.0

    # Matice Nx2
    Wk4 = StrojniSoucasti.polygon2prurezovymodulkrut([0 0; 4 0; 4 3; 0 3])
    @test Wk4 == 10.0

    # Unitful vstup
    body_u = [(0u"mm", 0u"mm"), (4u"mm", 0u"mm"), (4u"mm", 3u"mm"), (0u"mm", 3u"mm")]
    Wk5 = StrojniSoucasti.polygon2prurezovymodulkrut(body_u)
    @test Wk5 == 10.0u"mm^3"

    # Obrys + prazdne otvory (NamedTuple)
    body6 = (
        obrys = [(0, 0), (4, 0), (4, 3), (0, 3)],
        otvory = (),
    )
    Wk6 = StrojniSoucasti.polygon2prurezovymodulkrut(body6)
    @test Wk6 == 10.0

    # Obrys + jeden otvor (soustredny ctverec)
    body7 = (
        obrys = [(0, 0), (10, 0), (10, 10), (0, 10)],
        otvory = [[(3, 3), (7, 3), (7, 7), (3, 7)]],
    )
    Wk7 = StrojniSoucasti.polygon2prurezovymodulkrut(body7)
    @test isapprox(Wk7, 1624 / sqrt(50); atol=1e-9)

    # Neplatne vstupy
    @test_throws ArgumentError StrojniSoucasti.polygon2prurezovymodulkrut([(0, 0), (1, 0)])
    @test_throws ArgumentError StrojniSoucasti.polygon2prurezovymodulkrut([0 0 0; 1 1 1; 2 2 2])
    @test_throws ArgumentError StrojniSoucasti.polygon2prurezovymodulkrut([(0, 0), (1, 0), (2, 0)])
end

