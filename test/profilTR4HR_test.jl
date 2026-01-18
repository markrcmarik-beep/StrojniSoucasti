# ver: 2026-01-18
using Test
using StrojniSoucasti

profilTR4HR_tests = [
    ("TR4HR20x20x2", 20.0, 20.0, 2.0),
    ("TR4HR30x20x3", 30.0, 20.0, 3.0),
    ("TR4HR25x3", 25.0, 25.0, 3.0),
    ("TR4HR40x5", 40.0, 40.0, 5.0),
    ("TR4HR15x10x1.5", 15.0, 10.0, 1.5),
    ("TR4HR10x1", 10.0, 10.0, 1.0),
    ("tr4hr10x10x1", 10.0, 10.0, 1.0)
]   
@testset "profilTR4HR" begin
    for (name1, exp_a, exp_b, exp_t) in profilTR4HR_tests
        prof = StrojniSoucasti.profilTR4HR(name1)
        @test prof !== nothing
        @test prof.a === exp_a
        @test prof.b === exp_b
        @test prof.t === exp_t
    end

    # Test neexistující profil
    @test StrojniSoucasti.profilTR4HR("TR4HR999x999x9") === nothing
    @test StrojniSoucasti.profilTR4HR("TR4HR20x20x3") === nothing
end
