# ver: 2026-03-10
# Testovací skript pro funkci namahanitlak.jl
# Testuje namáhání v tlaku s různými typy zatížení

using StrojniSoucasti, Unitful, Test

function assert_namahanitlak_text_common(txt::String, VV::Dict{Symbol,Any})
    @test !isempty(txt)
    @test occursin("F = ", txt)
    @test occursin("S = ", txt)
    @test occursin("sigmaDt = ", txt)
    @test occursin("sigma = $(VV[:sigma_str])", txt)
    @test occursin("k = $(VV[:bezpecnost_str])", txt)
    @test occursin(string(VV[:verdict]), txt)
end

@testset "namahanitlak" begin
    expected_txt1 = """Výpočet namáhání v tlaku
----------------------------------------------------------------
materiál: 
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
sigmaDt = 240 MPa   Dovolené napětí v tlaku
----------------------------------------------------------------
výpočet:
sigma = F / S = 15 MPa   Napětí v tlaku
k = sigmaDt / sigma = 16   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt2 = """Výpočet namáhání v tlaku
----------------------------------------------------------------
materiál: 
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
sigmaDt = 184.615 MPa   Dovolené napětí v tlaku
Re = 240 MPa   Mez kluzu
----------------------------------------------------------------
výpočet:
sigma = F / S = 15 MPa   Napětí v tlaku
k = sigmaDt / sigma = 12.3077   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt3 = """Výpočet namáhání v tlaku
----------------------------------------------------------------
materiál: 11 373
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
sigmaDt = 192.308 MPa   Dovolené napětí v tlaku
Re = 250 MPa   Mez kluzu
E = 210 GPa   Youngův modul (tlak)
----------------------------------------------------------------
výpočet:
sigma = F / S = 15 MPa   Napětí v tlaku
epsilon = sigma / E = 7.14286 %   Poměrné zkrácení
k = sigmaDt / sigma = 12.8205   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt4 = """Výpočet namáhání v tlaku
----------------------------------------------------------------
materiál: S235
profil: PLO 20x20
  a = 20.0 mm
  b = 20.0 mm
  R = 0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
k = 5   Uživatelský požadavek bezpečnosti
S = a*b - 4*S(R) = 400 mm^2   Plocha průřezu
sigmaDt = 180.769 MPa   Dovolené napětí v tlaku
L0 = 90 mm   Délka namáhaného profilu
Re = 235 MPa   Mez kluzu
E = 210 GPa   Youngův modul (tlak)
----------------------------------------------------------------
výpočet:
sigma = F / S = 15 MPa   Napětí v tlaku
epsilon = sigma / E = 7.14286 %   Poměrné zkrácení
deltaL = -epsilon * L0 = -6.42857 mm   Skutečné zkrácení
L = L0 + deltaL = 83.5714 mm   Délka po deformaci
k = sigmaDt / sigma = 12.0513   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt5 = """Výpočet namáhání v tlaku
----------------------------------------------------------------
materiál: 
profil:
zatížení: dynamický
----------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
sigmaDt = 120 MPa   Dovolené napětí v tlaku
Re = 240 MPa   Mez kluzu
----------------------------------------------------------------
výpočet:
sigma = F / S = 15 MPa   Napětí v tlaku
k = sigmaDt / sigma = 8   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt6 = """Výpočet namáhání v tlaku
----------------------------------------------------------------
materiál: 
profil:
zatížení: rázový
----------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
sigmaDt = 96 MPa   Dovolené napětí v tlaku
Re = 240 MPa   Mez kluzu
----------------------------------------------------------------
výpočet:
sigma = F / S = 15 MPa   Napětí v tlaku
k = sigmaDt / sigma = 6.4   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt7 = """Výpočet namáhání v tlaku
----------------------------------------------------------------
materiál: 
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
sigmaDt = 180 MPa   Dovolené napětí v tlaku
E = 200 GPa   Youngův modul (tlak)
----------------------------------------------------------------
výpočet:
sigma = F / S = 15 MPa   Napětí v tlaku
epsilon = sigma / E = 7.5 %   Poměrné zkrácení
k = sigmaDt / sigma = 12   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt8 = """Výpočet namáhání v tlaku
----------------------------------------------------------------
materiál: 
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
sigmaDt = 180 MPa   Dovolené napětí v tlaku
L0 = 500 mm   Délka namáhaného profilu
E = 200 GPa   Youngův modul (tlak)
----------------------------------------------------------------
výpočet:
sigma = F / S = 15 MPa   Napětí v tlaku
epsilon = sigma / E = 7.5 %   Poměrné zkrácení
deltaL = -epsilon * L0 = -37.5 mm   Skutečné zkrácení
L = L0 + deltaL = 462.5 mm   Délka po deformaci
k = sigmaDt / sigma = 12   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    # Test 1: Základní výpočet bez jednotek
    @testset "zĂˇkladnĂ­ výpočet bez jednotek" begin
        VV, txt = namahanitlak(F=6000, S=400, sigmaDt=240)
        @test haskey(VV, :sigma)
        @test haskey(VV, :bezpecnost)
        @test haskey(VV, :info)
        @test VV[:info] == "namáhání v tlaku"
        @test VV[:sigma] > 0u"MPa"
        @test VV[:bezpecnost] > 0
        @test isa(txt, String)
        @test !isempty(txt)
        assert_namahanitlak_text_common(txt, VV)
        @test txt == expected_txt1
    end

    # Test 2: Výpočet s jednotkami
    @testset "výpočet s jednotkami" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", sigmaDt=240u"MPa")
        @test haskey(VV, :sigma)
        @test VV[:sigma] > 0u"MPa"
        @test uconvert(u"N", VV[:F]) == 6000u"N"
        @test uconvert(u"mm^2", VV[:S]) == 400u"mm^2"
        @test uconvert(u"MPa", VV[:sigmaDt]) == 240u"MPa"
        @test isa(txt, String)
        assert_namahanitlak_text_common(txt, VV)
        @test txt == expected_txt1
    end

    # Test 3: Výpočet s Re
    @testset "výpočet s Re" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa")
        @test haskey(VV, :sigma)
        @test haskey(VV, :sigmaDt)
        @test haskey(VV, :Re)
        @test VV[:sigma] > 0u"MPa"
        @test isa(txt, String)
        assert_namahanitlak_text_common(txt, VV)
        @test txt == expected_txt2
    end

    # Test 4: Výpočet s materiálem
    @testset "výpočet s materiálem" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", mat="11373")
        @test haskey(VV, :sigma)
        @test haskey(VV, :Re)
        @test haskey(VV, :E)
        @test VV[:Re] > 0u"MPa"
        @test VV[:E] > 0u"GPa"
        @test isa(txt, String)
        assert_namahanitlak_text_common(txt, VV)
        @test txt == expected_txt3
    end

        # Test 4b: Výpočet s materiálem jako struct z materialy()
    @testset "výpočet s materiálem jako proměnná" begin
        A1 = materialy("11373")
        @test A1 !== nothing
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", mat=A1)
        @test haskey(VV, :sigma)
        @test haskey(VV, :Re)
        @test haskey(VV, :E)
        @test VV[:Re] > 0u"MPa"
        @test VV[:E] > 0u"GPa"
        @test VV[:mat] == A1.name
        @test isa(txt, String)
        assert_namahanitlak_text_common(txt, VV)
        @test txt == expected_txt3
    end

    # Test 5: Výpočet s profilem a délkou
    @testset "výpočet s profilem a délkou" begin
        VV, txt = namahanitlak(F=6000u"N", profil="PLO 20x20", mat="S235", L0=90u"mm", k=5)
        @test haskey(VV, :sigma)
        @test haskey(VV, :S)
        @test haskey(VV, :deltaL)
        @test haskey(VV, :L)
        @test VV[:S] > 0u"mm^2"
        @test VV[:deltaL] !== nothing
        @test uconvert(u"mm", VV[:deltaL]) isa Quantity
        @test VV[:L] !== nothing
        @test uconvert(u"mm", VV[:L]) isa Quantity
        @test VV[:k] == 5
        assert_namahanitlak_text_common(txt, VV)
        @test txt == expected_txt4
    end

    # Test 6: StatickĂ© zatížení (výchozí)
    @testset "statickĂ© zatížení" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="statický")
        @test VV[:zatizeni] == "statický"
        @test haskey(VV, :sigmaDt)
        @test isa(txt, String)
        assert_namahanitlak_text_common(txt, VV)
        @test txt == expected_txt2
    end

    # Test 7: Dynamické zatížení
    @testset "dynamickĂ© zatížení" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="dynamický")
        @test VV[:zatizeni] == "dynamický"
        @test haskey(VV, :sigmaDt)
        assert_namahanitlak_text_common(txt, VV)
        @test txt == expected_txt5
    end

    # Test 8: Rázové zatížení
    @testset "rĂˇzovĂ© zatížení" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="rázový")
        @test VV[:zatizeni] == "rázový"
        @test haskey(VV, :sigmaDt)
        assert_namahanitlak_text_common(txt, VV)
        @test txt == expected_txt6
    end

    # Test 9: Výstup bez textu
    @testset "vĂ˝stup bez textu" begin
        VV = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa", return_text=false)
        @test isa(VV, Dict)
        @test haskey(VV, :sigma)
        @test haskey(VV, :bezpecnost)
    end

    # Test 10: Poměrné zkrácení
    @testset "pomÄ›rnĂ© zkrácení" begin
        VV, txt = namahanitlak(F=6000u"N", sigmaDt=180u"MPa", S=400u"mm^2", E=200u"GPa")
        @test haskey(VV, :epsilon)
        @test VV[:epsilon] !== nothing
        @test isa(VV[:epsilon], Number)
        assert_namahanitlak_text_common(txt, VV)
        @test txt == expected_txt7
    end

    # Test 11: ZkrĂˇcenĂ­ součásti
    @testset "zkrácení součásti" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", sigmaDt=180u"MPa", E=200u"GPa", L0=500u"mm")
        @test haskey(VV, :deltaL)
        @test haskey(VV, :L)
        @test VV[:deltaL] !== nothing
        @test uconvert(u"mm", VV[:deltaL]) isa Quantity
        @test VV[:L] !== nothing
        @test uconvert(u"mm", VV[:L]) isa Quantity
        @test VV[:L] < VV[:L0]  # zkrácení v tlaku
        assert_namahanitlak_text_common(txt, VV)
        @test txt == expected_txt8
    end

    # Test 12: Ověření vzorců
    @testset "ovÄ›Ĺ™enĂ­ vzorců" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa")
        @test VV[:sigma_str] == "F / S"
        @test VV[:bezpecnost_str] == "sigmaDt / sigma"
        # Ověření číselného výpočtu
        expected_sigma = uconvert(u"MPa", 6000u"N" / 400u"mm^2")
        @test isapprox(uconvert(u"MPa", VV[:sigma]), expected_sigma, rtol=1e-5)
    end

    # Test 13: Bezpečnost - bezpečný spoj
    @testset "bezpečný spoj" begin
        VV, txt = namahanitlak(F=3000u"N", S=400u"mm^2", Re=240u"MPa")
        @test VV[:bezpecnost] >= 1.5
        @test occursin("bezpečný", VV[:verdict])
    end

    # Test 14: Bezpečnost - hranice bezpeÄŤnosti
    @testset "hranice bezpeÄŤnosti" begin
        VV, txt = namahanitlak(F=24000u"N", S=400u"mm^2", sigmaDt=80u"MPa")
        @test VV[:bezpecnost] >= 1.0 && VV[:bezpecnost] < 1.5
        @test occursin("na hranici", VV[:verdict])
    end

    # Test 15: Bezpečnost - nebezpečný spoj
    @testset "nebezpečný spoj" begin
        VV, txt = namahanitlak(F=16000u"N", S=180u"mm^2", sigmaDt=80u"MPa")
        @test VV[:bezpecnost] < 1.0
        @test occursin("není bezpečný", VV[:verdict])
    end

    # Test 16: Vlastní požadavek bezpeÄŤnosti
    @testset "vlastnĂ­ požadavek bezpeÄŤnosti" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa", k=3)
        @test haskey(VV, :k)
        @test VV[:k] == 3
        @test isa(VV[:verdict], String)
    end

    # Test 17: Kladná síla
    @testset "kladnĂˇ síla" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", sigmaDt=240u"MPa")
        @test VV[:F] > 0u"N"
    end

    # Test 18: Neplatné vstupy
    @testset "neplatnĂ© vstupy" begin
        err = try
            namahanitlak(F=0u"N", S=400u"mm^2", sigmaDt=240u"MPa")
            nothing
        catch e
            e
        end
        @test err isa ErrorException
        @test occursin("F musí být kladná hodnota", sprint(showerror, err))

        err = try
            namahanitlak(F=6000u"N", S=0u"mm^2", sigmaDt=240u"MPa")
            nothing
        catch e
            e
        end
        @test err isa ErrorException
        @test occursin("S musí být kladná hodnota", sprint(showerror, err))

        err = try
            namahanitlak(F=6000u"N", S=400u"mm^2", sigmaDt=240u"MPa", k=0)
            nothing
        catch e
            e
        end
        @test err isa ErrorException
        @test occursin("k musí být kladné číslo", sprint(showerror, err))

        err = try
            namahanitlak(F=6000u"N", S=400u"mm^2", sigmaDt=240u"MPa", Imin=0u"mm^4")
            nothing
        catch e
            e
        end
        @test err isa ErrorException
        @test occursin("Imin musí být kladná hodnota", sprint(showerror, err))
    end

end




