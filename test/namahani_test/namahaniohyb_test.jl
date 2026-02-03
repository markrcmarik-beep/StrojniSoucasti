# ver: 2026-02-03
# Testovací skript pro funkci namahaniohyb.jl
# Testuje namáhání v ohybu s různými typy zatížení

using StrojniSoucasti, Unitful, Test

@testset "namahaniohyb" begin

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
    end

    # Test 6: Statické zatížení (výchozí)
    @testset "statické zatížení" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", zatizeni="statický")
        @test VV[:zatizeni] == "statický"
        @test haskey(VV, :sigmaDo)
        @test isa(txt, String)
    end

    # Test 7: Pulzní zatížení
    @testset "pulzní zatížení" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", zatizeni="pulzní")
        @test VV[:zatizeni] == "pulzní"
        @test haskey(VV, :sigmaDo)
    end

    # Test 8: Dynamické zatížení
    @testset "dynamické zatížení" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", zatizeni="dynamický")
        @test VV[:zatizeni] == "dynamický"
        @test haskey(VV, :sigmaDo)
    end

    # Test 9: Rázové zatížení
    @testset "rázové zatížení" begin
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", zatizeni="rázový")
        @test VV[:zatizeni] == "rázový"
        @test haskey(VV, :sigmaDo)
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
        VV, txt = namahaniohyb(Mo=600u"N*m", Wo=400u"mm^3", Re=240u"MPa", natoceni=45u"°")
        @test haskey(VV, :natoceni)
        @test VV[:natoceni] !== nothing
    end

end
