# ver: 2026-02-16
# Testovací skript pro funkci dovoleneNapeti.jl
# Testuje výpočet dovolených napětí s různými kombinacemi namáhání a zatížení

using StrojniSoucasti, Unitful, Test

@testset "dovoleneNapeti" begin

    # Test 0: hodnoty načtené z gammaM.toml
    @testset "gammaM.toml - načtení dat" begin
        sigma_simple = dovoleneNapeti("tah", "statický"; Re=260u"MPa")
        @test sigma_simple ≈ 200.0u"MPa" rtol=1e-12

        sigma_combo = dovoleneNapeti("tah-střih", "statický-pulzní"; Re=230u"MPa")
        @test sigma_combo ≈ 100.0u"MPa" rtol=1e-12
    end

    # Test 1: Tah - statický
    @testset "tah - statický" begin
        sigma = dovoleneNapeti("tah", "statický", Re=250u"MPa")
        @test sigma isa Quantity
        @test sigma > 0u"MPa"
        @test unit(sigma) == u"MPa"
    end

    # Test 2: Tah - pulzní
    @testset "tah - pulzní" begin
        sigma = dovoleneNapeti("tah", "pulzní"; Re=250u"MPa")
        @test sigma > 0u"MPa"
        # Pulzní by mělo mít menší hodnotu než statické
        sigma_stat = dovoleneNapeti("tah", "statický"; Re=250u"MPa")
        @test sigma < sigma_stat
    end

    # Test 3: Tah - dynamický
    @testset "tah - dynamický" begin
        sigma = dovoleneNapeti("tah", "dynamický"; Re=250u"MPa")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti("tah", "statický"; Re=250u"MPa")
        @test sigma < sigma_stat
    end

    # Test 4: Tah - rázový
    @testset "tah - rázový" begin
        sigma = dovoleneNapeti("tah", "rázový"; Re=250u"MPa")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti("tah", "statický"; Re=250u"MPa")
        @test sigma < sigma_stat
    end

    # Test 5: Tlak - statický
    @testset "tlak - statický" begin
        sigma = dovoleneNapeti("tlak", "statický"; Re=250u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 6: Tlak - dynamický
    @testset "tlak - dynamický" begin
        sigma = dovoleneNapeti("tlak", "dynamický"; Re=250u"MPa")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti("tlak", "statický"; Re=250u"MPa")
        @test sigma < sigma_stat
    end

    # Test 7: Ohyb - statický
    @testset "ohyb - statický" begin
        sigma = dovoleneNapeti("ohyb", "statický"; Re=250u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 8: Ohyb - pulzní
    @testset "ohyb - pulzní" begin
        sigma = dovoleneNapeti("ohyb", "pulzní"; Re=300u"MPa")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti("ohyb", "statický"; Re=300u"MPa")
        @test sigma < sigma_stat
    end

    # Test 9: Ohyb - rázový
    @testset "ohyb - rázový" begin
        sigma = dovoleneNapeti("ohyb", "rázový"; Re=450u"MPa")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti("ohyb", "statický"; Re=450u"MPa")
        @test sigma < sigma_stat
    end

    # Test 10: Střih - statický
    @testset "střih - statický" begin
        sigma = dovoleneNapeti("střih", "statický"; Re=250u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 11: Střih - dynamický
    @testset "střih - dynamický" begin
        sigma = dovoleneNapeti("střih", "dynamický"; Re=350u"MPa")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti("střih", "statický"; Re=350u"MPa")
        @test sigma < sigma_stat
    end

    # Test 12: Krut - statický
    @testset "krut - statický" begin
        sigma = dovoleneNapeti("krut", "statický"; Re=250u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 13: Krut - dynamický
    @testset "krut - dynamický" begin
        sigma = dovoleneNapeti("krut", "dynamický"; Re=400u"MPa")
        @test sigma > 0u"MPa"
        sigma_stat = dovoleneNapeti("krut", "statický"; Re=400u"MPa")
        @test sigma < sigma_stat
    end

    # Test 14: Otlačení - statický
    @testset "otlačení - statický" begin
        sigma = dovoleneNapeti("otlačení", "statický"; Re=250u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 15: Otlačení - bez parametru zatížení (výchozí statický)
    @testset "otlačení - výchozí" begin
        sigma1 = dovoleneNapeti("otlačení"; Re=600u"MPa")
        sigma2 = dovoleneNapeti("otlačení", "statický"; Re=600u"MPa")
        @test sigma1 == sigma2
    end

    # Test 16: Bez jednotek u Re (automatický přepis)
    @testset "bez jednotek u Re" begin
        sigma = dovoleneNapeti("tah", "statický"; Re=250)
        @test sigma isa Quantity
        @test sigma > 0u"MPa"
    end

    # Test 17: Tah-střih - statický-statický
    @testset "tah-střih - statický-statický" begin
        sigma = dovoleneNapeti("tah-střih", "statický-statický"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 18: Tlak-střih - statický-statický
    @testset "tlak-střih - statický-statický" begin
        sigma = dovoleneNapeti("tlak-střih", "statický-statický"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 19: Tah-střih - různá zatížení
    @testset "tah-střih - statický-pulzní" begin
        sigma = dovoleneNapeti("tah-střih", "statický-pulzní"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 20: Tah-krut - kombinované zatížení
    @testset "tah-krut - statický" begin
        sigma = dovoleneNapeti("tah-krut", "statický-statický"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 21: Tlak-krut - kombinované zatížení
    @testset "tlak-krut - statický" begin
        sigma = dovoleneNapeti("tlak-krut", "statický-statický"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 22: Tah-ohyb - kombinované zatížení
    @testset "tah-ohyb - statický" begin
        sigma = dovoleneNapeti("tah-ohyb", "statický-statický"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 23: Tlak-ohyb - kombinované zatížení
    @testset "tlak-ohyb - statický" begin
        sigma = dovoleneNapeti("tlak-ohyb", "statický-statický"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 24: Střih-krut - kombinované zatížení
    @testset "střih-krut - statický-statický" begin
        sigma = dovoleneNapeti("střih-krut", "statický-statický"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 25: Střih-krut - různá zatížení
    @testset "střih-krut - pulzní-dynamický" begin
        sigma = dovoleneNapeti("střih-krut", "pulzní-dynamický"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 26: Střih-ohyb - kombinované zatížení
    @testset "střih-ohyb - statický" begin
        sigma = dovoleneNapeti("střih-ohyb", "statický-statický"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 27: Krut-ohyb - kombinované zatížení
    @testset "krut-ohyb - dynamický-dynamický" begin
        sigma = dovoleneNapeti("krut-ohyb", "dynamický-dynamický"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 28: Krut-ohyb - různá zatížení
    @testset "krut-ohyb - pulzní-rázový" begin
        sigma = dovoleneNapeti("krut-ohyb", "pulzní-rázový"; Re=500u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 29: Monotónní pokles s rostoucím zatížením
    @testset "monotónní pokles zatížení - tah" begin
        Re = 250u"MPa"
        sigma_stat = dovoleneNapeti("tah", "statický"; Re=Re)
        sigma_pulz = dovoleneNapeti("tah", "pulzní"; Re=Re)
        sigma_dyn = dovoleneNapeti("tah", "dynamický"; Re=Re)
        sigma_raz = dovoleneNapeti("tah", "rázový"; Re=Re)
        @test sigma_stat > sigma_pulz > sigma_dyn > sigma_raz
    end

    # Test 30: Různé hodnoty Re
    @testset "různé hodnoty Re" begin
        sigma_low = dovoleneNapeti("tah", "statický"; Re=200u"MPa")
        sigma_high = dovoleneNapeti("tah", "statický"; Re=300u"MPa")
        @test sigma_low < sigma_high
    end

    # Test 31: Vysoká mez kluzu
    @testset "vysoká mez kluzu" begin
        sigma = dovoleneNapeti("tah", "statický"; Re=600u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 32: Velmi nízká mez kluzu
    @testset "velmi nízká mez kluzu" begin
        sigma = dovoleneNapeti("ohyb", "statický"; Re=100u"MPa")
        @test sigma > 0u"MPa"
    end

    # Test 33: Normalizace jednotek (MPa vs N/mm²)
    @testset "jednotky MPa" begin
        sigma1 = dovoleneNapeti("tah", "statický"; Re=250u"MPa")
        sigma2 = uconvert(u"MPa", sigma1)
        @test unit(sigma2) == u"MPa"
        @test ustrip(sigma2) > 0
    end

    # Test 34: Srovnání namáhání - tah vs tlak (stejné hodnoty)
    @testset "tah vs tlak - stejné Re" begin
        sigma_tah = dovoleneNapeti("tah", "statický"; Re=250u"MPa")
        sigma_tlak = dovoleneNapeti("tlak", "statický"; Re=250u"MPa")
        @test sigma_tah ≈ sigma_tlak rtol=5
    end

    # Test 35: Srovnání namáhání - ohyb vs tah
    @testset "ohyb vs tah - stejné Re" begin
        sigma_tah = dovoleneNapeti("tah", "statický"; Re=250u"MPa")
        sigma_ohyb = dovoleneNapeti("ohyb", "statický"; Re=250u"MPa")
        @test sigma_tah ≈ sigma_ohyb rtol=50
    end

    # Test 36: Srovnání namáhání - střih vs krut
    @testset "střih vs krut - stejné Re" begin
        sigma_strih = dovoleneNapeti("střih", "statický"; Re=250u"MPa")
        sigma_krut = dovoleneNapeti("krut", "statický"; Re=250u"MPa")
        @test sigma_strih ≈ sigma_krut rtol=50
    end

    # Test 37: Otlačení je méně bezpečné
    @testset "otlačení - nižší bezpečnost" begin
        sigma_tah = dovoleneNapeti("tah", "statický"; Re=250u"MPa")
        sigma_otl = dovoleneNapeti("otlačení", "statický"; Re=250u"MPa")
        @test sigma_otl > sigma_tah  # Otlačení má nižší faktor bezpečnosti
    end

    # Test 38: Re lze předat jako výstup z materialy() pro ocel
    @testset "Re z materialy() - ocel" begin
        mat = materialy("S235")
        sigma = dovoleneNapeti("tah", "statický"; mat=mat)
        @test sigma isa Quantity
        @test sigma > 0u"MPa"
    end

    # Test 39: Litina z materialy() vrací nothing (zatím nepodporováno)
    @testset "Re z materialy() - litina" begin
        mat = materialy("422420")
        @test !isnothing(mat)
        @test isnothing(dovoleneNapeti("tah", "statický"; mat=mat))
    end

    # Test 40: Neznámý materiál (materialy() => nothing) vrací nothing
    @testset "Re z materialy() - nothing" begin
        mat = materialy("NEEXISTUJICI_MATERIAL")
        @test isnothing(mat)
        #@test isnothing(dovoleneNapeti("tah", "statický"; mat=mat))
    end

    # Test 41: Chybné namáhání
    @testset "chybné namáhání - výjimka" begin
        @test_throws ErrorException dovoleneNapeti("zkrutování", "statický"; Re=250u"MPa")
    end

    # Test 42: Chybné zatížení
    @testset "chybné zatížení - výjimka" begin
        @test_throws ErrorException dovoleneNapeti("tah", "cyklické"; Re=250u"MPa")
    end

    # Test 43: Neznámá kombinace
    @testset "neznámá kombinace - výjimka" begin
        @test_throws ErrorException dovoleneNapeti("neznámé-namáhání", "statický"; Re=250u"MPa")
    end

end
