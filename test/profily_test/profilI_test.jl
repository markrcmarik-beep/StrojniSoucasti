# ver: 2026-04-09
using Test
using StrojniSoucasti

profilI_tests = [
    ("IPE100", "IPE", "EN 10365", 100.0, 55.0, 4.1, 5.7, 7.0, ["S235JR", "S355JR"]),
    ("ipe 100", "IPE", "EN 10365", 100.0, 55.0, 4.1, 5.7, 7.0, ["S235JR", "S355JR"]),
    ("IPE100.0", "IPE", "EN 10365", 100.0, 55.0, 4.1, 5.7, 7.0, ["S235JR", "S355JR"]),
    ("IPE120", "IPE", "EN 10365", 120.0, 64.0, 4.4, 6.3, 7.0, ["S235JR", "S355JR"]),
    ("HEA100", "HEA", "EN 10365", 96.0, 100.0, 5.0, 8.0, 12.0, ["S235JR", "S355JR"]),
    ("HEB100", "HEB", "EN 10365", 100.0, 100.0, 6.0, 10.0, 12.0, ["S235JR", "S355JR"]),
    ("IPN100", "IPN", "EN 10365", 100.0, 50.0, 4.5, 6.8, 5.0, ["S235JR", "S355JR"]),
]

@testset "profilI" begin
    for (name1, exp_serie, exp_standard, exp_h, exp_b, exp_tw, exp_tf, exp_r, exp_material) in profilI_tests
        prof = StrojniSoucasti.profilI(name1)
        @test prof !== nothing
        @test prof.serie == exp_serie
        @test prof.standard == exp_standard
        @test prof.h == exp_h
        @test prof.b == exp_b
        @test prof.tw == exp_tw
        @test prof.tf == exp_tf
        @test prof.r == exp_r
        @test prof.material == exp_material
    end

    @test StrojniSoucasti.profilI("HEM100") === nothing
    @test StrojniSoucasti.profilI("IPE999") === nothing
    @test StrojniSoucasti.profilI("XYZ100") === nothing
end
