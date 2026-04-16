# ver: 2026-04-16
using Test
using StrojniSoucasti

profil_IPE_CSN425553_tests = [
    ("IPE80", "IPE", "\u010CSN 42 5553", 80.0, 46.0, 3.8, 5.2, 5.0, 0.0, ["11 373", "11 375", "11 503", "11 523", "15 217"]),
    ("IPE 100", "IPE", "\u010CSN 42 5553", 100.0, 55.0, 4.1, 5.7, 7.0, 0.0, ["11 373", "11 375", "11 503", "11 523", "15 217"]),
    ("ipe100.0", "IPE", "\u010CSN 42 5553", 100.0, 55.0, 4.1, 5.7, 7.0, 0.0, ["11 373", "11 375", "11 503", "11 523", "15 217"]),
]

function _test_profil_ipe_csn425553_common(prof, exp_serie, exp_standard, exp_h, exp_b, exp_t1, exp_t2, exp_R, exp_R1, exp_material)
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

@testset "profil_IPE_CSN425553" begin
    for (name1, exp_serie, exp_standard, exp_h, exp_b, exp_t1, exp_t2, exp_R, exp_R1, exp_material) in profil_IPE_CSN425553_tests
        prof = StrojniSoucasti.profil_IPE_CSN425553(name1)
        _test_profil_ipe_csn425553_common(prof, exp_serie, exp_standard, exp_h, exp_b, exp_t1, exp_t2, exp_R, exp_R1, exp_material)
    end

    @test StrojniSoucasti.profil_IPE_CSN425553("I100") === nothing
    @test StrojniSoucasti.profil_IPE_CSN425553("IPE999") === nothing
    @test StrojniSoucasti.profil_IPE_CSN425553("IPN100") === nothing
    @test StrojniSoucasti.profil_IPE_CSN425553("XYZ100") === nothing
    @test StrojniSoucasti.profil_IPE_CSN425553("IPE") === nothing
end
