# ver: 2026-02-03
# Testovací skript pro funkci namahanikrut.jl
# Testuje namáhání v krutu s různými typy zatížení

using StrojniSoucasti, Unitful, Test

@testset "namahanikrut" begin

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
    end

    # Test 5: Statické zatížení (výchozí)
    @testset "statické zatížení" begin
        VV, txt = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa", zatizeni="statický")
        @test VV[:zatizeni] == "statický"
        @test haskey(VV, :tauDk)
        @test isa(txt, String)
    end

    # Test 6: Pulzní zatížení
    @testset "pulzní zatížení" begin
        VV, txt = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa", zatizeni="pulzní")
        @test VV[:zatizeni] == "pulzní"
        @test haskey(VV, :tauDk)
    end

    # Test 7: Dynamické zatížení
    @testset "dynamické zatížení" begin
        VV, txt = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa", zatizeni="dynamický")
        @test VV[:zatizeni] == "dynamický"
        @test haskey(VV, :tauDk)
    end

    # Test 8: Rázové zatížení
    @testset "rázové zatížení" begin
        VV, txt = namahanikrut(Mk=200u"N*m", Wk=400u"mm^3", Re=240u"MPa", zatizeni="rázový")
        @test VV[:zatizeni] == "rázový"
        @test haskey(VV, :tauDk)
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
