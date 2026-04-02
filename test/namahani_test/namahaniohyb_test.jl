# ver: 2026-03-22
# Testovací skript pro funkci namahaniohyb.jl
# Testuje namáhání v ohybu s různými typy zatížení

using StrojniSoucasti, Unitful, Test

function assert_namahaniohyb_text_common(txt::String, VV::Dict{Symbol,Any})
    @test !isempty(txt)
    @test occursin("Mo = ", txt)
    @test occursin("Wo = ", txt)
    @test occursin("sigmaDo = ", txt)
    @test occursin("sigma = $(VV[:sigma_str])", txt)
    @test occursin("k = $(VV[:bezpecnost_str])", txt)
    @test occursin(string(VV[:verdict]), txt)
end

@testset "namahaniohyb" begin
    expected_txt1 = """Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
Mo = 600 m N   Ohybový moment
natočení = 0 rad   Natočení profilu
Wo = 400 mm^3   Průřezový modul v ohybu
sigmaDo = 240 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 1500 MPa   Napětí v ohybu
k = sigmaDo / sigma = 0.16   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást není bezpečná!"""

    expected_txt2 = """Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 
profil:
zatížení: pulzní
----------------------------------------------------------------
zadání:
Mo = 600 m N   Ohybový moment
natočení = 0 rad   Natočení profilu
Wo = 400 mm^3   Průřezový modul v ohybu
Re = 240 MPa   Mez kluzu
sigmaDo = 120 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 1500 MPa   Napětí v ohybu
k = sigmaDo / sigma = 0.08   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást není bezpečná!"""

    expected_txt3 = """Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 11 373
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
Mo = 600 m N   Ohybový moment
natočení = 0 rad   Natočení profilu
Wo = 400 mm^3   Průřezový modul v ohybu
Ix = 600 mm^4   Moment setrvačnosti
Re = 250 MPa   Mez kluzu
E = 210 GPa   Modul pružnosti
sigmaDo = 166.667 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 1500 MPa   Napětí v ohybu
delta = Mo / (E * Ix) = 4.7619 m^-1   Relativní průhyb
k = sigmaDo / sigma = 0.111111   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást není bezpečná!"""

    expected_txt4 = """Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 11 373
profil: TRKR 76x5
  D = 76.0 mm
  d = 66.0 mm
  t = 5.0 mm
zatížení: dynamický
----------------------------------------------------------------
zadání:
Mo = 600 m N   Ohybový moment
k = 5   Uživatelský požadavek bezpečnosti
natočení = 0 rad   Natočení profilu
Wo = π/32*(D⁴ - d⁴)/D = 18585.3 mm^3   Průřezový modul v ohybu
Ix = pi/64*(D^4 - d^4) = 706242 mm^4   Moment setrvačnosti
Re = 250 MPa   Mez kluzu
E = 210 GPa   Modul pružnosti
Lo = 200 mm   Délka nosníku
sigmaDo = 100 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 32.2836 MPa   Napětí v ohybu
delta = Mo / (E * Ix) = 0.00404556 m^-1   Relativní průhyb
y = Mo * Lo^2 / (3 * E * Ix) = 0.0539408 mm   Průhyb na volném konci
alfa = Mo * Lo / (2 * E * Ix) = 0.000404556 rad = 0.0231793°   Úhel natočení průřezu
k = sigmaDo / sigma = 3.09755   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Spoj není bezpečný!"""

    expected_txt5 = """Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
Mo = 600 m N   Ohybový moment
natočení = 0 rad   Natočení profilu
Wo = 400 mm^3   Průřezový modul v ohybu
Re = 240 MPa   Mez kluzu
sigmaDo = 160 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 1500 MPa   Napětí v ohybu
k = sigmaDo / sigma = 0.106667   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást není bezpečná!"""

    expected_txt6 = """Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 
profil:
zatížení: dynamický
----------------------------------------------------------------
zadání:
Mo = 600 m N   Ohybový moment
natočení = 0 rad   Natočení profilu
Wo = 400 mm^3   Průřezový modul v ohybu
Re = 240 MPa   Mez kluzu
sigmaDo = 96 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 1500 MPa   Napětí v ohybu
k = sigmaDo / sigma = 0.064   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást není bezpečná!"""

    expected_txt7 = """Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 
profil:
zatížení: rázový
----------------------------------------------------------------
zadání:
Mo = 600 m N   Ohybový moment
natočení = 0 rad   Natočení profilu
Wo = 400 mm^3   Průřezový modul v ohybu
Re = 240 MPa   Mez kluzu
sigmaDo = 80 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 1500 MPa   Napětí v ohybu
k = sigmaDo / sigma = 0.0533333   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást není bezpečná!"""

    expected_txt8 = """Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
Mo = 600 m N   Ohybový moment
natočení = 0 rad   Natočení profilu
Wo = 400 mm^3   Průřezový modul v ohybu
Ix = 600 mm^4   Moment setrvačnosti
E = 200 GPa   Modul pružnosti
sigmaDo = 120 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 1500 MPa   Napětí v ohybu
delta = Mo / (E * Ix) = 5 m^-1   Relativní průhyb
k = sigmaDo / sigma = 0.08   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást není bezpečná!"""

    expected_txt9 = """Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
Mo = 600 m N   Ohybový moment
natočení = 45°   Natočení profilu
Wo = 400 mm^3   Průřezový modul v ohybu
Re = 240 MPa   Mez kluzu
sigmaDo = 160 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 1500 MPa   Napětí v ohybu
k = sigmaDo / sigma = 0.106667   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást není bezpečná!"""

    # Test 1: Základní výpočet bez jednotek
    @testset "základní výpočet bez jednotek" begin
        VV, txt = namahaniohyb(Mo=600, Wo=400, sigmaDo=240)
        @test haskey(VV, :sigma)
        @test haskey(VV, :bezpecnost)
        @test haskey(VV, :info)
        @test VV[:info] == "namáhání v ohybu"
        @test VV[:sigma] > 0u"MPa"
        @test VV[:bezpecnost] > 0
        @test isa(txt, String)
        @test !isempty(txt)
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt1
    end

    # Test 2: Výpočet s jednotkami
    @testset "výpočet s jednotkami" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", sigmaDo=240u"MPa")
        @test haskey(VV, :sigma)
        @test VV[:sigma] > 0u"MPa"
        @test uconvert(u"N*m", VV[:Mo]) == 600u"N*m"
        @test uconvert(u"mm^3", VV[:Wo]) == 400u"mm^3"
        @test uconvert(u"MPa", VV[:sigmaDo]) == 240u"MPa"
        @test isa(txt, String)
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt1
    end

    # Test 3: Výpočet s Re a pulzním zatížením
    @testset "výpočet s Re a pulzním zatížením" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", zatizeni="pulzní")
        @test haskey(VV, :sigma)
        @test haskey(VV, :sigmaDo)
        @test haskey(VV, :Re)
        @test VV[:zatizeni] == "pulzní"
        @test VV[:sigma] > 0u"MPa"
        @test isa(txt, String)
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt2
    end

    # Test 4: Výpočet s materiálem a momentem setrvačnosti
    @testset "výpočet s materiálem" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Ix=600u"mm^4", mat="11373")
        @test haskey(VV, :sigma)
        @test haskey(VV, :Re)
        @test haskey(VV, :E)
        @test haskey(VV, :delta)
        @test VV[:Re] > 0u"MPa"
        @test VV[:E] > 0u"GPa"
        @test isa(txt, String)
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt3
    end

    # Test 4b: Výpočet s materiálem jako proměnná
    @testset "výpočet s materiálem jako proměnná" begin
        A1 = materialy("11373")
        @test A1 !== nothing
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Ix=600u"mm^4", mat=A1)
        @test haskey(VV, :sigma)
        @test haskey(VV, :Re)
        @test haskey(VV, :E)
        @test haskey(VV, :delta)
        @test VV[:Re] > 0u"MPa"
        @test VV[:E] > 0u"GPa"
        @test VV[:mat] == A1.name
        @test isa(txt, String)
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt3
    end

    # Test 4b: Výpočet s materiálem jako proměnná
    @testset "výpočet s materiálem jako proměnná" begin
        A1 = materialy("11373")
        @test A1 !== nothing
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Ix=600u"mm^4", mat=A1)
        @test haskey(VV, :sigma)
        @test haskey(VV, :Re)
        @test haskey(VV, :E)
        @test haskey(VV, :delta)
        @test VV[:Re] > 0u"MPa"
        @test VV[:E] > 0u"GPa"
        @test VV[:mat] == A1.name
        @test isa(txt, String)
    end

    # Test 5: Výpočet s profilem a délkou
    @testset "výpočet s profilem a délkou" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", profil="TRKR 76x5", mat="11373", 
            zatizeni="dynamický", natoceni=0u"rad", Lo=200u"mm", k=5)
        @test haskey(VV, :sigma)
        @test haskey(VV, :Wo)
        @test haskey(VV, :Ix)
        @test haskey(VV, :y)
        @test haskey(VV, :alfa)
        @test VV[:y] !== nothing
        @test uconvert(u"mm", VV[:y]) isa Quantity
        @test VV[:alfa] !== nothing
        @test uconvert(u"rad", VV[:alfa]) isa Quantity
        @test VV[:k] == 5
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt4
    end

    # Test 6: Statické zatížení (výchozí)
    @testset "statické zatížení" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", zatizeni="statický")
        @test VV[:zatizeni] == "statický"
        @test haskey(VV, :sigmaDo)
        @test isa(txt, String)
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt5
    end

    # Test 7: Pulzní zatížení
    @testset "pulzní zatížení" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", zatizeni="pulzní")
        @test VV[:zatizeni] == "pulzní"
        @test haskey(VV, :sigmaDo)
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt2
    end

    # Test 8: Dynamické zatížení
    @testset "dynamické zatížení" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", zatizeni="dynamický")
        @test VV[:zatizeni] == "dynamický"
        @test haskey(VV, :sigmaDo)
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt6
    end

    # Test 9: Rázové zatížení
    @testset "rázové zatížení" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", zatizeni="rázový")
        @test VV[:zatizeni] == "rázový"
        @test haskey(VV, :sigmaDo)
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt7
    end

    # Test 10: Výstup bez textu
    @testset "výstup bez textu" begin
        VV = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", return_text=false)
        @test isa(VV, Dict)
        @test haskey(VV, :sigma)
        @test haskey(VV, :bezpecnost)
    end

    # Test 11: Relativní průhyb
    @testset "relativní průhyb" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", sigmaDo=120u"MPa", Wo=400u"mm^3", Ix=600u"mm^4", E=200u"GPa")
        @test haskey(VV, :delta)
        @test VV[:delta] !== nothing
        @test uconvert(u"m^-1", VV[:delta]) isa Quantity
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt8
    end

    # Test 12: Průhyb na volném konci
    @testset "průhyb na volném konci" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", sigmaDo=120u"MPa", Wo=400u"mm^3", Ix=600u"mm^4", E=200u"GPa", Lo=200u"mm")
        @test haskey(VV, :y)
        @test VV[:y] !== nothing
        @test uconvert(u"mm", VV[:y]) isa Quantity
        @test VV[:y] > 0u"mm"
    end

    # Test 13: Úhel natočení
    @testset "úhel natočení" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", sigmaDo=120u"MPa", Wo=400u"mm^3", Ix=600u"mm^4", E=200u"GPa", Lo=200u"mm")
        @test haskey(VV, :alfa)
        @test VV[:alfa] !== nothing
        @test uconvert(u"rad", VV[:alfa]) isa Quantity
    end

    # Test 14: Ověření vzorců
    @testset "ověření vzorců" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa")
        @test VV[:sigma_str] == "Mo / Wo"
        @test VV[:bezpecnost_str] == "sigmaDo / sigma"
        # Ověření číselného výpočtu
        expected_sigma = uconvert(u"MPa", 600u"N*m" / 400u"mm^3")
        @test isapprox(uconvert(u"MPa", VV[:sigma]), expected_sigma, rtol=1e-5)
    end

    # Test 15: Bezpečnost - bezpečná součást
    @testset "bezpečná součást" begin
        VV, txt = namahaniohyb(Mo=200u"N*m", Wo=2000u"mm^3", Re=240u"MPa")
        @test VV[:bezpecnost] >= 1.5
        @test occursin("bezpečná", VV[:verdict])
    end

    # Test 16: Bezpečnost - hranice bezpečnosti
    @testset "hranice bezpečnosti" begin
        VV, txt = namahaniohyb(Mo=180u"N*m", Wo=1200u"mm^3", sigmaDo=160u"MPa")
        @test VV[:bezpecnost] >= 1.0 && VV[:bezpecnost] < 1.5
    end

    # Test 17: Bezpečnost - nebezpečná součást
    @testset "nebezpečná součást" begin
        VV, txt = namahaniohyb(Mo=800u"N*m", Wo=400u"mm^3", sigmaDo=80u"MPa")
        @test VV[:bezpecnost] < 1.0
        @test occursin("není bezpečná", VV[:verdict])
    end

    # Test 18: Vlastní požadavek bezpečnosti
    @testset "vlastní požadavek bezpečnosti" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", k=3)
        @test haskey(VV, :k)
        @test VV[:k] == 3
        @test isa(VV[:verdict], String)
    end

    # Test 19: Natočení profilu
    @testset "natočení profilu" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", natoceni=45u"deg")
        @test haskey(VV, :natoceni)
        @test VV[:natoceni] !== nothing
        assert_namahaniohyb_text_common(txt, VV)
        @test txt == expected_txt9
    end

end
