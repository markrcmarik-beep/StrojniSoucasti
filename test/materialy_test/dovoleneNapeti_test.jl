# ver: 2026-02-04
# Testovací skript pro funkci dovoleneNapeti.jl
# Testuje výpočet dovolených napětí s různými kombinacemi namáhání a zatížení

using StrojniSoucasti, Unitful, Test

@testset "dovoleneNapeti" begin

    # Test 1: Tah - statický
    @testset "tah - statický" begin
        sigma = dovoleneNapeti(250u"MPa", "tah", "statický")
        @test sigma isa Quantity
        @test sigma > 0u"MPa"
        @test unit(sigma) == u"MPa"
    end

    # Test 2: Tah - pulzní
    @testset "tah - pulzní" begin
        sigma = dovoleneNapeti(250u"MPa", "tah", "pulzní")
        @test sigma > 0u"MPa"
        # Pulzní by mělo mít menší hodnotu než statické
        sigma_stat = dovoleneNapeti(250u"MPa", "tah", "statický")
        @test sigma < sigma_stat
    end

    # Test 3: Tah - dynamický
    @testset "tah - dynamický" begin
        sigma = dovoleneNapeti(250u"MPa", "tah", "dynamický")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti(250u"MPa", "tah", "statický")
        @test sigma < sigma_stat
    end

    # Test 4: Tah - rázový
    @testset "tah - rázový" begin
        sigma = dovoleneNapeti(250u"MPa", "tah", "rázový")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti(250u"MPa", "tah", "statický")
        @test sigma < sigma_stat
    end

    # Test 5: Tlak - statický
    @testset "tlak - statický" begin
        sigma = dovoleneNapeti(250u"MPa", "tlak", "statický")
        @test sigma > 0u"MPa"
    end

    # Test 6: Tlak - dynamický
    @testset "tlak - dynamický" begin
        sigma = dovoleneNapeti(250u"MPa", "tlak", "dynamický")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti(250u"MPa", "tlak", "statický")
        @test sigma < sigma_stat
    end

    # Test 7: Ohyb - statický
    @testset "ohyb - statický" begin
        sigma = dovoleneNapeti(250u"MPa", "ohyb", "statický")
        @test sigma > 0u"MPa"
    end

    # Test 8: Ohyb - pulzní
    @testset "ohyb - pulzní" begin
        sigma = dovoleneNapeti(300u"MPa", "ohyb", "pulzní")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti(300u"MPa", "ohyb", "statický")
        @test sigma < sigma_stat
    end

    # Test 9: Ohyb - rázový
    @testset "ohyb - rázový" begin
        sigma = dovoleneNapeti(450u"MPa", "ohyb", "rázový")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti(450u"MPa", "ohyb", "statický")
        @test sigma < sigma_stat
    end

    # Test 10: Střih - statický
    @testset "střih - statický" begin
        sigma = dovoleneNapeti(250u"MPa", "střih", "statický")
        @test sigma > 0u"MPa"
    end

    # Test 11: Střih - dynamický
    @testset "střih - dynamický" begin
        sigma = dovoleneNapeti(350u"MPa", "střih", "dynamický")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti(350u"MPa", "střih", "statický")
        @test sigma < sigma_stat
    end

    # Test 12: Krut - statický
    @testset "krut - statický" begin
        sigma = dovoleneNapeti(250u"MPa", "krut", "statický")
        @test sigma > 0u"MPa"
    end

    # Test 13: Krut - dynamický
    @testset "krut - dynamický" begin
        sigma = dovoleneNapeti(400u"MPa", "krut", "dynamický")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti(400u"MPa", "krut", "statický")
        @test sigma < sigma_stat
    end

    # Test 14: Otlačení - statický
    @testset "otlačení - statický" begin
        sigma = dovoleneNapeti(250u"MPa", "otlačení", "statický")
        @test sigma > 0u"MPa"
    end

    # Test 15: Otlačení - bez parametru zatížení (výchozí statický)
    @testset "otlačení - výchozí" begin
        sigma1 = dovoleneNapeti(600u"MPa", "otlačení")
        sigma2 = dovoleneNapeti(600u"MPa", "otlačení", "statický")
        @test sigma1 == sigma2
    end

    # Test 16: Bez jednotek u Re (automatický přepis)
    @testset "bez jednotek u Re" begin
        sigma = dovoleneNapeti(250, "tah", "statický")
        @test sigma isa Quantity
        @test sigma > 0u"MPa"
    end

    # Test 17: Tah-střih - statický-statický
    @testset "tah-střih - statický-statický" begin
        sigma = dovoleneNapeti(500u"MPa", "tah-střih", "statický-statický")
        @test sigma > 0u"MPa"
    end

    # Test 18: Tlak-střih - statický-statický
    @testset "tlak-střih - statický-statický" begin
        sigma = dovoleneNapeti(500u"MPa", "tlak-střih", "statický-statický")
        @test sigma > 0u"MPa"
    end

    # Test 19: Tah-střih - různá zatížení
    @testset "tah-střih - statický-pulzní" begin
        sigma = dovoleneNapeti(500u"MPa", "tah-střih", "statický-pulzní")
        @test sigma > 0u"MPa"
    end

    # Test 20: Tah-krut - kombinované zatížení
    @testset "tah-krut - statický" begin
        sigma = dovoleneNapeti(500u"MPa", "tah-krut", "statický-statický")
        @test sigma > 0u"MPa"
    end

    # Test 21: Tlak-krut - kombinované zatížení
    @testset "tlak-krut - statický" begin
        sigma = dovoleneNapeti(500u"MPa", "tlak-krut", "statický-statický")
        @test sigma > 0u"MPa"
    end

    # Test 22: Tah-ohyb - kombinované zatížení
    @testset "tah-ohyb - statický" begin
        sigma = dovoleneNapeti(500u"MPa", "tah-ohyb", "statický-statický")
        @test sigma > 0u"MPa"
    end

    # Test 23: Tlak-ohyb - kombinované zatížení
    @testset "tlak-ohyb - statický" begin
        sigma = dovoleneNapeti(500u"MPa", "tlak-ohyb", "statický-statický")
        @test sigma > 0u"MPa"
    end

    # Test 24: Střih-krut - kombinované zatížení
    @testset "střih-krut - statický-statický" begin
        sigma = dovoleneNapeti(500u"MPa", "střih-krut", "statický-statický")
        @test sigma > 0u"MPa"
    end

    # Test 25: Střih-krut - různá zatížení
    @testset "střih-krut - pulzní-dynamický" begin
        sigma = dovoleneNapeti(500u"MPa", "střih-krut", "pulzní-dynamický")
        @test sigma > 0u"MPa"
    end

    # Test 26: Střih-ohyb - kombinované zatížení
    @testset "střih-ohyb - statický" begin
        sigma = dovoleneNapeti(500u"MPa", "střih-ohyb", "statický-statický")
        @test sigma > 0u"MPa"
    end

    # Test 27: Krut-ohyb - kombinované zatížení
    @testset "krut-ohyb - dynamický-dynamický" begin
        sigma = dovoleneNapeti(500u"MPa", "krut-ohyb", "dynamický-dynamický")
        @test sigma > 0u"MPa"
    end

    # Test 28: Krut-ohyb - různá zatížení
    @testset "krut-ohyb - pulzní-rázový" begin
        sigma = dovoleneNapeti(500u"MPa", "krut-ohyb", "pulzní-rázový")
        @test sigma > 0u"MPa"
    end

    # Test 29: Monotónní pokles s rostoucím zatížením
    @testset "monotónní pokles zatížení - tah" begin
        Re = 250u"MPa"
        sigma_stat = dovoleneNapeti(Re, "tah", "statický")
        sigma_pulz = dovoleneNapeti(Re, "tah", "pulzní")
        sigma_dyn = dovoleneNapeti(Re, "tah", "dynamický")
        sigma_raz = dovoleneNapeti(Re, "tah", "rázový")
        @test sigma_stat > sigma_pulz > sigma_dyn > sigma_raz
    end

    # Test 30: Různé hodnoty Re
    @testset "různé hodnoty Re" begin
        sigma_low = dovoleneNapeti(200u"MPa", "tah", "statický")
        sigma_high = dovoleneNapeti(300u"MPa", "tah", "statický")
        @test sigma_low < sigma_high
    end

    # Test 31: Vysoká mez kluzu
    @testset "vysoká mez kluzu" begin
        sigma = dovoleneNapeti(600u"MPa", "tah", "statický")
        @test sigma > 0u"MPa"
    end

    # Test 32: Velmi nízká mez kluzu
    @testset "velmi nízká mez kluzu" begin
        sigma = dovoleneNapeti(100u"MPa", "ohyb", "statický")
        @test sigma > 0u"MPa"
    end

    # Test 33: Normalizace jednotek (MPa vs N/mm²)
    @testset "jednotky MPa" begin
        sigma1 = dovoleneNapeti(250u"MPa", "tah", "statický")
        sigma2 = uconvert(u"MPa", sigma1)
        @test unit(sigma2) == u"MPa"
        @test ustrip(sigma2) > 0
    end

    # Test 34: Srovnání namáhání - tah vs tlak (stejné hodnoty)
    @testset "tah vs tlak - stejné Re" begin
        sigma_tah = dovoleneNapeti(250u"MPa", "tah", "statický")
        sigma_tlak = dovoleneNapeti(250u"MPa", "tlak", "statický")
        @test sigma_tah ≈ sigma_tlak rtol=5
    end

    # Test 35: Srovnání namáhání - ohyb vs tah
    @testset "ohyb vs tah - stejné Re" begin
        sigma_tah = dovoleneNapeti(250u"MPa", "tah", "statický")
        sigma_ohyb = dovoleneNapeti(250u"MPa", "ohyb", "statický")
        @test sigma_tah ≈ sigma_ohyb rtol=50
    end

    # Test 36: Srovnání namáhání - střih vs krut
    @testset "střih vs krut - stejné Re" begin
        sigma_strih = dovoleneNapeti(250u"MPa", "střih", "statický")
        sigma_krut = dovoleneNapeti(250u"MPa", "krut", "statický")
        @test sigma_strih ≈ sigma_krut rtol=50
    end

    # Test 37: Otlačení je méně bezpečné
    @testset "otlačení - nižší bezpečnost" begin
        sigma_tah = dovoleneNapeti(250u"MPa", "tah", "statický")
        sigma_otl = dovoleneNapeti(250u"MPa", "otlačení", "statický")
        @test sigma_otl > sigma_tah  # Otlačení má nižší faktor bezpečnosti
    end

    # Test 38: Chybné namáhání
    @testset "chybné namáhání - výjimka" begin
        @test_throws ErrorException dovoleneNapeti(250u"MPa", "zkrutování", "statický")
    end

    # Test 39: Chybné zatížení
    @testset "chybné zatížení - výjimka" begin
        @test_throws ErrorException dovoleneNapeti(250u"MPa", "tah", "cyklické")
    end

    # Test 40: Neznámá kombinace
    @testset "neznámá kombinace - výjimka" begin
        @test_throws ErrorException dovoleneNapeti(250u"MPa", "neznámé-namáhání", "statický")
    end

end
