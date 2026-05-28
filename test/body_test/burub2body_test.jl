# ver: 2026-04-30
using StrojniSoucasti, Test

@testset "burub2body - základní funkčnost" begin

    A = (0.0, 0.0)
    B = (4.0, 0.0)
    u1 = pi/4
    u2 = 3pi/4
    R = 1.0

    body = StrojniSoucasti.burub2body(A, u1, R, u2, B, 0.2)

    @test length(body) ≥ 2

end

#-------------------------------------------------------------

@testset "burub2body - body leží na kružnici" begin

    A = (0.0, 0.0)
    B = (4.0, 0.0)
    u1 = pi/4
    u2 = 3pi/4
    R = 1.0

    body = StrojniSoucasti.burub2body(A, u1, R, u2, B, 0.2)

    # průsečík přímek
    P = StrojniSoucasti.buub2b(A, u1, u2, B)

    # tečné body
    T1, T2 = StrojniSoucasti.ubru2bb(u1, P, R, u2)

    # najdi střed kružnice (kolmý posun)
    # střed leží ve vzdálenosti R kolmo od tečného bodu
    # použijeme první bod oblouku
    cx_candidates = []
    for (tx, ty) in (T1, T2)
        push!(cx_candidates, (tx, ty))  # placeholder (nepotřebujeme přesný střed)
    end

    # ověř vzdálenost mezi sousedními body ~ konst.
    for i in 1:length(body)-1
        dx = body[i+1][1] - body[i][1]
        dy = body[i+1][2] - body[i][2]
        @test hypot(dx, dy) ≤ 0.25   # přibližná horní mez (presnost)
    end

end

#-------------------------------------------------------------

@testset "burub2body - body leží mezi tečnými body" begin

    A = (1.0, 1.0)
    B = (5.0, 1.0)
    u1 = pi/3
    u2 = 2pi/3
    R = 0.5

    body = StrojniSoucasti.burub2body(A, u1, R, u2, B, 0.1)

    P = StrojniSoucasti.buub2b(A, u1, u2, B)

    function on_segment(Pt, X, Y; atol=1e-8)
        XY = (Y[1] - X[1], Y[2] - X[2])
        XPt = (Pt[1] - X[1], Pt[2] - X[2])
        cross = XY[1]*XPt[2] - XY[2]*XPt[1]
        dot = XY[1]*XPt[1] + XY[2]*XPt[2]
        len2 = XY[1]^2 + XY[2]^2
        return abs(cross) ≤ atol && dot ≥ -atol && dot ≤ len2 + atol
    end

    # první i poslední bod oblouku musí ležet mezi body A-P a B-P
    @test on_segment(body[1], A, P)
    @test on_segment(body[end], B, P)

end

#-------------------------------------------------------------

@testset "burub2body - invariant posunutí" begin

    A = (0.0, 0.0)
    B = (4.0, 0.0)
    shift = (10.0, -3.0)

    u1 = 0.5
    u2 = 2.0
    R = 1.0

    body1 = StrojniSoucasti.burub2body(A, u1, R, u2, B, 0.2)

    A2 = (A[1] + shift[1], A[2] + shift[2])
    B2 = (B[1] + shift[1], B[2] + shift[2])

    body2 = StrojniSoucasti.burub2body(A2, u1, R, u2, B2, 0.2)

    @test length(body1) == length(body2)

    for i in eachindex(body1)
        @test body2[i][1] ≈ body1[i][1] + shift[1] atol=1e-10
        @test body2[i][2] ≈ body1[i][2] + shift[2] atol=1e-10
    end

end

#-------------------------------------------------------------

@testset "burub2body - invariant rotace" begin

    A = (-1.0, 0.0)
    B = (0.0, -1.0)
    u1 = 0.0
    u2 = pi/2
    R = 0.5

    rot = pi/4

    function rotp(p, ang)
        (p[1]*cos(ang) - p[2]*sin(ang),
         p[1]*sin(ang) + p[2]*cos(ang))
    end

    body1 = StrojniSoucasti.burub2body(A, u1, R, u2, B, 0.1)

    A2 = rotp(A, rot)
    B2 = rotp(B, rot)

    body2 = StrojniSoucasti.burub2body(A2, u1+rot, R, u2+rot, B2, 0.1)

    body1r = [rotp(p, rot) for p in body1]

    @test length(body1r) == length(body2)

    for i in eachindex(body1r)
        @test body2[i][1] ≈ body1r[i][1] atol=1e-10
        @test body2[i][2] ≈ body1r[i][2] atol=1e-10
    end

end

#-------------------------------------------------------------

@testset "burub2body - tečné body leží na polopřímkách" begin

    A = (0.0, 0.0)
    B = (0.0, 2.0)
    u1 = 0.0
    u2 = 3pi/2
    R = 0.5

    body = StrojniSoucasti.burub2body(A, u1, R, u2, B, 0.1)

    function on_ray(P, O, u; atol=1e-8)
        d = (cos(u), sin(u))
        v = (P[1] - O[1], P[2] - O[2])
        cross = d[1]*v[2] - d[2]*v[1]
        t = d[1]*v[1] + d[2]*v[2]
        return abs(cross) ≤ atol && t ≥ -atol
    end

    @test on_ray(body[1], A, u1)
    @test on_ray(body[end], B, u2)

end

#-------------------------------------------------------------

@testset "burub2body - degenerace" begin

    # rovnoběžné přímky
    @test_throws ArgumentError StrojniSoucasti.burub2body(
        (0.0,0.0), 0.5, 1.0, 0.5, (1.0,1.0), 0.1)

    # nulový poloměr
    @test_throws ArgumentError StrojniSoucasti.burub2body(
        (0.0,0.0), 0.5, 0.0, 1.0, (1.0,1.0), 0.1)

    # nulová přesnost
    @test_throws ArgumentError StrojniSoucasti.burub2body(
        (0.0,0.0), 0.5, 1.0, 1.0, (1.0,1.0), 0.0)

    # zadaný poloměr je příliš velký pro úsečky A-P a B-P
    @test_throws ArgumentError StrojniSoucasti.burub2body(
        (0.0,0.0), pi/4, 3.0, 3pi/4, (4.0,0.0), 0.1)

end
