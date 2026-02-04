# ver: 2026-02-03
# Testovací skript pro funkci namahaniotl.jl
# Testuje namáhání na otlačení (plošný tlak) s různými typy zatížení

using StrojniSoucasti, Unitful, Test

@testset "namahaniotl" begin

    # Test 1: Základní výpočet bez jednotek
    @testset "základní výpočet bez jednotek" begin
        VV, txt = namahaniotl(F=5000, S_otl=120, sigmaDotl=240)
        @test haskey(VV, :sigma)
        @test haskey(VV, :bezpecnost)
        @test haskey(VV, :info)
        @test VV[:info] == "namáhání na otlačení"
        @test VV[:sigma] > 0u"MPa"
        @test VV[:bezpecnost] > 0
        @test isa(txt, String)
        @test !isempty(txt)
    end

    # Test 2: Výpočet s jednotkami
    @testset "výpočet s jednotkami" begin
        VV, txt = namahaniotl(F=5000u"N", S_otl=120u"mm^2", sigmaDotl=240u"MPa")
        @test haskey(VV, :sigma)
        @test VV[:sigma] > 0u"MPa"
        @test uconvert(u"N", VV[:F]) == 5000u"N"
        @test uconvert(u"mm^2", VV[:S_otl]) == 120u"mm^2"
        @test uconvert(u"MPa", VV[:sigmaDotl]) == 240u"MPa"
        @test isa(txt, String)
    end

    # Test 3: Výpočet s Re
    @testset "výpočet s Re" begin
        VV, txt = namahaniotl(F=5000u"N", S_otl=120u"mm^2", Re=240u"MPa")
        @test haskey(VV, :sigma)
        @test haskey(VV, :sigmaDotl)
        @test haskey(VV, :bezpecnost)
        @test VV[:sigma] > 0u"MPa"
        @test isa(txt, String)
    end

    # Test 4: Výpočet s materiálem
    @testset "výpočet s materiálem" begin
        VV, txt = namahaniotl(F=5000u"N", S_otl=120u"mm^2", mat="11373")
        @test haskey(VV, :sigma)
        @test haskey(VV, :sigmaDotl)
        @test haskey(VV, :info)
        @test VV[:info] == "namáhání na otlačení"
        @test isa(txt, String)
    end

    # Test 5: Výpočet s profilem
    @testset "výpočet s profilem" begin
        VV, txt = namahaniotl(F=5000u"N", profil="PLO 20x20", mat="11373")
        @test haskey(VV, :sigma)
        @test haskey(VV, :S_otl)
        @test VV[:S_otl] > 0u"mm^2"
        @test haskey(VV, :profil)
        @test isa(txt, String)
    end

    # Test 6: Statické zatížení (výchozí)
    @testset "statické zatížení" begin
        VV, txt = namahaniotl(F=5000u"N", S_otl=120u"mm^2", Re=240u"MPa", zatizeni="statický")
        @test VV[:zatizeni] == "statický"
        @test haskey(VV, :sigmaDotl)
        @test isa(txt, String)
    end

    # Test 7: Dynamické zatížení
    @testset "dynamické zatížení" begin
        VV, txt = namahaniotl(F=5000u"N", S_otl=120u"mm^2", Re=240u"MPa", zatizeni="dynamický")
        @test VV[:zatizeni] == "dynamický"
        @test haskey(VV, :sigmaDotl)
        @test isa(txt, String)
    end

    # Test 8: Výstup bez textu
    @testset "výstup bez textu" begin
        VV = namahaniotl(F=5000u"N", S_otl=120u"mm^2", Re=240u"MPa", return_text=false)
        @test isa(VV, Dict)
        @test haskey(VV, :sigma)
        @test haskey(VV, :bezpecnost)
    end

    # Test 9: Ověření výpočtu napětí
    @testset "ověření výpočtu napětí" begin
        VV, txt = namahaniotl(F=5000u"N", S_otl=120u"mm^2", Re=240u"MPa")
        # Ověření číselného výpočtu: sigma = F / S_otl
        expected_sigma = uconvert(u"MPa", 5000u"N" / 120u"mm^2")
        @test isapprox(uconvert(u"MPa", VV[:sigma]), expected_sigma, rtol=1e-5)
    end

    # Test 10: Bezpečnost - bezpečný spoj
    @testset "bezpečný spoj" begin
        VV, txt = namahaniotl(F=2000u"N", S_otl=120u"mm^2", Re=240u"MPa")
        @test VV[:bezpecnost] >= 1.5
        @test occursin("bezpečný", VV[:verdict])
    end

    # Test 11: Bezpečnost - hranice bezpečnosti
    @testset "hranice bezpečnosti" begin
        VV, txt = namahaniotl(F=7800u"N", S_otl=190u"mm^2", sigmaDotl=100u"MPa")
        @test VV[:bezpecnost] >= 1.0 && VV[:bezpecnost] < 3
    end

    # Test 12: Bezpečnost - nebezpečný spoj
    @testset "nebezpečný spoj" begin
        VV, txt = namahaniotl(F=10000u"N", S_otl=100u"mm^2", sigmaDotl=80u"MPa")
        @test VV[:bezpecnost] < 1.0
        @test occursin("není bezpečný", VV[:verdict])
    end

    # Test 13: Kladná síla
    @testset "kladná síla" begin
        VV, txt = namahaniotl(F=5000u"N", S_otl=120u"mm^2", sigmaDotl=240u"MPa")
        @test VV[:F] > 0u"N"
    end

    # Test 14: Kladná kontaktní plocha
    @testset "kladná kontaktní plocha" begin
        VV, txt = namahaniotl(F=5000u"N", S_otl=120u"mm^2", sigmaDotl=240u"MPa")
        @test VV[:S_otl] > 0u"mm^2"
    end

    # Test 15: Kladné dovolené napětí
    @testset "kladné dovolené napětí" begin
        VV, txt = namahaniotl(F=5000u"N", S_otl=120u"mm^2", Re=240u"MPa")
        @test VV[:sigmaDotl] > 0u"MPa"
    end

end
