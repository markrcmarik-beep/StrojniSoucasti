# ver: 2026-02-03
# Testovací skript pro funkci namahanitlak.jl
# Testuje namáhání v tlaku s různými typy zatížení

using StrojniSoucasti, Unitful, Test

@testset "namahanitlak" begin

    # Test 1: Základní výpočet bez jednotek
    @testset "základní výpočet bez jednotek" begin
        VV, txt = namahanitlak(F=6000, S=400, sigmaDt=240)
        @test haskey(VV, :sigma)
        @test haskey(VV, :bezpecnost)
        @test haskey(VV, :info)
        @test VV[:info] == "namáhání v tlaku"
        @test VV[:sigma] > 0u"MPa"
        @test VV[:bezpecnost] > 0
        @test isa(txt, String)
        @test !isempty(txt)
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
    end

    # Test 3: Výpočet s Re
    @testset "výpočet s Re" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa")
        @test haskey(VV, :sigma)
        @test haskey(VV, :sigmaDt)
        @test haskey(VV, :Re)
        @test VV[:sigma] > 0u"MPa"
        @test isa(txt, String)
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
    end

    # Test 6: Statické zatížení (výchozí)
    @testset "statické zatížení" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="statický")
        @test VV[:zatizeni] == "statický"
        @test haskey(VV, :sigmaDt)
        @test isa(txt, String)
    end

    # Test 7: Dynamické zatížení
    @testset "dynamické zatížení" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="dynamický")
        @test VV[:zatizeni] == "dynamický"
        @test haskey(VV, :sigmaDt)
    end

    # Test 8: Rázové zatížení
    @testset "rázové zatížení" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="rázový")
        @test VV[:zatizeni] == "rázový"
        @test haskey(VV, :sigmaDt)
    end

    # Test 9: Výstup bez textu
    @testset "výstup bez textu" begin
        VV = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa", return_text=false)
        @test isa(VV, Dict)
        @test haskey(VV, :sigma)
        @test haskey(VV, :bezpecnost)
    end

    # Test 10: Poměrné zkrácení
    @testset "poměrné zkrácení" begin
        VV, txt = namahanitlak(F=6000u"N", sigmaDt=180u"MPa", S=400u"mm^2", E=200u"GPa")
        @test haskey(VV, :epsilon)
        @test VV[:epsilon] !== nothing
        @test isa(VV[:epsilon], Number)
    end

    # Test 11: Zkrácení součásti
    @testset "zkrácení součásti" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", sigmaDt=180u"MPa", E=200u"GPa", L0=500u"mm")
        @test haskey(VV, :deltaL)
        @test haskey(VV, :L)
        @test VV[:deltaL] !== nothing
        @test uconvert(u"mm", VV[:deltaL]) isa Quantity
        @test VV[:L] !== nothing
        @test uconvert(u"mm", VV[:L]) isa Quantity
        @test VV[:L] < VV[:L0]  # zkrácení v tlaku
    end

    # Test 12: Ověření vzorců
    @testset "ověření vzorců" begin
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

    # Test 14: Bezpečnost - hranice bezpečnosti
    @testset "hranice bezpečnosti" begin
        VV, txt = namahanitlak(F=4800u"N", S=400u"mm^2", sigmaDt=80u"MPa")
        @test VV[:bezpecnost] >= 1.0 && VV[:bezpecnost] < 8
    end

    # Test 15: Bezpečnost - nebezpečný spoj
    @testset "nebezpečný spoj" begin
        VV, txt = namahanitlak(F=16000u"N", S=180u"mm^2", sigmaDt=80u"MPa")
        @test VV[:bezpecnost] < 1.0
        @test occursin("není bezpečný", VV[:verdict])
    end

    # Test 16: Vlastní požadavek bezpečnosti
    @testset "vlastní požadavek bezpečnosti" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", Re=240u"MPa", k=3)
        @test haskey(VV, :k)
        @test VV[:k] == 3
        @test isa(VV[:verdict], String)
    end

    # Test 17: Kladná síla
    @testset "kladná síla" begin
        VV, txt = namahanitlak(F=6000u"N", S=400u"mm^2", sigmaDt=240u"MPa")
        @test VV[:F] > 0u"N"
    end

end
