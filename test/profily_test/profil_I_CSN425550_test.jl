# ver: 2026-05-01
using Test
using StrojniSoucasti

profil_I_CSN425550_tests = [
    ("I80", "I", "\u010CSN 42 5550", 80.0, 42.0, 3.9, 5.9, 3.9, 2.3, ["10 000", "10 370.1", "11 373", "11 375", "11 523"]),
    ("i 80", "I", "\u010CSN 42 5550", 80.0, 42.0, 3.9, 5.9, 3.9, 2.3, ["10 000", "10 370.1", "11 373", "11 375", "11 523"]),
    ("I80.0", "I", "\u010CSN 42 5550", 80.0, 42.0, 3.9, 5.9, 3.9, 2.3, ["10 000", "10 370.1", "11 373", "11 375", "11 523"]),
    ("I100", "I", "\u010CSN 42 5550", 100.0, 50.0, 4.5, 6.8, 4.5, 2.7, ["10 000", "10 370.1", "11 373", "11 375", "11 523"]),
]

function _test_profil_i_csn425550_common(prof, exp_serie, exp_standard, exp_h, exp_b, exp_t1, exp_t2, exp_R, exp_R1, exp_material)
    @test prof !== nothing
    @test prof isa StrojniSoucasti.I_CSN425550
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

@testset "profil_I_CSN425550" begin
    for (name1, exp_serie, exp_standard, exp_h, exp_b, exp_t1, exp_t2, exp_R, exp_R1, exp_material) in profil_I_CSN425550_tests
        prof = StrojniSoucasti.profil_I_CSN425550(name1)
        _test_profil_i_csn425550_common(prof, exp_serie, exp_standard, exp_h, exp_b, exp_t1, exp_t2, exp_R, exp_R1, exp_material)
    end

    prof80 = StrojniSoucasti.profil_I_CSN425550("I80")
    @test prof80 !== nothing
    @test prof80.Sx == 11400.0
    @test prof80.sx == 68.4
    @test prof80.sx_unit == "mm"

    @test StrojniSoucasti.profil_I_CSN425550("IPE100") === nothing
    @test StrojniSoucasti.profil_I_CSN425550("I999") === nothing
    @test StrojniSoucasti.profil_I_CSN425550("IPN100") === nothing
    @test StrojniSoucasti.profil_I_CSN425550("XYZ100") === nothing
    @test StrojniSoucasti.profil_I_CSN425550("I") === nothing
end
