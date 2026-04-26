# ver: 2026-04-26
using StrojniSoucasti, Test

@testset "ubru2bb - základní funkčnost" begin

    # jednoduchý pravý úhel
    A = (0.0, 0.0)
    alfa = 0.0
    beta = pi/2
    r = 10.0

    B, C = StrojniSoucasti.ubru2bb(alfa, A, r, beta)

    # vzdálenost od A musí být stejná
    a = r / tan((pi/2)/2)

    @test B[1] ≈ a atol=1e-10
    @test B[2] ≈ 0 atol=1e-10

    @test C[1] ≈ 0 atol=1e-10
    @test C[2] ≈ a atol=1e-10

end

#-------------------------------------------------------------

@testset "ubru2bb - obecný případ" begin

    A = (2.0, 3.0)
    alfa = 0.3
    beta = 1.2
    r = 5.0

    B, C = StrojniSoucasti.ubru2bb(alfa, A, r, beta)

    # body leží na příslušných přímkách (kolinearita)
    d1 = (cos(alfa), sin(alfa))
    d2 = (cos(beta), sin(beta))

    AB = (B[1]-A[1], B[2]-A[2])
    AC = (C[1]-A[1], C[2]-A[2])

    @test abs(d1[1]*AB[2] - d1[2]*AB[1]) < 1e-10
    @test abs(d2[1]*AC[2] - d2[2]*AC[1]) < 1e-10

end

#-------------------------------------------------------------

@testset "ubru2bb - symetrie" begin

    A = (0.0, 0.0)
    alfa = pi/6
    beta = 5pi/6
    r = 3.0

    B, C = StrojniSoucasti.ubru2bb(alfa, A, r, beta)

    # symetrie podle osy y
    @test B[1] ≈ -C[1] atol=1e-10
    @test B[2] ≈  C[2] atol=1e-10

end

#-------------------------------------------------------------

@testset "ubru2bb - invariant posunutí" begin

    A = (1.0, 2.0)
    shift = (10.0, -5.0)

    alfa = 0.4
    beta = 1.5
    r = 2.0

    B1, C1 = StrojniSoucasti.ubru2bb(alfa, A, r, beta)

    A2 = (A[1]+shift[1], A[2]+shift[2])
    B2, C2 = StrojniSoucasti.ubru2bb(alfa, A2, r, beta)

    @test B2[1] ≈ B1[1] + shift[1] atol=1e-10
    @test B2[2] ≈ B1[2] + shift[2] atol=1e-10

    @test C2[1] ≈ C1[1] + shift[1] atol=1e-10
    @test C2[2] ≈ C1[2] + shift[2] atol=1e-10

end

#-------------------------------------------------------------

@testset "ubru2bb - malé a velké úhly" begin

    A = (0.0, 0.0)
    r = 1.0

    # velmi malý úhel → velká vzdálenost
    alfa = 0.0
    beta = 1e-6

    B, C = StrojniSoucasti.ubru2bb(alfa, A, r, beta)
    @test isfinite(B[1])
    @test isfinite(C[1])

    # úhel blízko π
    alfa = 0.0
    beta = pi - 1e-6

    B, C = StrojniSoucasti.ubru2bb(alfa, A, r, beta)
    @test isfinite(B[1])
    @test isfinite(C[1])

end

#-------------------------------------------------------------

@testset "ubru2bb - chyby (degenerace)" begin

    A = (0.0, 0.0)
    r = 1.0

    # rovnoběžné přímky
    @test_throws ArgumentError StrojniSoucasti.ubru2bb(0.0, A, r, 0.0)

    # téměř rovnoběžné
    @test_throws ArgumentError StrojniSoucasti.ubru2bb(0.0, A, r, 1e-12)

    # protisměrné (π)
    @test_throws ArgumentError StrojniSoucasti.ubru2bb(0.0, A, r, pi)

    # záporný poloměr
    @test_throws ArgumentError StrojniSoucasti.ubru2bb(0.0, A, -1.0, pi/2)

end
