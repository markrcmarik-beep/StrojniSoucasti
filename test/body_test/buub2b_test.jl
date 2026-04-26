# ver: 2026-04-26
using StrojniSoucasti, Test

@testset "buub2b - základní funkčnost" begin
    # původní testy
    C = StrojniSoucasti.buub2b((10.0, 20.0), 30*pi/180, 45*pi/180, (42.89, 38.99))
    @test C[1] ≈ 42.89 atol=1e-2
    @test C[2] ≈ 38.99 atol=1e-2

    C = StrojniSoucasti.buub2b((1.0, 0.5), pi/2, pi, (1.0, 10.5))
    @test C[1] ≈ 1 atol=1e-2
    @test C[2] ≈ 10.5 atol=1e-2

    C = StrojniSoucasti.buub2b((5.0, 5.0), pi/4, 3pi/4, (9.9497, 9.9497))
    @test C[1] ≈ 9.9497 atol=1e-2
    @test C[2] ≈ 9.9497 atol=1e-2

    C = StrojniSoucasti.buub2b((15.0, 25.0), 2pi/3, 4pi/3, (14.13, 26.5))
    @test C[1] ≈ 14.13 atol=1e-2
    @test C[2] ≈ 26.5 atol=1e-2
end

#-------------------------------------------------------------
@testset "buub2b - kritické úhly" begin
    # vodorovná + svislá
    C = StrojniSoucasti.buub2b((0.0, 0.0), 0.0, pi/2, (1.0, -1.0))
    @test C[1] ≈ 1.0 atol=1e-10
    @test C[2] ≈ 0.0 atol=1e-10

    # obě svislé → chyba
    @test_throws ErrorException StrojniSoucasti.buub2b((0.0,0.0), pi/2, pi/2, (1.0,1.0))

    # obě vodorovné → chyba
    @test_throws ErrorException StrojniSoucasti.buub2b((0.0,0.0), 0.0, 0.0, (1.0,1.0))
end

#-------------------------------------------------------------
@testset "buub2b - rovnoběžnost a téměř rovnoběžnost" begin
    # přesně rovnoběžné
    @test_throws ErrorException StrojniSoucasti.buub2b((0.0,0.0), pi/4, pi/4, (1.0,1.0))
    # téměř rovnoběžné (numerická stabilita)
    C = StrojniSoucasti.buub2b((0.0,0.0), pi/4, pi/4 + 1e-8, (1.0,0.0))
    @test isfinite(C[1])
    @test isfinite(C[2])
end

#-------------------------------------------------------------
@testset "buub2b - obecné geometrické vlastnosti" begin
    A = (2.0, 3.0)
    B = (8.0, -1.0)
    u1 = 0.7
    u2 = 2.1

    C = StrojniSoucasti.buub2b(A, u1, u2, B)

    # C leží na přímce z A
    v1 = (cos(u1), sin(u1))
    AC = (C[1]-A[1], C[2]-A[2])
    @test abs(v1[1]*AC[2] - v1[2]*AC[1]) < 1e-10

    # C leží na přímce z B
    v2 = (cos(u2), sin(u2))
    BC = (C[1]-B[1], C[2]-B[2])
    @test abs(v2[1]*BC[2] - v2[2]*BC[1]) < 1e-10
end

#-------------------------------------------------------------
@testset "buub2b - invariance (posunutí soustavy)" begin
    A = (1.0, 2.0)
    B = (4.0, 6.0)
    u1 = 0.3
    u2 = 2.0

    C1 = StrojniSoucasti.buub2b(A, u1, u2, B)

    shift = (10.0, -5.0)
    A2 = (A[1]+shift[1], A[2]+shift[2])
    B2 = (B[1]+shift[1], B[2]+shift[2])

    C2 = StrojniSoucasti.buub2b(A2, u1, u2, B2)

    @test C2[1] ≈ C1[1] + shift[1] atol=1e-10
    @test C2[2] ≈ C1[2] + shift[2] atol=1e-10
end
