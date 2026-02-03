# ver: 2026-02-03
# Testovací skript pro funkci namahanistrih.jl
# Testuje namáhání ve střihu s různými typy zatížení

using StrojniSoucasti, Unitful, Test

@testset "namahanistrih" begin

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
    end

    # Test 6: Statické zatížení (výchozí)
    @testset "statické zatížení" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="statický")
        @test VV[:zatizeni] == "statický"
        @test haskey(VV, :tauDs)
        @test isa(txt, String)
    end

    # Test 7: Pulzní zatížení
    @testset "pulzní zatížení" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="pulzní")
        @test VV[:zatizeni] == "pulzní"
        @test haskey(VV, :tauDs)
    end

    # Test 8: Dynamické zatížení
    @testset "dynamické zatížení" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="dynamický")
        @test VV[:zatizeni] == "dynamický"
        @test haskey(VV, :tauDs)
    end

    # Test 9: Rázové zatížení
    @testset "rázové zatížení" begin
        VV, txt = namahanistrih(F=6000u"N", S=400u"mm^2", Re=240u"MPa", zatizeni="rázový")
        @test VV[:zatizeni] == "rázový"
        @test haskey(VV, :tauDs)
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
