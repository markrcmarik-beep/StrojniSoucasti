# ver: 2026-04-09
using Test
using StrojniSoucasti

expected_R(t) = min(t + t/3, 8.0)

profilTR4HR_tests = [
    ("TR4HR20x20x2", 20, 20, 2, "ČSN 42 5720", ["11 353", "11 453", "11 523"]),
    ("TR4HR20x2", 20, 20, 2, "ČSN 42 5720", ["11 353", "11 453", "11 523"]),
    ("TR4HR30x20x3", 30, 20, 3, "ČSN 42 5720", ["11 353", "11 453", "11 523"]),
    ("TR4HR25x3", 25, 25, 3, "ČSN 42 5720", ["11 353", "11 453", "11 523"]),
    ("TR4HR40x40x5", 40, 40, 5, "ČSN 42 5720", ["11 353", "11 453", "11 523"]),
    ("TR4HR40x5", 40, 40, 5, "ČSN 42 5720", ["11 353", "11 453", "11 523"]),
    ("TR4HR15x10x1.5", 15, 10, 1.5, "ČSN 42 5720", ["11 353", "11 453", "11 523"]),
    ("TR4HR10x1", 10, 10, 1, "ČSN 42 5720", ["11 353", "11 453", "11 523"]),
    ("tr4hr10x10x1", 10, 10, 1, "ČSN 42 5720", ["11 353", "11 453", "11 523"]),
    ("TR4HR60x40x6", 60, 40, 6, "ČSN 42 5720", ["11 353", "11 453", "11 523"]),
    ("tr4hr60x6.3", 60, 60, 6.3, "ČSN 42 5720", ["11 353", "11 453", "11 523"]),
]

@testset "profilTR4HR" begin
    for (name1, exp_a, exp_b, exp_t, exp_standard, exp_material) in profilTR4HR_tests
        prof = StrojniSoucasti.profilTR4HR(name1)
        @test prof !== nothing
        @test prof.a == exp_a
        @test prof.b == exp_b
        @test prof.t == exp_t
        @test isapprox(prof.R, expected_R(exp_t); atol=1e-12)
        @test prof.standard == exp_standard
        @test prof.material == exp_material
    end

    # Test neexistující profil
    @test StrojniSoucasti.profilTR4HR("TR4HR999x999x9") === nothing
    @test StrojniSoucasti.profilTR4HR("TR4HR20x20x3") === nothing
    @test StrojniSoucasti.profilTR4HR("TR4HR20.5x30x2") === nothing
end
