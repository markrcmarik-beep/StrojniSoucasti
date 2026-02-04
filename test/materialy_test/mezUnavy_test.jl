# ver: 2026-02-04
# Testovací skript pro funkci mezUnavy.jl
# Testuje výpočet mezí únavy materiálu s různými kombinacemi namáhání a zatížení

using StrojniSoucasti, Unitful, Test

@testset "mezUnavy" begin

    # Test 1: Tah s statickým zatížením
    @testset "tah - statický" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "tah", "statický")
        #println(B)
        @test isa(B, Quantity)
        @test B > 0u"MPa"
        #@test B isa Quantity{<:Real, typeof(u"MPa")}
    end

    # Test 2: Tah s pulzním zatížením
    @testset "tah - pulzní" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "tah", "pulzní")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
        # Pulzní zatížení by mělo mít menší hodnotu než statické
        B_stat = mezUnavy(250u"MPa", 450u"MPa", "tah", "statický")
        @test B < B_stat
    end

    # Test 3: Tah s dynamickým zatížením
    @testset "tah - dynamický" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "tah", "dynamický")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
        # Dynamické zatížení by mělo mít menší hodnotu než statické
        B_stat = mezUnavy(250u"MPa", 450u"MPa", "tah", "statický")
        @test B < B_stat
    end

    # Test 4: Tah s rázovým zatížením
    @testset "tah - rázový" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "tah", "rázový")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
        # Rázové zatížení by mělo mít nejmenší hodnotu
        B_stat = mezUnavy(250u"MPa", 450u"MPa", "tah", "statický")
        @test B < B_stat
    end

    # Test 5: Tlak s statickým zatížením
    @testset "tlak - statický" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "tlak", "statický")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
    end

    # Test 6: Tlak s rázovým zatížením
    @testset "tlak - rázový" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "tlak", "rázový")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
        B_stat = mezUnavy(250u"MPa", 450u"MPa", "tlak", "statický")
        @test B < B_stat
    end

    # Test 7: Ohyb s statickým zatížením
    @testset "ohyb - statický" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "ohyb", "statický")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
    end

    # Test 8: Ohyb s dynamickým zatížením
    @testset "ohyb - dynamický" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "ohyb", "dynamický")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
        B_stat = mezUnavy(250u"MPa", 450u"MPa", "ohyb", "statický")
        @test B < B_stat
    end

    # Test 9: Střih s statickým zatížením
    @testset "střih - statický" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "střih", "statický")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
    end

    # Test 10: Střih s pulzním zatížením
    @testset "střih - pulzní" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "střih", "pulzní")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
        B_stat = mezUnavy(250u"MPa", 450u"MPa", "střih", "statický")
        @test B < B_stat
    end

    # Test 11: Krut s statickým zatížením
    @testset "krut - statický" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "krut", "statický")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
    end

    # Test 12: Krut s rázovým zatížením
    @testset "krut - rázový" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "krut", "rázový")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
        B_stat = mezUnavy(250u"MPa", 450u"MPa", "krut", "statický")
        @test B < B_stat
    end

    # Test 13: Různé materiály - menší mez kluzu
    @testset "nižší mez kluzu a pevnost" begin
        B_low = mezUnavy(200u"MPa", 350u"MPa", "tah", "statický")
        B_high = mezUnavy(250u"MPa", 450u"MPa", "tah", "statický")
        @test isa(B_low, Quantity)
        @test isa(B_high, Quantity)
        # Nižší pevnost by měla mít nižší mez únavy
        @test B_low < B_high
    end

    # Test 14: Vysoká mez pevnosti
    @testset "vysoká mez pevnosti" begin
        B = mezUnavy(300u"MPa", 550u"MPa", "tah", "dynamický")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
    end

    # Test 15: Velmi nízké hodnoty
    @testset "velmi nízké hodnoty" begin
        B = mezUnavy(100u"MPa", 150u"MPa", "ohyb", "statický")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
    end

    # Test 16: Jednotky v MPa
    @testset "jednotky v MPa" begin
        B = mezUnavy(250u"MPa", 450u"MPa", "tah", "statický")
        B_converted = uconvert(u"MPa", B)
        @test unit(B_converted) == u"MPa"
        @test ustrip(B_converted) > 0
    end

    # Test 17: Normalizace vstupů - malá/velká písmena
    @testset "normalizace vstupů - velikost písmen" begin
        B1 = mezUnavy(250u"MPa", 450u"MPa", "tah", "STATICKÝ")
        B2 = mezUnavy(250u"MPa", 450u"MPa", "TAH", "statický")
        B3 = mezUnavy(250u"MPa", 450u"MPa", "TaH", "StAtIcKý")
        @test B1 == B2
        @test B2 == B3
    end

    # Test 18: Normalizace vstupů - mezery
    @testset "normalizace vstupů - mezery" begin
        B1 = mezUnavy(250u"MPa", 450u"MPa", "tah", "statický")
        B2 = mezUnavy(250u"MPa", 450u"MPa", " tah ", " statický ")
        @test B1 == B2
    end

    # Test 19: Porovnání namáhání - tah vs ohyb
    @testset "porovnání namáhání - tah vs ohyb" begin
        B_tah = mezUnavy(250u"MPa", 450u"MPa", "tah", "statický")
        B_ohyb = mezUnavy(250u"MPa", 450u"MPa", "ohyb", "statický")
        @test isa(B_tah, Quantity)
        @test isa(B_ohyb, Quantity)
        # Obě by měly být podobné pro stejné zatížení
        @test B_tah ≈ B_ohyb rtol=0.1
    end

    # Test 20: Porovnání namáhání - střih vs krut
    @testset "porovnání namáhání - střih vs krut" begin
        B_strih = mezUnavy(250u"MPa", 450u"MPa", "střih", "statický")
        B_krut = mezUnavy(250u"MPa", 450u"MPa", "krut", "statický")
        @test isa(B_strih, Quantity)
        @test isa(B_krut, Quantity)
        # Obě by měly být podobné pro stejné zatížení
        @test B_strih ≈ B_krut rtol=0.1
    end

    # Test 21: Monotónní pokles se zvyšujícím se zatížením
    @testset "monotónní pokles zatížení" begin
        Re = 250u"MPa"
        Rm = 450u"MPa"
        B_stat = mezUnavy(Re, Rm, "tah", "statický")
        B_pulz = mezUnavy(Re, Rm, "tah", "pulzní")
        B_dyn = mezUnavy(Re, Rm, "tah", "dynamický")
        B_raz = mezUnavy(Re, Rm, "tah", "rázový")
        @test B_stat > B_pulz > B_dyn > B_raz
    end

    # Test 22: Kontrola chybových zpráv - neznámé namáhání
    @testset "chybná namáhání - výjimka" begin
        @test_throws ErrorException mezUnavy(250u"MPa", 450u"MPa", "zkrutování", "statický")
    end

    # Test 23: Kontrola chybových zpráv - neznámé zatížení
    @testset "chybné zatížení - výjimka" begin
        @test_throws ErrorException mezUnavy(250u"MPa", 450u"MPa", "tah", "cyklické")
    end

    # Test 24: Chybí jednotky u Re
    @testset "chybí jednotky u Re - výjimka" begin
        @test_throws ErrorException mezUnavy(250, 450u"MPa", "tah", "statický")
    end

    # Test 25: Chybí jednotky u Rm
    @testset "chybí jednotky u Rm - výjimka" begin
        @test_throws ErrorException mezUnavy(250u"MPa", 450, "tah", "statický")
    end

    # Test 26: Tisk výsledků (bez kontroly obsahu, jen že nechybí)
    @testset "tisk výsledků" begin
        # Tisk by neměl vyvolat chybu
        B = mezUnavy(250u"MPa", 450u"MPa", "tah", "statický")
        @test isa(B, Quantity)
        @test B > 0u"MPa"
    end

end
