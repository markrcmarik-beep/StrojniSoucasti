# ver: 2026-03-02
using Test
using StrojniSoucasti

@testset "torsion_J_TR4HR_numeric" begin
    solid_rect_J(a, b) = a >= b ?
        a * b^3 * (1 / 3 - 0.21 * (b / a) * (1 - b^4 / (12 * a^4))) :
        b * a^3 * (1 / 3 - 0.21 * (a / b) * (1 - a^4 / (12 * b^4)))

    a, b, t = 20.0, 10.0, 1.0
    J = StrojniSoucasti.torsion_J_TR4HR_numeric(a, b, t; nx=120, ny=120, tol=1e-5, maxiter=50_000)
    J_BB = 2 * (a - t)^2 * (b - t)^2 * t / ((a - t) + (b - t))
    J_ref = solid_rect_J(a, b) - solid_rect_J(a - 2t, b - 2t)

    @test J > 0
    @test isfinite(J)
    @test J > J_BB
    @test J ≈ J_ref rtol=5e-3

    # Geometrie je ekvivalentni po prohozeni stran.
    J_swapped = StrojniSoucasti.torsion_J_TR4HR_numeric(b, a, t; nx=120, ny=120, tol=1e-5, maxiter=50_000)
    @test J ≈ J_swapped rtol=1e-2

    # Pro stejne vnejsi rozmery s rostouci tloustkou steny roste i J.
    J_t1 = StrojniSoucasti.torsion_J_TR4HR_numeric(20.0, 10.0, 1.0; nx=120, ny=120, tol=1e-5, maxiter=50_000)
    J_t4 = StrojniSoucasti.torsion_J_TR4HR_numeric(20.0, 10.0, 4.0; nx=120, ny=120, tol=1e-5, maxiter=50_000)
    @test J_t4 > J_t1

    @test_throws AssertionError StrojniSoucasti.torsion_J_TR4HR_numeric(10.0, 10.0, 5.0)
end
