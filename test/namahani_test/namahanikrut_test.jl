# ver: 2026-03-22
# Testovací skript pro funkci namahanikrut.jl
# Testuje namáhání v krutu s různými typy zatížení

using StrojniSoucasti, Unitful, Test

function assert_namahanikrut_text_common(txt::String, VV::Dict{Symbol,Any})
    @test !isempty(txt)
    @test occursin("Mk = ", txt)
    @test occursin("Wk = ", txt)
    @test occursin("tauDk = ", txt)
    @test occursin("tau = $(VV[:tau_str])", txt)
    @test occursin("k = $(VV[:bezpecnost_str])", txt)
    @test occursin(string(VV[:verdict]), txt)
end

@testset "namahanikrut" begin
    expected_txt1 = """Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 6000 m N   Krouticí moment
Wk =  = 400 mm^3   Průřezový modul v krutu
tauDk = 240 MPa   Dovolené napětí v krutu
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 15000 MPa   Napětí v krutu
k = tauDk / tau = 0.016   Součinitel bezpečnosti
Bezpečnost spoje: Spoj není bezpečný!"""

    expected_txt2 = """Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 200 m N   Krouticí moment
Wk =  = 400 mm^3   Průřezový modul v krutu
tauDk = 81.5083 MPa   Dovolené napětí v krutu
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 500 MPa   Napětí v krutu
k = tauDk / tau = 0.163017   Součinitel bezpečnosti
Bezpečnost spoje: Spoj není bezpečný!"""

    expected_txt3 = """Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 11 373
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 120 m N   Krouticí moment
Wk =  = 2200 mm^3   Průřezový modul v krutu
Ip =  = 25000 mm^4   Polární moment setrvačnosti
tauDk = 84.9045 MPa   Dovolené napětí v krutu
G = 81 GPa   Smykový modul
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 54.5455 MPa   Napětí v krutu
theta = Mk / (G * Ip) = 0.0592593 rad m^-1   Poměrné zkroucení
theta = 3.39531 ° m^-1   Poměrné zkroucení
k = tauDk / tau = 1.55658   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt4 = """Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 16 440
profil: TRKR 40x5
  D = 40.0 mm
  d = 30.0 mm
  t = 5.0 mm
zatížení: rázový
----------------------------------------------------------------
zadání:
Mk = 300 m N   Krouticí moment
k = 5   Uživatelský požadavek bezpečnosti
Wk = π/16*(D⁴ - d⁴)/D = 8590.29 mm^3   Průřezový modul v krutu
Ip = π/32*(D⁴ - d⁴) = 171806 mm^4   Polární moment setrvačnosti
tauDk = 72.1688 MPa   Dovolené napětí v krutu
G = 81 GPa   Smykový modul
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 34.9231 MPa   Napětí v krutu
phi = (Mk * L0) / (G * Ip) = 0.00194017 rad   Úhel zkroucení
phi = 0.111164°   Úhel zkroucení
theta = Mk / (G * Ip) = 0.0215575 rad m^-1   Poměrné zkroucení
theta = 1.23515 ° m^-1   Poměrné zkroucení
k = tauDk / tau = 2.0665   Součinitel bezpečnosti
Bezpečnost spoje: Spoj není bezpečný!"""

    expected_txt5 = """Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 
profil:
zatížení: pulzní
----------------------------------------------------------------
zadání:
Mk = 200 m N   Krouticí moment
Wk =  = 400 mm^3   Průřezový modul v krutu
tauDk = 62.9837 MPa   Dovolené napětí v krutu
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 500 MPa   Napětí v krutu
k = tauDk / tau = 0.125967   Součinitel bezpečnosti
Bezpečnost spoje: Spoj není bezpečný!"""

    expected_txt6 = """Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 
profil:
zatížení: dynamický
----------------------------------------------------------------
zadání:
Mk = 200 m N   Krouticí moment
Wk =  = 400 mm^3   Průřezový modul v krutu
tauDk = 51.32 MPa   Dovolené napětí v krutu
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 500 MPa   Napětí v krutu
k = tauDk / tau = 0.10264   Součinitel bezpečnosti
Bezpečnost spoje: Spoj není bezpečný!"""

    expected_txt7 = """Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 
profil:
zatížení: rázový
----------------------------------------------------------------
zadání:
Mk = 200 m N   Krouticí moment
Wk =  = 400 mm^3   Průřezový modul v krutu
tauDk = 43.3013 MPa   Dovolené napětí v krutu
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 500 MPa   Napětí v krutu
k = tauDk / tau = 0.0866025   Součinitel bezpečnosti
Bezpečnost spoje: Spoj není bezpečný!"""

    expected_txt8 = """Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 
profil:
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 200 m N   Krouticí moment
Wk =  = 400 mm^3   Průřezový modul v krutu
Ip =  = 25000 mm^4   Polární moment setrvačnosti
tauDk = 110 MPa   Dovolené napětí v krutu
G = 80 GPa   Smykový modul
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 500 MPa   Napětí v krutu
theta = Mk / (G * Ip) = 0.1 rad m^-1   Poměrné zkroucení
theta = 5.72958 ° m^-1   Poměrné zkroucení
k = tauDk / tau = 0.22   Součinitel bezpečnosti
Bezpečnost spoje: Spoj není bezpečný!"""

    # Test 1: Základní výpočet s explicitními hodnotami (bez jednotek)
    @testset "základní výpočet bez jednotek" begin
        VV, txt = namahanikrut(Mk=6000, Wk=400, tauDk=240)
        @test haskey(VV, :tau)
        @test haskey(VV, :bezpecnost)
        @test haskey(VV, :info)
        @test VV[:info] == "namáhání v krutu"
        @test VV[:tau] > 0u"MPa"
        @test VV[:bezpecnost] > 0
        @test isa(txt, String)
        @test !isempty(txt)
        assert_namahanikrut_text_common(txt, VV)
        @test txt == expected_txt1
    end

    # Test 2: Výpočet s jednotkami
    @testset "výpočet s jednotkami" begin
        VV, txt = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa")
        @test haskey(VV, :tau)
        @test haskey(VV, :tauDk)
        @test VV[:tau] > 0u"MPa"
        @test VV[:tauDk] > 0u"MPa"
        @test uconvert(u"N*m", VV[:Mk]) == 200u"N*m"
        @test isa(txt, String)
        assert_namahanikrut_text_common(txt, VV)
        @test txt == expected_txt2
    end

    # Test 3: Výpočet s materiálem a polárním momentem
    @testset "výpočet s materiálem" begin
        VV, txt = namahanikrut(Mk=120u"N*m", Wk=2200u"mm^3", Ip=25000u"mm^4", mat="11373")
        @test haskey(VV, :tau)
        @test haskey(VV, :tauDk)
        @test haskey(VV, :Re)
        @test haskey(VV, :G)
        @test VV[:Re] > 0u"MPa"
        @test VV[:G] > 0u"GPa"
        @test isa(txt, String)
        assert_namahanikrut_text_common(txt, VV)
        @test txt == expected_txt3
    end

    # Test 3b: Výpočet s materiálem jako proměnná
    @testset "výpočet s materiálem jako proměnná" begin
        A1 = materialy("11373")
        @test A1 !== nothing
        VV, txt = namahanikrut(Mk=120u"N*m", Wk=2200u"mm^3", Ip=25000u"mm^4", mat=A1)
        @test haskey(VV, :tau)
        @test haskey(VV, :tauDk)
        @test haskey(VV, :Re)
        @test haskey(VV, :G)
        @test VV[:Re] > 0u"MPa"
        @test VV[:G] > 0u"GPa"
        @test VV[:mat] == A1.name
        @test isa(txt, String)
        assert_namahanikrut_text_common(txt, VV)
        @test txt == expected_txt3
    end

    # Test 3b: Výpočet s materiálem jako proměnná
    @testset "výpočet s materiálem jako proměnná" begin
        A1 = materialy("11373")
        @test A1 !== nothing
        VV, txt = namahanikrut(Mk=120u"N*m", Wk=2200u"mm^3", Ip=25000u"mm^4", mat=A1)
        @test haskey(VV, :tau)
        @test haskey(VV, :tauDk)
        @test haskey(VV, :Re)
        @test haskey(VV, :G)
        @test VV[:Re] > 0u"MPa"
        @test VV[:G] > 0u"GPa"
        @test VV[:mat] == A1.name
        @test isa(txt, String)
    end

    # Test 4: Výpočet s profilem a délkou (úhel zkroucení)
    @testset "výpočet s profilem a délkou" begin
        VV, txt = namahanikrut(Mk=300u"N*m", profil="TRKR 40x5", mat="16440", L0=90u"mm", zatizeni="rázový", k=5)
        @test haskey(VV, :tau)
        @test haskey(VV, :Wk)
        @test haskey(VV, :Ip)
        @test haskey(VV, :phi)
        @test VV[:phi] !== nothing
        @test uconvert(u"rad", VV[:phi]) isa Quantity
        @test haskey(VV, :k)
        @test VV[:k] == 5
        assert_namahanikrut_text_common(txt, VV)
        @test txt == expected_txt4
    end

    # Test 5: Statické zatížení (výchozí)
    @testset "statické zatížení" begin
        VV, txt = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa", zatizeni="statický")
        @test VV[:zatizeni] == "statický"
        @test haskey(VV, :tauDk)
        @test isa(txt, String)
        assert_namahanikrut_text_common(txt, VV)
        @test txt == expected_txt2
    end

    # Test 6: Pulzní zatížení
    @testset "pulzní zatížení" begin
        VV, txt = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa", zatizeni="pulzní")
        @test VV[:zatizeni] == "pulzní"
        @test haskey(VV, :tauDk)
        assert_namahanikrut_text_common(txt, VV)
        @test txt == expected_txt5
    end

    # Test 7: Dynamické zatížení
    @testset "dynamické zatížení" begin
        VV, txt = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa", zatizeni="dynamický")
        @test VV[:zatizeni] == "dynamický"
        @test haskey(VV, :tauDk)
        assert_namahanikrut_text_common(txt, VV)
        @test txt == expected_txt6
    end

    # Test 8: Rázové zatížení
    @testset "rázové zatížení" begin
        VV, txt = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa", zatizeni="rázový")
        @test VV[:zatizeni] == "rázový"
        @test haskey(VV, :tauDk)
        assert_namahanikrut_text_common(txt, VV)
        @test txt == expected_txt7
    end

    # Test 9: Výstup bez textu
    @testset "výstup bez textu" begin
        VV = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa", return_text=false)
        @test isa(VV, Dict)
        @test haskey(VV, :tau)
        @test haskey(VV, :bezpecnost)
    end

    # Test 10: Poměrné zkroucení (theta)
    @testset "poměrné zkroucení" begin
        VV, txt = namahanikrut(Mk=200u"N*m", tauDk=110u"MPa" , Wk=400u"mm^3", Ip=25000u"mm^4", G=80u"GPa")
        @test haskey(VV, :theta)
        @test VV[:theta] !== nothing
        @test uconvert(u"rad/m", VV[:theta]) isa Quantity
        assert_namahanikrut_text_common(txt, VV)
        @test txt == expected_txt8
    end

    # Test 11: Ověření vzorců
    @testset "ověření vzorců" begin
        VV, txt = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa")
        @test VV[:tau_str] == "Mk / Wk"
        @test VV[:bezpecnost_str] == "tauDk / tau"
        # Ověření číselného výpočtu
        expected_tau = uconvert(u"MPa", 200u"N*m" / 400u"mm^3")
        @test isapprox(uconvert(u"MPa", VV[:tau]), expected_tau, rtol=1e-5)
    end

    # Test 12: Bezpečnost - bezpečný spoj
    @testset "bezpečný spoj" begin
        VV, txt = namahanikrut(Mk=100u"N*m", Wk=1600u"mm^3", Re=280u"MPa")
        @test VV[:bezpecnost] >= 1.5
        @test occursin("bezpečný", VV[:verdict])
    end

    # Test 13: Bezpečnost - hranice bezpečnosti
    @testset "hranice bezpečnosti" begin
        VV, txt = namahanikrut(Mk=110u"N*m", Wk=650u"mm^3", tauDk=180u"MPa")
        @test VV[:bezpecnost] >= 1.0 && VV[:bezpecnost] < 1.5
    end

    # Test 14: Bezpečnost - nebezpečný spoj
    @testset "nebezpečný spoj" begin
        VV, txt = namahanikrut(Mk=500u"N*m", Wk=400u"mm^3", tauDk=80u"MPa")
        @test VV[:bezpecnost] < 1.0
        @test occursin("není bezpečný", VV[:verdict])
    end

    # Test 15: Vlastní požadavek bezpečnosti
    @testset "vlastní požadavek bezpečnosti" begin
        VV, txt = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa", k=3)
        @test haskey(VV, :k)
        @test VV[:k] == 3
        @test isa(VV[:verdict], String)
    end

end
