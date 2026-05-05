# ver: 2026-05-05
using Test
using StrojniSoucasti

expected_R(t) = min(t + t/3, 8.0)

profil_TR4HR_CSN425720_tests = [
    ("TR4HR20x20x2", 20, 20, 2, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 20x2"),
    ("TR4HR20x2", 20, 20, 2, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 20x2"),
    ("TR4HR30x20x3", 30, 20, 3, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 30x20x3"),
    #("TR4HR30x3", 30, 30, 3, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 30x3"),
    ("TR4HR25x3", 25, 25, 3, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 25x3"),
    ("TR4HR40x40x5", 40, 40, 5, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 40x5"),
    ("TR4HR40x5", 40, 40, 5, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 40x5"),
    ("TR4HR15x10x1.5", 15, 10, 1.5, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 15x10x1.5"),
    #("TR4HR15x1.5", 15, 15, 1.5, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 15x1.5"),
    ("TR4HR10x1", 10, 10, 1, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 10x1"),
    ("tr4hr10x10x1", 10, 10, 1, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 10x1"),
    ("TR4HR60x40x6", 60, 40, 6, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 60x40x6"),
    ("TR4HR60x6.3", 60, 60, 6.3, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 60x6.3"),
    ("tr4hr60x6.3", 60, 60, 6.3, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 60x6.3"),
]

@testset "profil_TR4HR_CSN425720" begin
    for (name1, exp_a, exp_b, exp_t, exp_standard, exp_material, nazev1) in profil_TR4HR_CSN425720_tests
        prof = StrojniSoucasti.profil_TR4HR_CSN425720(name1)
        @test prof !== nothing
        @test prof isa StrojniSoucasti.TR4HR_CSN425720
        @test prof.name == nazev1
        @test prof.series == "TR4HR"
        @test prof.a == exp_a
        @test prof.b == exp_b
        @test prof.t == exp_t
        @test isapprox(prof.R, expected_R(exp_t); atol=1e-4)
        @test prof.standard == exp_standard
        @test prof.material == exp_material
    end

    # Test neexistující profil
    @test StrojniSoucasti.profil_TR4HR_CSN425720("TR4HR999x999x9") === nothing
    @test StrojniSoucasti.profil_TR4HR_CSN425720("TR4HR20x20x3") === nothing # tloušťka 3 mm není v databázi pro 20x20
    @test StrojniSoucasti.profil_TR4HR_CSN425720("TR4HR20.5x30x2") === nothing
end
