# ver: 2026-04-10
using Test
using StrojniSoucasti

profilI_tests = [
    ("I80", "I", "ČSN 42 5550", 80, 42, 3.9, 5.9, 3.9, 2.3, ["10 000", "10 370.1", "11 373", "11 375", "11 523"]),
    ("I100", "I", "ČSN 42 5550", 100, 50, 4.5, 6.8, 4.5, 2.7, ["10 000", "10 370.1", "11 373", "11 375", "11 523"]),
]

@testset "profilI" begin
    for (name1, exp_serie, exp_standard, exp_b, exp_h, exp_t1, exp_t2, exp_R, exp_R1, exp_material) in profilI_tests
        prof = StrojniSoucasti.profilI(name1)
        @test prof !== nothing
        @test prof.serie == exp_serie
        @test prof.standard == exp_standard
        @test prof.h == exp_h
        @test prof.h_unit == "mm"
        @test prof.b == exp_b
        @test prof.b_unit == "mm"
        @test prof.t1 == exp_t1
        @test prof.t1_unit == "mm"
        @test prof.t2 == exp_t2
        @test prof.t2_unit == "mm"
        @test prof.R == exp_R
        @test prof.R_unit == "mm"
        @test prof.R1 == exp_R1
        @test prof.R1_unit == "mm"
        @test prof.material == exp_material
    end

    @test StrojniSoucasti.profilI("HEM100") === nothing
    @test StrojniSoucasti.profilI("IPE999") === nothing
    @test StrojniSoucasti.profilI("XYZ100") === nothing
end
