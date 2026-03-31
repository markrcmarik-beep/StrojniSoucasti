# ver: 2026-03-11
# Testovací skript pro funkci namahaniotl.jl
# Testuje namáhání na otlačení (plošný tlak) s různými typy zatížení

using StrojniSoucasti, Unitful, Test

function assert_namahaniotl_text_common(txt::String, VV::Dict{Symbol,Any})
    @test !isempty(txt)
    @test occursin("F = ", txt)
    @test occursin("S = ", txt)
    @test occursin("sigmaDotl = ", txt)
    @test occursin("sigma = $(VV[:sigma_str])", txt)
    @test occursin("k = $(VV[:bezpecnost_str])", txt)
    @test occursin(string(VV[:verdict]), txt)
end

@testset "namahaniotl" begin
    expected_txt1 = """Výpočet namáhání na otlačení
--------------------------------------------------------------
materiál: 
profil:
zatížení: statický
--------------------------------------------------------------
zadání:
F = 5000 N   Zatěžující síla
S = 120 mm^2   Kontaktní plocha
sigmaDotl = 240 MPa   Dovolené napětí na otlačení
--------------------------------------------------------------
výpočet:
sigma = F / S = 41.6667 MPa   Skutečné napětí na otlačení
k = sigmaDt / sigma = 5.76   Součinitel bezpečnosti
Výsledek posouzení: Spoj je bezpečný"""

    expected_txt2 = """Výpočet namáhání na otlačení
--------------------------------------------------------------
materiál: 
profil:
zatížení: statický
--------------------------------------------------------------
zadání:
F = 5000 N   Zatěžující síla
S = 120 mm^2   Kontaktní plocha
sigmaDotl = 240 MPa   Dovolené napětí na otlačení
Re = 240 MPa   Mez kluzu
--------------------------------------------------------------
výpočet:
sigma = F / S = 41.6667 MPa   Skutečné napětí na otlačení
k = sigmaDt / sigma = 5.76   Součinitel bezpečnosti
Výsledek posouzení: Spoj je bezpečný"""

    expected_txt3 = """Výpočet namáhání na otlačení
--------------------------------------------------------------
materiál: 11 373
profil:
zatížení: statický
--------------------------------------------------------------
zadání:
F = 5000 N   Zatěžující síla
S = 120 mm^2   Kontaktní plocha
sigmaDotl = 250 MPa   Dovolené napětí na otlačení
Re = 250 MPa   Mez kluzu
--------------------------------------------------------------
výpočet:
sigma = F / S = 41.6667 MPa   Skutečné napětí na otlačení
k = sigmaDt / sigma = 6   Součinitel bezpečnosti
Výsledek posouzení: Spoj je bezpečný"""

    expected_txt4 = """Výpočet namáhání na otlačení
--------------------------------------------------------------
materiál: 11 373
profil: PLO 20x20
  a = 20.0 mm
  b = 20.0 mm
  R = 0 mm
zatížení: statický
--------------------------------------------------------------
zadání:
F = 5000 N   Zatěžující síla
S = a*b - 4*S(R) = 400 mm^2   Kontaktní plocha
sigmaDotl = 250 MPa   Dovolené napětí na otlačení
Re = 250 MPa   Mez kluzu
--------------------------------------------------------------
výpočet:
sigma = F / S = 12.5 MPa   Skutečné napětí na otlačení
k = sigmaDt / sigma = 20   Součinitel bezpečnosti
Výsledek posouzení: Spoj je bezpečný"""

    expected_txt5 = """Výpočet namáhání na otlačení
--------------------------------------------------------------
materiál: 
profil:
zatížení: dynamický
--------------------------------------------------------------
zadání:
F = 5000 N   Zatěžující síla
S = 120 mm^2   Kontaktní plocha
sigmaDotl = 184.615 MPa   Dovolené napětí na otlačení
Re = 240 MPa   Mez kluzu
--------------------------------------------------------------
výpočet:
sigma = F / S = 41.6667 MPa   Skutečné napětí na otlačení
k = sigmaDt / sigma = 4.43077   Součinitel bezpečnosti
Výsledek posouzení: Spoj je bezpečný"""

    # Test 1: Základní výpočet bez jednotek
    @testset "základní výpočet bez jednotek" begin
        VV, txt = namahaniotl(F=5000, S=120, sigmaDotl=240)
        @test haskey(VV, :sigma)
        @test haskey(VV, :bezpecnost)
        @test haskey(VV, :info)
        @test VV[:info] == "namáhání na otlačení"
        @test VV[:sigma] > 0u"MPa"
        @test VV[:bezpecnost] > 0
        @test isa(txt, String)
        @test !isempty(txt)
        assert_namahaniotl_text_common(txt, VV)
        @test txt == expected_txt1
    end

    # Test 2: Výpočet s jednotkami
    @testset "výpočet s jednotkami" begin
        VV, txt = namahaniotl(F=5000u"N", S=120u"mm^2", sigmaDotl=240u"MPa")
        @test haskey(VV, :sigma)
        @test VV[:sigma] > 0u"MPa"
        @test uconvert(u"N", VV[:F]) == 5000u"N"
        @test uconvert(u"mm^2", VV[:S]) == 120u"mm^2"
        @test uconvert(u"MPa", VV[:sigmaDotl]) == 240u"MPa"
        @test isa(txt, String)
        assert_namahaniotl_text_common(txt, VV)
        @test txt == expected_txt1
    end

    # Test 3: Výpočet s Re
    @testset "výpočet s Re" begin
        VV, txt = namahaniotl(F=5000u"N", S=120u"mm^2", Re=240u"MPa")
        @test haskey(VV, :sigma)
        @test haskey(VV, :sigmaDotl)
        @test haskey(VV, :bezpecnost)
        @test VV[:sigma] > 0u"MPa"
        @test isa(txt, String)
        assert_namahaniotl_text_common(txt, VV)
        @test txt == expected_txt2
    end

    # Test 4: Výpočet s materiálem
    @testset "výpočet s materiálem" begin
        VV, txt = namahaniotl(F=5000u"N", S=120u"mm^2", mat="11373")
        @test haskey(VV, :sigma)
        @test haskey(VV, :sigmaDotl)
        @test haskey(VV, :info)
        @test VV[:info] == "namáhání na otlačení"
        @test isa(txt, String)
        assert_namahaniotl_text_common(txt, VV)
        @test txt == expected_txt3
    end

    # Test 4b: Výpočet s materiálem jako proměnná
    @testset "výpočet s materiálem jako proměnná" begin
        A1 = materialy("11373")
        @test A1 !== nothing
        VV, txt = namahaniotl(F=5000u"N", S=120u"mm^2", mat=A1)
        @test haskey(VV, :sigma)
        @test haskey(VV, :sigmaDotl)
        @test VV[:mat] == A1.name
        @test isa(txt, String)
        assert_namahaniotl_text_common(txt, VV)
        @test txt == expected_txt3
    end

    # Test 5: Výpočet s profilem
    @testset "výpočet s profilem" begin
        VV, txt = namahaniotl(F=5000u"N", profil="PLO 20x20", mat="11373")
        @test haskey(VV, :sigma)
        @test haskey(VV, :S)
        @test VV[:S] > 0u"mm^2"
        @test haskey(VV, :profil)
        @test isa(txt, String)
        assert_namahaniotl_text_common(txt, VV)
        @test txt == expected_txt4
    end

    # Test 6: Statické zatížení (výchozí)
    @testset "statické zatížení" begin
        VV, txt = namahaniotl(F=5000u"N", S=120u"mm^2", Re=240u"MPa", zatizeni="statický")
        @test VV[:zatizeni] == "statický"
        @test haskey(VV, :sigmaDotl)
        @test isa(txt, String)
        assert_namahaniotl_text_common(txt, VV)
        @test txt == expected_txt2
    end

    # Test 7: Dynamické zatížení
    @testset "dynamické zatížení" begin
        VV, txt = namahaniotl(F=5000u"N", S=120u"mm^2", Re=240u"MPa", zatizeni="dynamický")
        @test VV[:zatizeni] == "dynamický"
        @test haskey(VV, :sigmaDotl)
        @test isa(txt, String)
        assert_namahaniotl_text_common(txt, VV)
        @test txt == expected_txt5
    end

    # Test 8: Výstup bez textu
    @testset "výstup bez textu" begin
        VV = namahaniotl(F=5000u"N", S=120u"mm^2", Re=240u"MPa", return_text=false)
        @test isa(VV, Dict)
        @test haskey(VV, :sigma)
        @test haskey(VV, :bezpecnost)
    end

    # Test 9: Ověření výpočtu napětí
    @testset "ověření výpočtu napětí" begin
        VV, txt = namahaniotl(F=5000u"N", S=120u"mm^2", Re=240u"MPa")
        # Ověření číselného výpočtu: sigma = F / S_otl
        expected_sigma = uconvert(u"MPa", 5000u"N" / 120u"mm^2")
        @test isapprox(uconvert(u"MPa", VV[:sigma]), expected_sigma, rtol=1e-5)
    end

    # Test 10: Bezpečnost - bezpečný spoj
    @testset "bezpečný spoj" begin
        VV, txt = namahaniotl(F=2000u"N", S=120u"mm^2", Re=240u"MPa")
        @test VV[:bezpecnost] >= 1.5
        @test occursin("bezpečný", VV[:verdict])
    end

    # Test 11: Bezpečnost - hranice bezpečnosti
    @testset "hranice bezpečnosti" begin
        VV, txt = namahaniotl(F=7800u"N", S=190u"mm^2", sigmaDotl=100u"MPa")
        @test VV[:bezpecnost] >= 1.0 && VV[:bezpecnost] < 3
    end

    # Test 12: Bezpečnost - nebezpečný spoj
    @testset "nebezpečný spoj" begin
        VV, txt = namahaniotl(F=10000u"N", S=100u"mm^2", sigmaDotl=80u"MPa")
        @test VV[:bezpecnost] < 1.0
        @test occursin("není bezpečný", VV[:verdict])
    end

    # Test 13: Kladná síla
    @testset "kladná síla" begin
        VV, txt = namahaniotl(F=5000u"N", S=120u"mm^2", sigmaDotl=240u"MPa")
        @test VV[:F] > 0u"N"
    end

    # Test 14: Kladná kontaktní plocha
    @testset "kladná kontaktní plocha" begin
        VV, txt = namahaniotl(F=5000u"N", S=120u"mm^2", sigmaDotl=240u"MPa")
        @test VV[:S] > 0u"mm^2"
    end

    # Test 15: Kladné dovolené napětí
    @testset "kladné dovolené napětí" begin
        VV, txt = namahaniotl(F=5000u"N", S=120u"mm^2", Re=240u"MPa")
        @test VV[:sigmaDotl] > 0u"MPa"
    end

end
