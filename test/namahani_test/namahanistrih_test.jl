# ver: 2026-03-22
# Testovací skript pro funkci namahanistrih.jl
# Testuje namáhání ve střihu s různými typy zatížení

using StrojniSoucasti, Unitful, Test

function assert_namahanistrih_text_common(txt::String, VV::Dict{Symbol,Any})
    @test !isempty(txt)
    @test occursin("F = ", txt)
    @test occursin("S = ", txt)
    @test occursin("tauDs = ", txt)
    @test occursin("tau = $(VV[:tau_str])", txt)
    @test occursin("k = $(VV[:bezpecnost_str])", txt)
    @test occursin(string(VV[:verdict]), txt)
end

@testset "namahanistrih" begin
    expected_txt1 = """Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 
profil:
zatížení: statický
--------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
tauDs = 240 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 15 MPa   Napětí ve střihu
k = tauDs / tau = 16   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt2 = """Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 
profil:
zatížení: pulzní
--------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
Re = 240 MPa   Mez kluzu
tauDs = 69.282 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 15 MPa   Napětí ve střihu
k = tauDs / tau = 4.6188   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt3 = """Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 11 373
profil:
zatížení: statický
--------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
Re = 250 MPa   Mez kluzu
G = 81 GPa   Modul pružnosti ve smyku
tauDs = 96.225 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 15 MPa   Napětí ve střihu
gamma = tau / G = 0.185185   Deformace ve smyku
k = tauDs / tau = 6.415   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt4 = """Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 11 373
profil: TRKR 52x5
  D = 52.0 mm
  d = 42.0 mm
  t = 5.0 mm
zatížení: dynamický
--------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
k = 5   Uživatelský požadavek bezpečnosti
S = π*(D² - d²)/4 = 738.274 mm^2   Plocha průřezu
Re = 250 MPa   Mez kluzu
G = 81 GPa   Modul pružnosti ve smyku
tauDs = 57.735 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 8.12706 MPa   Napětí ve střihu
gamma = tau / G = 0.100334   Deformace ve smyku
k = tauDs / tau = 7.10405   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt5 = """Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 
profil:
zatížení: statický
--------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
Re = 240 MPa   Mez kluzu
tauDs = 92.376 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 15 MPa   Napětí ve střihu
k = tauDs / tau = 6.1584   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt6 = """Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 
profil:
zatížení: dynamický
--------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
Re = 240 MPa   Mez kluzu
tauDs = 55.4256 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 15 MPa   Napětí ve střihu
k = tauDs / tau = 3.69504   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt7 = """Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 
profil:
zatížení: rázový
--------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
Re = 240 MPa   Mez kluzu
tauDs = 46.188 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 15 MPa   Napětí ve střihu
k = tauDs / tau = 3.0792   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    expected_txt8 = """Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 
profil:
zatížení: statický
--------------------------------------------------------------
zadání:
F = 6000 N   Zatěžující síla
S = 400 mm^2   Plocha průřezu
G = 80 GPa   Modul pružnosti ve smyku
tauDs = 190 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 15 MPa   Napětí ve střihu
gamma = tau / G = 0.1875   Deformace ve smyku
k = tauDs / tau = 12.6667   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný"""

    # Test 1: Základní výpočet bez jednotek
    @testset "základní výpočet bez jednotek" begin
        VV, txt = namahanistrih(F=6000, S=400, tauDs=240)
        @test haskey(VV, :tau)
        @test haskey(VV, :bezpecnost)
        @test haskey(VV, :info)
        @test VV[:info] == "namáhání ve střihu"
        @test VV[:tau] > 0u"MPa"
        @test VV[:bezpecnost] > 0
        @test isa(txt, String)
        @test !isempty(txt)
        assert_namahanistrih_text_common(txt, VV)
        @test txt == expected_txt1
    end

    # Test 2: Výpočet s jednotkami
    @testset "výpočet s jednotkami" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", tauDs=240u"MPa")
        @test haskey(VV, :tau)
        @test VV[:tau] > 0u"MPa"
        @test uconvert(u"N", VV[:F]) == 6000u"N"
        @test uconvert(u"mm^2", VV[:S]) == 400u"mm^2"
        @test uconvert(u"MPa", VV[:tauDs]) == 240u"MPa"
        @test isa(txt, String)
        assert_namahanistrih_text_common(txt, VV)
        @test txt == expected_txt1
    end

    # Test 3: Výpočet s Re a pulzním zatížením
    @testset "výpočet s Re a pulzním zatížením" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="pulzní")
        @test haskey(VV, :tau)
        @test haskey(VV, :tauDs)
        @test haskey(VV, :Re)
        @test VV[:zatizeni] == "pulzní"
        @test VV[:tau] > 0u"MPa"
        @test isa(txt, String)
        assert_namahanistrih_text_common(txt, VV)
        @test txt == expected_txt2
    end

    # Test 4: Výpočet s materiálem
    @testset "výpočet s materiálem" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", mat="11373")
        @test haskey(VV, :tau)
        @test haskey(VV, :Re)
        @test haskey(VV, :G)
        @test VV[:Re] > 0u"MPa"
        @test VV[:G] > 0u"GPa"
        @test isa(txt, String)
        assert_namahanistrih_text_common(txt, VV)
        @test txt == expected_txt3
    end

    # Test 4b: Výpočet s materiálem jako struct z materialy()
    @testset "výpočet s materiálem jako proměnná" begin
        A1 = materialy("11373")
        @test A1 !== nothing
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", mat=A1)
        @test haskey(VV, :tau)
        @test haskey(VV, :Re)
        @test haskey(VV, :G)
        @test VV[:Re] > 0u"MPa"
        @test VV[:G] > 0u"GPa"
        @test VV[:mat] == A1.name
        @test isa(txt, String)
        assert_namahanistrih_text_common(txt, VV)
        @test txt == expected_txt3
    end

    # Test 4b: Výpočet s materiálem jako struct z materialy()
    @testset "výpočet s materiálem jako proměnná" begin
        A1 = materialy("11373")
        @test A1 !== nothing
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", mat=A1)
        @test haskey(VV, :tau)
        @test haskey(VV, :Re)
        @test haskey(VV, :G)
        @test VV[:Re] > 0u"MPa"
        @test VV[:G] > 0u"GPa"
        @test VV[:mat] == A1.name
        @test isa(txt, String)
    end

    # Test 5: Výpočet s profilem
    @testset "výpočet s profilem" begin
        VV, txt = namahanistrih(F=6000u"N", profil="TRKR 52x5", mat="11373", zatizeni="dynamický", k=5)
        @test haskey(VV, :tau)
        @test haskey(VV, :S)
        @test VV[:S] > 0u"mm^2"
        @test haskey(VV, :k)
        @test VV[:k] == 5
        @test isa(txt, String)
        assert_namahanistrih_text_common(txt, VV)
        @test txt == expected_txt4
    end

    # Test 6: Statické zatížení (výchozí)
    @testset "statické zatížení" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="statický")
        @test VV[:zatizeni] == "statický"
        @test haskey(VV, :tauDs)
        @test isa(txt, String)
        assert_namahanistrih_text_common(txt, VV)
        @test txt == expected_txt5
    end

    # Test 7: Pulzní zatížení
    @testset "pulzní zatížení" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="pulzní")
        @test VV[:zatizeni] == "pulzní"
        @test haskey(VV, :tauDs)
        assert_namahanistrih_text_common(txt, VV)
        @test txt == expected_txt2
    end

    # Test 8: Dynamické zatížení
    @testset "dynamické zatížení" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="dynamický")
        @test VV[:zatizeni] == "dynamický"
        @test haskey(VV, :tauDs)
        assert_namahanistrih_text_common(txt, VV)
        @test txt == expected_txt6
    end

    # Test 9: Rázové zatížení
    @testset "rázové zatížení" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="rázový")
        @test VV[:zatizeni] == "rázový"
        @test haskey(VV, :tauDs)
        assert_namahanistrih_text_common(txt, VV)
        @test txt == expected_txt7
    end

    # Test 10: Výstup bez textu
    @testset "výstup bez textu" begin
        VV = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa", return_text=false)
        @test isa(VV, Dict)
        @test haskey(VV, :tau)
        @test haskey(VV, :bezpecnost)
    end

    # Test 11: Deformace ve smyku
    @testset "deformace ve smyku" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", tauDs=190u"MPa", G=80u"GPa")
        @test haskey(VV, :gamma)
        @test VV[:gamma] !== nothing
        @test isa(VV[:gamma], Number)
        assert_namahanistrih_text_common(txt, VV)
        @test txt == expected_txt8
    end

    # Test 12: Ověření vzorců
    @testset "ověření vzorců" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa")
        @test VV[:tau_str] == "F / S"
        @test VV[:bezpecnost_str] == "tauDs / tau"
        # Ověření číselného výpočtu
        expected_tau = uconvert(u"MPa", 6000u"N" / 400u"mm^2")
        @test isapprox(uconvert(u"MPa", VV[:tau]), expected_tau, rtol=1e-5)
    end

    # Test 13: Bezpečnost - bezpečný spoj
    @testset "bezpečný spoj" begin
        VV, txt = namahanistrih(F=3000u"N", S=400u"mm^2", Re=240u"MPa")
        @test VV[:bezpecnost] >= 1.5
        @test occursin("bezpečný", VV[:verdict])
    end

    # Test 14: Bezpečnost - hranice bezpečnosti
    @testset "hranice bezpečnosti" begin
        VV, txt = namahanistrih(F=8000u"N", S=400u"mm^2", tauDs=120u"MPa")
        @test VV[:bezpecnost] >= 1.0 && VV[:bezpecnost] < 8
    end

    # Test 15: Bezpečnost - nebezpečný spoj
    @testset "nebezpečný spoj" begin
        VV, txt = namahanistrih(F=16000u"N", S=180u"mm^2", tauDs=80u"MPa")
        @test VV[:bezpecnost] < 1.0
        @test occursin("není bezpečný", VV[:verdict])
    end

    # Test 16: Vlastní požadavek bezpečnosti
    @testset "vlastní požadavek bezpečnosti" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa", k=3)
        @test haskey(VV, :k)
        @test VV[:k] == 3
        @test isa(VV[:verdict], String)
    end

    # Test 17: Kladná síla (validace)
    @testset "kladná síla" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", tauDs=240u"MPa")
        @test VV[:F] > 0u"N"
    end

end
