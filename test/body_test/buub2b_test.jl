# ver: 2026-04-27
using StrojniSoucasti, Test

@testset "buub2b - základní funkčnost" begin

    # průsečík os
    C = StrojniSoucasti.buub2b((0.0, 0.0), 0.0, pi/2, (1.0, 1.0))
    @test C[1] ≈ 1.0 atol=1e-10
    @test C[2] ≈ 0.0 atol=1e-10

    # jednoduchý obecný případ
    C = StrojniSoucasti.buub2b((1.0, 1.0), pi/4, -pi/4, (3.0, 1.0))
    @test C[1] ≈ 2.0 atol=1e-10
    @test C[2] ≈ 2.0 atol=1e-10

end

#-------------------------------------------------------------

@testset "buub2b - svislé a vodorovné přímky" begin

    # vertikální + horizontální
    C = StrojniSoucasti.buub2b((2.0, 0.0), pi/2, 0.0, (0.0, 3.0))
    @test C[1] ≈ 2.0 atol=1e-10
    @test C[2] ≈ 3.0 atol=1e-10

end

#-------------------------------------------------------------

@testset "buub2b - obecná geometrie" begin

    A = (0.5, -1.0)
    B = (2.0, 3.0)
    u1 = 0.7
    u2 = 2.2

    C = StrojniSoucasti.buub2b(A, u1, u2, B)

    # ověření kolinearity (vektorový součin ~ 0)
    d1 = (cos(u1), sin(u1))
    d2 = (cos(u2), sin(u2))

    AC = (C[1]-A[1], C[2]-A[2])
    BC = (C[1]-B[1], C[2]-B[2])

    @test abs(d1[1]*AC[2] - d1[2]*AC[1]) < 1e-10
    @test abs(d2[1]*BC[2] - d2[2]*BC[1]) < 1e-10

end

#-------------------------------------------------------------

@testset "buub2b - invariant posunutí" begin

    A = (1.0, 2.0)
    B = (3.0, 4.0)
    shift = (10.0, -5.0)

    u1 = 0.3
    u2 = 1.5

    C1 = StrojniSoucasti.buub2b(A, u1, u2, B)

    A2 = (A[1] + shift[1], A[2] + shift[2])
    B2 = (B[1] + shift[1], B[2] + shift[2])

    C2 = StrojniSoucasti.buub2b(A2, u1, u2, B2)

    @test C2[1] ≈ C1[1] + shift[1] atol=1e-10
    @test C2[2] ≈ C1[2] + shift[2] atol=1e-10

end

#-------------------------------------------------------------

@testset "buub2b - invariant rotace" begin

    A = (1.0, 0.0)
    B = (0.0, 1.0)
    u1 = 0.0
    u2 = pi/2

    rot = pi/3

    C1 = StrojniSoucasti.buub2b(A, u1, u2, B)

    # rotace bodu
    function rotp(p, ang)
        (p[1]*cos(ang) - p[2]*sin(ang),
         p[1]*sin(ang) + p[2]*cos(ang))
    end

    A2 = rotp(A, rot)
    B2 = rotp(B, rot)

    C2 = StrojniSoucasti.buub2b(A2, u1+rot, u2+rot, B2)

    C1r = rotp(C1, rot)

    @test C2[1] ≈ C1r[1] atol=1e-10
    @test C2[2] ≈ C1r[2] atol=1e-10

end

#-------------------------------------------------------------

@testset "buub2b - rovnoběžné přímky" begin

    A = (0.0, 0.0)
    B = (1.0, 1.0)

    # stejný směr
    @test_throws ArgumentError StrojniSoucasti.buub2b(A, 0.5, 0.5, B)

    # téměř rovnoběžné
    @test_throws ArgumentError StrojniSoucasti.buub2b(A, 0.5, 0.5 + 1e-14, B)

end
