# ver: 2026-07-18
using Test
using StrojniSoucasti, Unitful

@testset "polygon2kvadratickymoment" begin
    @testset "Jednoduchy polygon (obdelnik 4x3)" begin
        body = [(0, 0), (4, 0), (4, 3), (0, 3)]
        # Ix = b*h^3/12 = 4*3^3/12 = 9
        # Iy = h*b^3/12 = 3*4^3/12 = 16
        M1 = StrojniSoucasti.polygon2kvadratickymoment(body)
        @test M1.Ix == 9.0
        @test M1.Iy == 16.0

        # Opaecny smer bodu
        body_rev = [(0, 0), (0, 3), (4, 3), (4, 0)]
        M2 = StrojniSoucasti.polygon2kvadratickymoment(body_rev)
        @test M2.Ix == 9.0
        @test M2.Iy == 16.0

        # Uzavreny polygon (prvni bod zopakovany)
        body_closed = [(0, 0), (4, 0), (4, 3), (0, 3), (0, 0)]
        M3 = StrojniSoucasti.polygon2kvadratickymoment(body_closed)
        @test M3.Ix == 9.0
        @test M3.Iy == 16.0

        # Matice Nx2
        M4 = StrojniSoucasti.polygon2kvadratickymoment([0 0; 4 0; 4 3; 0 3])
        @test M4.Ix == 9.0
        @test M4.Iy == 16.0

        # Unitful vstup
        body_u = [(0u"mm", 0u"mm"), (4u"mm", 0u"mm"), (4u"mm", 3u"mm"), (0u"mm", 3u"mm")]
        M5 = StrojniSoucasti.polygon2kvadratickymoment(body_u)
        @test M5.Ix == 9.0u"mm^4"
        @test M5.Iy == 16.0u"mm^4"
    end

    @testset "Nekonvexni polygon (profil U)" begin
        body_u_shape = [(0,0), (10,0), (10,10), (0,10), (0,8), (8,8), (8,2), (0,2)]
        M = StrojniSoucasti.polygon2kvadratickymoment(body_u_shape)
        @test isapprox(M.Ix, 2068/3; atol=1e-9) # 689.333...
        @test isapprox(M.Iy, 245908/507; atol=1e-9) # 485.025...
    end

    @testset "Polygon s otvory" begin
        # Obrys + jeden otvor (soustredny ctverec)
        body_s_otvorem = (
            obrys = [(0, 0), (10, 0), (10, 10), (0, 10)],
            otvory = [[(3, 3), (7, 3), (7, 7), (3, 7)]],
        )
        # Ix = 10*10^3/12 - 4*4^3/12 = 833.333 - 21.333 = 812
        M6 = StrojniSoucasti.polygon2kvadratickymoment(body_s_otvorem)
        @test isapprox(M6.Ix, 812.0; atol=1e-9)
        @test isapprox(M6.Iy, 812.0; atol=1e-9)

        # Obrys + vice otvoru
        body_s_vice_otvory = (
            obrys = [(0, 0), (10, 0), (10, 8), (0, 8)],
            otvory = [
                [(1, 1), (3, 1), (3, 3), (1, 3)],
                [(7, 5), (9, 5), (9, 7), (7, 7)],
            ],
        )
        M7 = StrojniSoucasti.polygon2kvadratickymoment(body_s_vice_otvory)
        @test isapprox(M7.Ix, 392.0; atol=1e-9)
        @test isapprox(M7.Iy, 592.0; atol=1e-9)

        # Polygon s prazdnym seznamem otvoru
        body_s_prazdnym_otvorem = (
            obrys = [(0, 0), (4, 0), (4, 3), (0, 3)],
            otvory = [],
        )
        M8 = StrojniSoucasti.polygon2kvadratickymoment(body_s_prazdnym_otvorem)
        @test M8.Ix == 9.0
        @test M8.Iy == 16.0
    end

    @testset "Komplexni profil (I-profil)" begin
        prof = StrojniSoucasti.profil_I_CSN425550("I80")
        body_i = StrojniSoucasti.body_I_CSN425550(prof, "stred")
        M = StrojniSoucasti.polygon2kvadratickymoment(body_i)
        @test isapprox(M.Ix, prof.Ix; rtol=1e-2)
        @test isapprox(M.Iy, prof.Iy; rtol=1e-2)
    end

    @testset "Specialni pripady a neplatne vstupy" begin
        @test StrojniSoucasti.polygon2kvadratickymoment(nothing) === nothing

        @test_throws ArgumentError StrojniSoucasti.polygon2kvadratickymoment([(0, 0), (1, 0)])
        @test_throws ArgumentError StrojniSoucasti.polygon2kvadratickymoment([0 0 0; 1 1 1; 2 2 2])
        @test_throws ArgumentError StrojniSoucasti.polygon2kvadratickymoment([(0, 0), (1, 0), (2, 0)]) # Degenerovany
        body_bad_hole = (obrys = [(0,0),(10,0),(10,10),(0,10)], otvory = [1, 2, 3])
        @test_throws ArgumentError StrojniSoucasti.polygon2kvadratickymoment(body_bad_hole)
        body_negative_area = (obrys = [(0,0),(1,0),(1,1),(0,1)], otvory = [[(-1,-1),(2,-1),(2,2),(-1,2)]])
        @test_throws ArgumentError StrojniSoucasti.polygon2kvadratickymoment(body_negative_area)
        @test_throws MethodError StrojniSoucasti.polygon2kvadratickymoment("not a polygon")
    end
end

nothing
