# ver: 2026-02-03
# Testovací skript pro funkci namahanikombinovane.jl
# Testuje kombinovaná namáhání dle Huber-Mises-Hencky a Tresca kritérií

using StrojniSoucasti, Unitful, Test

@testset "namahanikombinovane" begin

    # Příprava vstupních dat
    prof1 = "KR 25"
    mat1 = "16440"
    VVtah1, _ = namahanitah(F=20u"kN", profil=prof1, mat=mat1)
    VVtlak1, _ = namahanitlak(F=20u"kN", profil=prof1, mat=mat1)
    VVstrih1, _ = namahanistrih(F=10u"kN", profil=prof1, mat=mat1)
    VVkrut1, _ = namahanikrut(Mk=400u"N*m", profil=prof1, mat=mat1)
    VVohyb1, _ = namahaniohyb(Mo=400u"N*m", profil=prof1, mat=mat1)

    # Test 1: tah-střih kombinace
    @testset "tah-střih kombinace" begin
        VVkomb1, txtkomb1 = namahanikombinovane(vysledky = [VVtah1, VVstrih1])
        @test haskey(VVkomb1, :sigma_eq)
        @test haskey(VVkomb1, :sigmaD)
        @test haskey(VVkomb1, :bezpecnost)
        @test haskey(VVkomb1, :info)
        @test haskey(VVkomb1, :namahani)
        @test VVkomb1[:namahani] == "tah-střih"
        @test VVkomb1[:kriterium] == "Huber-Mises-Hencky" # výchozí kritérium
        @test VVkomb1[:sigma_eq] > 0u"MPa"
        @test VVkomb1[:sigmaD] > 0u"MPa"
        @test VVkomb1[:bezpecnost] > 0
        @test isa(txtkomb1, String)
        @test !isempty(txtkomb1)
    end

    # Test 2: tlak-střih kombinace
    @testset "tlak-střih kombinace" begin
        VVkomb2, txtkomb2 = namahanikombinovane(vysledky = [VVtlak1, VVstrih1])
        @test haskey(VVkomb2, :sigma_eq)
        @test VVkomb2[:namahani] == "tlak-střih"
        @test VVkomb2[:sigma_eq] > 0u"MPa"
        @test isa(txtkomb2, String)
    end

    # Test 3: tah-krut kombinace
    @testset "tah-krut kombinace" begin
        VVkomb3, txtkomb3 = namahanikombinovane(vysledky = [VVtah1, VVkrut1])
        @test haskey(VVkomb3, :sigma_eq)
        @test VVkomb3[:namahani] == "tah-krut"
        @test VVkomb3[:sigma_eq] > 0u"MPa"
        @test isa(txtkomb3, String)
    end

    # Test 4: tlak-krut kombinace
    @testset "tlak-krut kombinace" begin
        VVkomb4, txtkomb4 = namahanikombinovane(vysledky = [VVtlak1, VVkrut1])
        @test haskey(VVkomb4, :sigma_eq)
        @test VVkomb4[:namahani] == "tlak-krut"
        @test VVkomb4[:sigma_eq] > 0u"MPa"
    end

    # Test 5: tah-ohyb kombinace
    @testset "tah-ohyb kombinace" begin
        VVkomb5, txtkomb5 = namahanikombinovane(vysledky = [VVtah1, VVohyb1])
        @test haskey(VVkomb5, :sigma_eq)
        @test VVkomb5[:namahani] == "tah-ohyb"
        @test VVkomb5[:sigma_eq] > 0u"MPa"
    end

    # Test 6: tlak-ohyb kombinace
    @testset "tlak-ohyb kombinace" begin
        VVkomb6, txtkomb6 = namahanikombinovane(vysledky = [VVtlak1, VVohyb1])
        @test haskey(VVkomb6, :sigma_eq)
        @test VVkomb6[:namahani] == "tlak-ohyb"
        @test VVkomb6[:sigma_eq] > 0u"MPa"
    end

    # Test 7: střih-krut kombinace
    @testset "střih-krut kombinace" begin
        VVkomb7, txtkomb7 = namahanikombinovane(vysledky = [VVstrih1, VVkrut1])
        @test haskey(VVkomb7, :sigma_eq)
        @test VVkomb7[:namahani] == "střih-krut"
        @test VVkomb7[:sigma_eq] > 0u"MPa"
    end

    # Test 8: střih-ohyb kombinace
    @testset "střih-ohyb kombinace" begin
        VVkomb8, txtkomb8 = namahanikombinovane(vysledky = [VVstrih1, VVohyb1])
        @test haskey(VVkomb8, :sigma_eq)
        @test VVkomb8[:namahani] == "střih-ohyb"
        @test VVkomb8[:sigma_eq] > 0u"MPa"
    end

    # Test 9: krut-ohyb kombinace
    @testset "krut-ohyb kombinace" begin
        VVkomb9, txtkomb9 = namahanikombinovane(vysledky = [VVkrut1, VVohyb1], k=5)
        @test haskey(VVkomb9, :sigma_eq)
        @test VVkomb9[:namahani] == "krut-ohyb"
        @test VVkomb9[:sigma_eq] > 0u"MPa"
        @test haskey(VVkomb9, :k)
        @test VVkomb9[:k] == 5
    end

    # Test 10: Tresca kritérium
    @testset "Tresca kritérium" begin
        VVkomb10, _ = namahanikombinovane(vysledky = [VVtah1, VVstrih1], kriterium = :Tresca)
        @test VVkomb10[:kriterium] == "Tresca"
        @test haskey(VVkomb10, :sigma_eq)
        @test VVkomb10[:sigma_eq] > 0u"MPa"
    end

    # Test 11: Výstup bez textu
    @testset "výstup bez textu" begin
        VVkomb11 = namahanikombinovane(vysledky = [VVtah1, VVstrih1], return_text = false)
        @test isa(VVkomb11, Dict)
        @test haskey(VVkomb11, :sigma_eq)
        @test haskey(VVkomb11, :bezpecnost)
    end

    # Test 12: Vlastní dovolené napětí
    @testset "vlastní dovolené napětí" begin
        VVkomb12, _ = namahanikombinovane(vysledky = [VVtah1, VVstrih1], sigmaD = 100u"MPa")
        @test VVkomb12[:sigmaD] == 100u"MPa"
        @test VVkomb12[:sigma_eq] > 0u"MPa"
    end

    # Test 13: Inverzní pořadí vstupů
    @testset "inverzní pořadí vstupů" begin
        VVkomb_norm, txtkomb_norm = namahanikombinovane(vysledky = [VVtah1, VVstrih1])
        VVkomb_inv, txtkomb_inv = namahanikombinovane(vysledky = [VVstrih1, VVtah1])
        @test VVkomb_norm[:sigma_eq] == VVkomb_inv[:sigma_eq]
        @test VVkomb_norm[:bezpecnost] == VVkomb_inv[:bezpecnost]
        @test txtkomb_norm == txtkomb_inv
    end

end
