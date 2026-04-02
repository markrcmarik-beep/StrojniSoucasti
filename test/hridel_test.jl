# ver: 2026-03-28
# Test script for hridel.jl

using StrojniSoucasti, Unitful, Test

@testset "hridel" begin
    @testset "basic hollow shaft" begin
        VV, txt = StrojniSoucasti.hridel(Mk=200, D=40, d=20, 
            tauDk=120, return_text=true)
        @test isa(VV, Dict)
        @test haskey(VV, :tau)
        @test haskey(VV, :Wk)
        @test haskey(VV, :Ip)
        @test haskey(VV, :D)
        @test haskey(VV, :d)
        @test VV[:D] == 40u"mm"
        @test VV[:d] == 20u"mm"
        @test uconvert(u"N*m", VV[:Mk]) == 200u"N*m"
        @test VV[:tau] > 0u"MPa"
        @test VV[:bezpecnost] > 0
        @test isa(txt, String)
        @test !isempty(txt)
        expected_txt = """
Výpočet: hybný hřídel dutý
----------------------------------------------------------------
materiál: 
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 200 m N   Krouticí moment
D = 40 mm   Vnější průměr hřídele
d = 20 mm   Vnitřní průměr hřídele
Wk = π/16*(D⁴ - d⁴)/D = 11781 mm^3   Průřezový modul v krutu
Ip = π/32*(D⁴ - d⁴) = 235619 mm^4   Polární moment setrvačnosti
tauDk = 120 MPa   Dovolené napětí v krutu
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 16.9765 MPa   Napětí v krutu
k = tauDk / tau = 7.06858   Součinitel bezpečnosti
Bezpečnost součásti: Hřídel je bezpečný"""
        @test txt == expected_txt
    end

    @testset "solid shaft" begin
        VV = StrojniSoucasti.hridel(Mk=150u"N*m", D=30u"mm", 
            tauDk=100u"MPa", return_text=false)
        @test VV[:d] === nothing
        @test VV[:D] == 30u"mm"
        @test VV[:tau] > 0u"MPa"
    end

    @testset "solid shaft text" begin
        VV, txt = StrojniSoucasti.hridel(Mk=200, D=40, tauDk=120, 
            return_text=true)
        @test isa(VV, Dict)
        @test haskey(VV, :tau)
        @test haskey(VV, :Wk)
        @test haskey(VV, :Ip)
        @test haskey(VV, :D)
        @test VV[:D] == 40u"mm"
        @test uconvert(u"N*m", VV[:Mk]) == 200u"N*m"
        @test VV[:tau] > 0u"MPa"
        @test VV[:bezpecnost] > 0
        @test isa(txt, String)
        @test !isempty(txt)
        expected_txt = """
Výpočet: hybný hřídel
----------------------------------------------------------------
materiál: 
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 200 m N   Krouticí moment
D = 40 mm   Vnější průměr hřídele
Wk = π/16*D³ = 12566.4 mm^3   Průřezový modul v krutu
Ip = π/32*D⁴ = 251327 mm^4   Polární moment setrvačnosti
tauDk = 120 MPa   Dovolené napětí v krutu
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 15.9155 MPa   Napětí v krutu
k = tauDk / tau = 7.53982   Součinitel bezpečnosti
Bezpečnost součásti: Hřídel je bezpečný"""
        @test txt == expected_txt
    end

    @testset "angle of twist" begin
        VV, txt = StrojniSoucasti.hridel(Mk=150u"N*m", D=50u"mm", d=30u"mm",
            tauDk=100u"MPa", G=80u"GPa", L=100u"mm", return_text=true)
        @test VV[:phi] !== nothing
        @test VV[:theta] !== nothing
        @test uconvert(u"rad", VV[:phi]) isa Quantity
        @test uconvert(u"rad/m", VV[:theta]) isa Quantity
        @test isa(txt, String)
        @test !isempty(txt)
        expected_txt = """
Výpočet: hybný hřídel dutý
----------------------------------------------------------------
materiál: 
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 150 m N   Krouticí moment
D = 50 mm   Vnější průměr hřídele
d = 30 mm   Vnitřní průměr hřídele
L = 100 mm   Délka hřídele
Wk = π/16*(D⁴ - d⁴)/D = 21362.8 mm^3   Průřezový modul v krutu
Ip = π/32*(D⁴ - d⁴) = 534071 mm^4   Polární moment setrvačnosti
tauDk = 100 MPa   Dovolené napětí v krutu
G = 80 GPa   Smykový modul
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 7.02154 MPa   Napětí v krutu
phi = (Mk * L0) / (G * Ip) = 0.000351077 rad   Úhel zkroucení
phi = 0.0201152°   Úhel zkroucení
theta = Mk / (G * Ip) = 0.00351077 rad m^-1   Poměrné zkroucení
theta = 0.201152 ° m^-1   Poměrné zkroucení
k = tauDk / tau = 14.2419   Součinitel bezpečnosti
Bezpečnost součásti: Hřídel je bezpečný"""
        @test txt == expected_txt
    end

    @testset "material input" begin
        VV, txt = StrojniSoucasti.hridel(Mk=120u"N*m", D=45u"mm", 
            d=25u"mm", mat="11373", return_text=true)
        @test VV[:mat] == "11373"
        @test VV[:Re] > 0u"MPa"
        @test VV[:G] > 0u"GPa"
        @test VV[:tauDk] > 0u"MPa"
        @test isa(txt, String)
        @test !isempty(txt)
        expected_txt = """
Výpočet: hybný hřídel dutý
----------------------------------------------------------------
materiál: 11373
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 120 m N   Krouticí moment
D = 45 mm   Vnější průměr hřídele
d = 25 mm   Vnitřní průměr hřídele
Wk = π/16*(D⁴ - d⁴)/D = 16187.9 mm^3   Průřezový modul v krutu
Ip = π/32*(D⁴ - d⁴) = 364228 mm^4   Polární moment setrvačnosti
tauDk = 84.9045 MPa   Dovolené napětí v krutu
G = 81 GPa   Smykový modul
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 7.41293 MPa   Napětí v krutu
theta = Mk / (G * Ip) = 0.00406745 rad m^-1   Poměrné zkroucení
theta = 0.233048 ° m^-1   Poměrné zkroucení
k = tauDk / tau = 11.4536   Součinitel bezpečnosti
Bezpečnost součásti: Hřídel je bezpečný"""
        @test txt == expected_txt
    end

    @testset "input validation" begin
        @test_throws ErrorException StrojniSoucasti.hridel(D=40, d=20, tauDk=120, return_text=false) # missing Mk
        @test_throws ErrorException StrojniSoucasti.hridel(Mk=10, d=20, tauDk=120, return_text=false) # missing D
        @test_throws ErrorException StrojniSoucasti.hridel(Mk=-10, D=40, d=20, tauDk=120, return_text=false) # negative Mk
        @test_throws ErrorException StrojniSoucasti.hridel(Mk=10, D=40, d=20, return_text=false) # missing tauDk
    end
end
