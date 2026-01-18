# ver: 2026-01-18
using Test
using StrojniSoucasti

A1 = StrojniSoucasti.profilTR4HR("tr4hr40x40x3")
println("A1: ", A1.name, ", a=", A1.a, ", b=", A1.b, ", t=", A1.t)

profilTR4HR_tests = [
    ("TR4HR20x20x2", 20.0, 20.0, 2.0),
    ("TR4HR30x20x3", 30.0, 20.0, 3.0),
    ("TR4HR25x3", 25.0, 25.0, 3.0),
    ("TR4HR40x5", 40.0, 40.0, 5.0),
    ("TR4HR15x10x1.5", 15.0, 10.0, 1.5),
    ("TR4HR10x1", 10.0, 10.0, 1.0),
    ("tr4hr10x10x1", 10.0, 10.0, 1.0)
]   
@testset "profilTR4HR tests" begin
    for (name, exp_a, exp_b, exp_t) in profilTR4HR_tests
        prof = StrojniSoucasti.profilTR4HR(name)
        @test prof !== nothing "Profil $name should be found"
        @test prof.a == exp_a "Profil $name: expected a=$exp_a, got $(prof.a)"
        @test prof.b == exp_b "Profil $name: expected b=$exp_b, got $(prof.b)"
        @test prof.t == exp_t "Profil $name: expected t=$exp_t, got $(prof.t)"
    end

    # Test neexistující profil
    @test StrojniSoucasti.profilTR4HR("TR4HR999x999x9") === nothing "Non-existing profile should return nothing"
    @test StrojniSoucasti.profilTR4HR("TR4HR20x20x3") === nothing "Profile with wrong thickness should return nothing"
end
