# ver: 2026-02-03
# Testovací skript pro funkci namahanikombinovane.jl
# Testuje kombinovaná namáhání dle Huber-Mises-Hencky a Tresca kritérií

using StrojniSoucasti, Unitful, Test

function assert_namahanikombinovane_text_common(txt::String, VV::Dict{Symbol,Any})
    @test !isempty(txt)
    @test occursin("Výpočet $(VV[:info])", txt)
    @test occursin("kritérium:", txt)
    @test occursin("$(VV[:kriterium])", txt)
    @test occursin("zatížení:", txt)
    @test occursin("$(VV[:zatizeni])", txt)
    @test occursin("napětí:", txt)
    @test occursin("$(VV[:namahani])", txt)
    @test occursin("kombinace: $(VV[:namahani])", txt)
    @test occursin("sigma_eq = $(VV[:sigma_eq_str])", txt)
    @test occursin("sigmaD = ", txt)
    @test occursin("k = $(VV[:bezpecnost_str])", txt)
    @test occursin(string(VV[:verdict]), txt)

    if haskey(VV, :sigmat)
        @test occursin("sigmat = ", txt)
    end
    if haskey(VV, :sigmatl)
        @test occursin("sigmatl = ", txt)
    end
    if haskey(VV, :taus)
        @test occursin("taus = ", txt)
    end
    if haskey(VV, :tauk)
        @test occursin("tauk = ", txt)
    end
    if haskey(VV, :sigmao)
        @test occursin("sigmao = ", txt)
    end
end

@testset "namahanikombinovane" begin

    # Příprava vstupních dat
    prof1 = "KR 25"
    mat1 = "16440"
    VVtah1, _ = namahanitah(F=20u"kN", profil=prof1, mat=mat1)
    VVtlak1, _ = namahanitlak(F=20u"kN", profil=prof1, mat=mat1)
    VVstrih1, _ = namahanistrih(F=10u"kN", profil=prof1, mat=mat1)
    VVkrut1, _ = namahanikrut(Mk=400u"N*m", profil=prof1, mat=mat1)
    VVohyb1, _ = namahaniohyb(Mo=400u"N*m", profil=prof1, mat=mat1)

    expected_txtkomb1 = """Výpočet namáhání v tahu - střihu
----------------------------------------------------------------
Výpočet namáhání v tahu
--------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
--------------------------------------------------------------
zadání:
F = 20 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
sigmaDt = 307.692 MPa   Dovolené napětí
Re = 400 MPa   Mez kluzu
E = 210 GPa   Youngův modul
--------------------------------------------------------------
výpočet:
sigma = F / S = 40.7437 MPa   Skutečné napětí v tahu
epsilon = sigma / E = 19.4017 %   Poměrné prodloužení
k = sigmaDt / sigma = 7.55191   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
--------------------------------------------------------------
zadání:
F = 10 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
Re = 400 MPa   Mez kluzu
G = 81 GPa   Modul pružnosti ve smyku
tauDs = 153.96 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 20.3718 MPa   Napětí ve střihu
gamma = tau / G = 0.251504   Deformace ve smyku
k = tauDs / tau = 7.5575   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
kritérium: Huber-Mises-Hencky
zatížení:  statický-statický
----------------------------------------------------------------
napětí:  tah-střih
sigmat = 40.7437 MPa   Výsledné normálové napětí tahu
taus = 20.3718 MPa   Výsledné napětí ve střihu
----------------------------------------------------------------
kombinace: tah-střih
sigma_eq = sqrt(sigmat^2 + 3*taus^2) = 53.8988 MPa   Ekvivalentní napětí
sigmaD = 232.558 MPa   Dovolené napětí
----------------------------------------------------------------
k = sigmaD / sigma_eq = 4.31472   Součinitel bezpečnosti
Závěr posouzení: Součást je bezpečná"""

    expected_txtkomb2 = """Výpočet namáháni v tlaku - střihu
----------------------------------------------------------------
Výpočet namáhání v tlaku
----------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
F = 20 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
sigmaDt = 307.692 MPa   Dovolené napětí v tlaku
Re = 400 MPa   Mez kluzu
E = 210 GPa   Youngův modul (tlak)
----------------------------------------------------------------
výpočet:
sigma = F / S = 40.7437 MPa   Napětí v tlaku
epsilon = sigma / E = 19.4017 %   Poměrné zkrácení
k = sigmaDt / sigma = 7.55191   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
--------------------------------------------------------------
zadání:
F = 10 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
Re = 400 MPa   Mez kluzu
G = 81 GPa   Modul pružnosti ve smyku
tauDs = 153.96 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 20.3718 MPa   Napětí ve střihu
gamma = tau / G = 0.251504   Deformace ve smyku
k = tauDs / tau = 7.5575   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
kritérium: Huber-Mises-Hencky
zatížení:  statický-statický
----------------------------------------------------------------
napětí:  tlak-střih
sigmatl = 40.7437 MPa   Výsledné normálové napětí v tlaku
taus = 20.3718 MPa   Výsledné napětí ve střihu
----------------------------------------------------------------
kombinace: tlak-střih
sigma_eq = sqrt(sigmatl^2 + 3*taus^2) = 53.8988 MPa   Ekvivalentní napětí
sigmaD = 232.558 MPa   Dovolené napětí
----------------------------------------------------------------
k = sigmaD / sigma_eq = 4.31472   Součinitel bezpečnosti
Závěr posouzení: Součást je bezpečná"""

    expected_txtkomb3 = """Výpočet namáhání v tahu - krutu
----------------------------------------------------------------
Výpočet namáhání v tahu
--------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
--------------------------------------------------------------
zadání:
F = 20 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
sigmaDt = 307.692 MPa   Dovolené napětí
Re = 400 MPa   Mez kluzu
E = 210 GPa   Youngův modul
--------------------------------------------------------------
výpočet:
sigma = F / S = 40.7437 MPa   Skutečné napětí v tahu
epsilon = sigma / E = 19.4017 %   Poměrné prodloužení
k = sigmaDt / sigma = 7.55191   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 400 m N   Krouticí moment
Wk = π/16*D³ = 3067.96 mm^3   Průřezový modul v krutu
Ip = π/32*D⁴ = 38349.5 mm^4   Polární moment setrvačnosti
tauDk = 153.96 MPa   Dovolené napětí v krutu
G = 81 GPa   Smykový modul
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 130.38 MPa   Napětí v krutu
theta = Mk / (G * Ip) = 0.12877 rad m^-1   Poměrné zkroucení
theta = 7.37798 ° m^-1   Poměrné zkroucení
k = tauDk / tau = 1.18086   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je na hranici bezpečnosti
----------------------------------------------------------------
kritérium: Huber-Mises-Hencky
zatížení:  statický-statický
----------------------------------------------------------------
napětí:  tah-krut
sigmat = 40.7437 MPa   Výsledné normálové napětí tahu
tauk = 130.38 MPa   Výsledné napětí v krutu
----------------------------------------------------------------
kombinace: tah-krut
sigma_eq = sqrt(sigmat^2 + 3*tauk^2) = 229.47 MPa   Ekvivalentní napětí
sigmaD = 205.128 MPa   Dovolené napětí
----------------------------------------------------------------
k = sigmaD / sigma_eq = 0.89392   Součinitel bezpečnosti
Závěr posouzení: Součást není bezpečná!"""

    expected_txtkomb4 = """Výpočet namáhání v tlaku - krutu
----------------------------------------------------------------
Výpočet namáhání v tlaku
----------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
F = 20 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
sigmaDt = 307.692 MPa   Dovolené napětí v tlaku
Re = 400 MPa   Mez kluzu
E = 210 GPa   Youngův modul (tlak)
----------------------------------------------------------------
výpočet:
sigma = F / S = 40.7437 MPa   Napětí v tlaku
epsilon = sigma / E = 19.4017 %   Poměrné zkrácení
k = sigmaDt / sigma = 7.55191   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 400 m N   Krouticí moment
Wk = π/16*D³ = 3067.96 mm^3   Průřezový modul v krutu
Ip = π/32*D⁴ = 38349.5 mm^4   Polární moment setrvačnosti
tauDk = 153.96 MPa   Dovolené napětí v krutu
G = 81 GPa   Smykový modul
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 130.38 MPa   Napětí v krutu
theta = Mk / (G * Ip) = 0.12877 rad m^-1   Poměrné zkroucení
theta = 7.37798 ° m^-1   Poměrné zkroucení
k = tauDk / tau = 1.18086   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je na hranici bezpečnosti
----------------------------------------------------------------
kritérium: Huber-Mises-Hencky
zatížení:  statický-statický
----------------------------------------------------------------
napětí:  tlak-krut
sigmatl = 40.7437 MPa   Výsledné normálové napětí v tlaku
tauk = 130.38 MPa   Výsledné napětí v krutu
----------------------------------------------------------------
kombinace: tlak-krut
sigma_eq = sqrt(sigmatl^2 + 3*tauk^2) = 229.47 MPa   Ekvivalentní napětí
sigmaD = 205.128 MPa   Dovolené napětí
----------------------------------------------------------------
k = sigmaD / sigma_eq = 0.89392   Součinitel bezpečnosti
Závěr posouzení: Součást není bezpečná!"""

    expected_txtkomb5 = """Výpočet namáhání v tahu - ohybu
----------------------------------------------------------------
Výpočet namáhání v tahu
--------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
--------------------------------------------------------------
zadání:
F = 20 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
sigmaDt = 307.692 MPa   Dovolené napětí
Re = 400 MPa   Mez kluzu
E = 210 GPa   Youngův modul
--------------------------------------------------------------
výpočet:
sigma = F / S = 40.7437 MPa   Skutečné napětí v tahu
epsilon = sigma / E = 19.4017 %   Poměrné prodloužení
k = sigmaDt / sigma = 7.55191   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
Mo = 400 m N   Ohybový moment
natočení = 0 rad   Natočení profilu
Wo = π/32*D³ = 1533.98 mm^3   Průřezový modul v ohybu
Ix = pi/64*D^4 = 19174.8 mm^4   Moment setrvačnosti
Re = 400 MPa   Mez kluzu
E = 210 GPa   Modul pružnosti
sigmaDo = 266.667 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 260.759 MPa   Napětí v ohybu
delta = Mo / (E * Ix) = 0.0993369 m^-1   Relativní průhyb
k = sigmaDo / sigma = 1.02265   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást je na hranici bezpečnosti
----------------------------------------------------------------
kritérium: Huber-Mises-Hencky
zatížení:  statický-statický
----------------------------------------------------------------
napětí:  tah-ohyb
sigmat = 40.7437 MPa   Výsledné normálové napětí tahu
sigmao = 260.759 MPa   Výsledné napětí v ohybu
----------------------------------------------------------------
kombinace: tah-ohyb
sigma_eq = sqrt(sigmat^2 - sigmat*sigmao + sigmao^2) = 242.963 MPa   Ekvivalentní napětí
sigmaD = 232.558 MPa   Dovolené napětí
----------------------------------------------------------------
k = sigmaD / sigma_eq = 0.957173   Součinitel bezpečnosti
Závěr posouzení: Součást není bezpečná!"""

    expected_txtkomb6 = """Výpočet namáhání v tlaku - ohybu
----------------------------------------------------------------
Výpočet namáhání v tlaku
----------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
F = 20 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
sigmaDt = 307.692 MPa   Dovolené napětí v tlaku
Re = 400 MPa   Mez kluzu
E = 210 GPa   Youngův modul (tlak)
----------------------------------------------------------------
výpočet:
sigma = F / S = 40.7437 MPa   Napětí v tlaku
epsilon = sigma / E = 19.4017 %   Poměrné zkrácení
k = sigmaDt / sigma = 7.55191   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
Mo = 400 m N   Ohybový moment
natočení = 0 rad   Natočení profilu
Wo = π/32*D³ = 1533.98 mm^3   Průřezový modul v ohybu
Ix = pi/64*D^4 = 19174.8 mm^4   Moment setrvačnosti
Re = 400 MPa   Mez kluzu
E = 210 GPa   Modul pružnosti
sigmaDo = 266.667 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 260.759 MPa   Napětí v ohybu
delta = Mo / (E * Ix) = 0.0993369 m^-1   Relativní průhyb
k = sigmaDo / sigma = 1.02265   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást je na hranici bezpečnosti
----------------------------------------------------------------
kritérium: Huber-Mises-Hencky
zatížení:  statický-statický
----------------------------------------------------------------
napětí:  tlak-ohyb
sigmatl = 40.7437 MPa   Výsledné normálové napětí v tlaku
sigmao = 260.759 MPa   Výsledné napětí v ohybu
----------------------------------------------------------------
kombinace: tlak-ohyb
sigma_eq = sqrt(sigmatl^2 - sigmatl*sigmao + sigmao^2) = 242.963 MPa   Ekvivalentní napětí
sigmaD = 232.558 MPa   Dovolené napětí
----------------------------------------------------------------
k = sigmaD / sigma_eq = 0.957173   Součinitel bezpečnosti
Závěr posouzení: Součást není bezpečná!"""

    expected_txtkomb7 = """Výpočet namáhání v střihu - krutu
----------------------------------------------------------------
Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
--------------------------------------------------------------
zadání:
F = 10 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
Re = 400 MPa   Mez kluzu
G = 81 GPa   Modul pružnosti ve smyku
tauDs = 153.96 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 20.3718 MPa   Napětí ve střihu
gamma = tau / G = 0.251504   Deformace ve smyku
k = tauDs / tau = 7.5575   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 400 m N   Krouticí moment
Wk = π/16*D³ = 3067.96 mm^3   Průřezový modul v krutu
Ip = π/32*D⁴ = 38349.5 mm^4   Polární moment setrvačnosti
tauDk = 153.96 MPa   Dovolené napětí v krutu
G = 81 GPa   Smykový modul
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 130.38 MPa   Napětí v krutu
theta = Mk / (G * Ip) = 0.12877 rad m^-1   Poměrné zkroucení
theta = 7.37798 ° m^-1   Poměrné zkroucení
k = tauDk / tau = 1.18086   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je na hranici bezpečnosti
----------------------------------------------------------------
kritérium: Huber-Mises-Hencky
zatížení:  statický-statický
----------------------------------------------------------------
napětí:  střih-krut
taus = 20.3718 MPa   Výsledné napětí ve střihu
tauk = 130.38 MPa   Výsledné napětí v krutu
----------------------------------------------------------------
kombinace: střih-krut
sigma_eq = sqrt(3) * sqrt(taus^2 + tauk^2) = 228.564 MPa   Ekvivalentní napětí
sigmaD = 118.431 MPa   Dovolené napětí
----------------------------------------------------------------
k = sigmaD / sigma_eq = 0.518151   Součinitel bezpečnosti
Závěr posouzení: Součást není bezpečná!"""

    expected_txtkomb8 = """Výpočet namáhání ve střihu - ohybu
----------------------------------------------------------------
Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
--------------------------------------------------------------
zadání:
F = 10 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
Re = 400 MPa   Mez kluzu
G = 81 GPa   Modul pružnosti ve smyku
tauDs = 153.96 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 20.3718 MPa   Napětí ve střihu
gamma = tau / G = 0.251504   Deformace ve smyku
k = tauDs / tau = 7.5575   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
Mo = 400 m N   Ohybový moment
natočení = 0 rad   Natočení profilu
Wo = π/32*D³ = 1533.98 mm^3   Průřezový modul v ohybu
Ix = pi/64*D^4 = 19174.8 mm^4   Moment setrvačnosti
Re = 400 MPa   Mez kluzu
E = 210 GPa   Modul pružnosti
sigmaDo = 266.667 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 260.759 MPa   Napětí v ohybu
delta = Mo / (E * Ix) = 0.0993369 m^-1   Relativní průhyb
k = sigmaDo / sigma = 1.02265   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást je na hranici bezpečnosti
----------------------------------------------------------------
kritérium: Huber-Mises-Hencky
zatížení:  statický-statický
----------------------------------------------------------------
napětí:  střih-ohyb
taus = 20.3718 MPa   Výsledné napětí ve střihu
sigmao = 260.759 MPa   Výsledné napětí v ohybu
----------------------------------------------------------------
kombinace: střih-ohyb
sigma_eq = sqrt(sigmao^2 + 3*taus^2) = 263.136 MPa   Ekvivalentní napětí
sigmaD = 134.268 MPa   Dovolené napětí
----------------------------------------------------------------
k = sigmaD / sigma_eq = 0.510259   Součinitel bezpečnosti
Závěr posouzení: Součást není bezpečná!"""

    expected_txtkomb9 = """Výpočet namáhání v krutu - ohybu
----------------------------------------------------------------
Výpočet namáhání v krutu
----------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
Mk = 400 m N   Krouticí moment
Wk = π/16*D³ = 3067.96 mm^3   Průřezový modul v krutu
Ip = π/32*D⁴ = 38349.5 mm^4   Polární moment setrvačnosti
tauDk = 153.96 MPa   Dovolené napětí v krutu
G = 81 GPa   Smykový modul
-----------------------------------------------------------------
výpočet:
tau = Mk / Wk = 130.38 MPa   Napětí v krutu
theta = Mk / (G * Ip) = 0.12877 rad m^-1   Poměrné zkroucení
theta = 7.37798 ° m^-1   Poměrné zkroucení
k = tauDk / tau = 1.18086   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je na hranici bezpečnosti
----------------------------------------------------------------
Výpočet namáhání v ohybu
----------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
----------------------------------------------------------------
zadání:
Mo = 400 m N   Ohybový moment
natočení = 0 rad   Natočení profilu
Wo = π/32*D³ = 1533.98 mm^3   Průřezový modul v ohybu
Ix = pi/64*D^4 = 19174.8 mm^4   Moment setrvačnosti
Re = 400 MPa   Mez kluzu
E = 210 GPa   Modul pružnosti
sigmaDo = 266.667 MPa   Dovolené napětí v ohybu
----------------------------------------------------------------
výpočet:
sigma = Mo / Wo = 260.759 MPa   Napětí v ohybu
delta = Mo / (E * Ix) = 0.0993369 m^-1   Relativní průhyb
k = sigmaDo / sigma = 1.02265   Součinitel bezpečnosti
Závěr posouzení bezpečnosti: Součást je na hranici bezpečnosti
----------------------------------------------------------------
kritérium: Huber-Mises-Hencky
zatížení:  statický-statický
k = 5   Uživatelský požadavek bezpečnosti kombinovaného namáhání
----------------------------------------------------------------
napětí:  krut-ohyb
tauk = 130.38 MPa   Výsledné napětí v krutu
sigmao = 260.759 MPa   Výsledné napětí v ohybu
----------------------------------------------------------------
kombinace: krut-ohyb
sigma_eq = sqrt(sigmao^2 + 3*tauk^2) = 344.952 MPa   Ekvivalentní napětí
sigmaD = 205.128 MPa   Dovolené napětí
----------------------------------------------------------------
k = sigmaD / sigma_eq = 0.594657   Součinitel bezpečnosti
Závěr posouzení: Spoj není bezpečný!"""

    expected_txtkomb10 = """Výpočet namáhání v tahu - střihu
----------------------------------------------------------------
Výpočet namáhání v tahu
--------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
--------------------------------------------------------------
zadání:
F = 20 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
sigmaDt = 307.692 MPa   Dovolené napětí
Re = 400 MPa   Mez kluzu
E = 210 GPa   Youngův modul
--------------------------------------------------------------
výpočet:
sigma = F / S = 40.7437 MPa   Skutečné napětí v tahu
epsilon = sigma / E = 19.4017 %   Poměrné prodloužení
k = sigmaDt / sigma = 7.55191   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
Výpočet namáhání ve střihu
--------------------------------------------------------------
materiál: 16 440
profil: KR 25
  D = 25.0 mm
zatížení: statický
--------------------------------------------------------------
zadání:
F = 10 kN   Zatěžující síla
S = π*(D/2)² = 490.874 mm^2   Plocha průřezu
Re = 400 MPa   Mez kluzu
G = 81 GPa   Modul pružnosti ve smyku
tauDs = 153.96 MPa   Dovolené napětí ve střihu
--------------------------------------------------------------
výpočet:
tau = F / S = 20.3718 MPa   Napětí ve střihu
gamma = tau / G = 0.251504   Deformace ve smyku
k = tauDs / tau = 7.5575   Součinitel bezpečnosti
Bezpečnost spoje: Spoj je bezpečný
----------------------------------------------------------------
kritérium: Tresca
zatížení:  statický-statický
----------------------------------------------------------------
napětí:  tah-střih
sigmat = 40.7437 MPa   Výsledné normálové napětí tahu
taus = 20.3718 MPa   Výsledné napětí ve střihu
----------------------------------------------------------------
kombinace: tah-střih
sigma_eq = sqrt(sigmat^2 + 4*taus^2) = 57.6202 MPa   Ekvivalentní napětí
sigmaD = 232.558 MPa   Dovolené napětí
----------------------------------------------------------------
k = sigmaD / sigma_eq = 4.03605   Součinitel bezpečnosti
Závěr posouzení: Součást je bezpečná"""

    # Test 1: tah-střih kombinace
    @testset "tah-střih kombinace" begin
        VVkomb1, txtkomb1 = namahanikombinovane(vysledky = [VVtah1, VVstrih1])
        @test haskey(VVkomb1, :sigma_eq)
        @test haskey(VVkomb1, :sigmaD)
        @test haskey(VVkomb1, :bezpecnost)
        @test haskey(VVkomb1, :info)
        @test haskey(VVkomb1, :namahani)
        @test VVkomb1[:namahani] == "tah-střih"
        @test VVkomb1[:kriterium] == "Huber-Mises-Hencky" # výchozí kritérium
        @test VVkomb1[:sigma_eq] > 0u"MPa"
        @test VVkomb1[:sigmaD] > 0u"MPa"
        @test VVkomb1[:bezpecnost] > 0
        @test isa(txtkomb1, String)
        @test !isempty(txtkomb1)
        assert_namahanikombinovane_text_common(txtkomb1, VVkomb1)
        @test txtkomb1 == expected_txtkomb1
    end

    # Test 2: tlak-střih kombinace
    @testset "tlak-střih kombinace" begin
        VVkomb2, txtkomb2 = namahanikombinovane(vysledky = [VVtlak1, VVstrih1])
        @test haskey(VVkomb2, :sigma_eq)
        @test VVkomb2[:namahani] == "tlak-střih"
        @test VVkomb2[:sigma_eq] > 0u"MPa"
        @test isa(txtkomb2, String)
        assert_namahanikombinovane_text_common(txtkomb2, VVkomb2)
        @test txtkomb2 == expected_txtkomb2
    end

    # Test 3: tah-krut kombinace
    @testset "tah-krut kombinace" begin
        VVkomb3, txtkomb3 = namahanikombinovane(vysledky = [VVtah1, VVkrut1])
        @test haskey(VVkomb3, :sigma_eq)
        @test VVkomb3[:namahani] == "tah-krut"
        @test VVkomb3[:sigma_eq] > 0u"MPa"
        @test isa(txtkomb3, String)
        assert_namahanikombinovane_text_common(txtkomb3, VVkomb3)
        @test txtkomb3 == expected_txtkomb3
    end

    # Test 4: tlak-krut kombinace
    @testset "tlak-krut kombinace" begin
        VVkomb4, txtkomb4 = namahanikombinovane(vysledky = [VVtlak1, VVkrut1])
        @test haskey(VVkomb4, :sigma_eq)
        @test VVkomb4[:namahani] == "tlak-krut"
        @test VVkomb4[:sigma_eq] > 0u"MPa"
        assert_namahanikombinovane_text_common(txtkomb4, VVkomb4)
        @test txtkomb4 == expected_txtkomb4
    end

    # Test 5: tah-ohyb kombinace
    @testset "tah-ohyb kombinace" begin
        VVkomb5, txtkomb5 = namahanikombinovane(vysledky = [VVtah1, VVohyb1])
        @test haskey(VVkomb5, :sigma_eq)
        @test VVkomb5[:namahani] == "tah-ohyb"
        @test VVkomb5[:sigma_eq] > 0u"MPa"
        assert_namahanikombinovane_text_common(txtkomb5, VVkomb5)
        @test txtkomb5 == expected_txtkomb5
    end

    # Test 6: tlak-ohyb kombinace
    @testset "tlak-ohyb kombinace" begin
        VVkomb6, txtkomb6 = namahanikombinovane(vysledky = [VVtlak1, VVohyb1])
        @test haskey(VVkomb6, :sigma_eq)
        @test VVkomb6[:namahani] == "tlak-ohyb"
        @test VVkomb6[:sigma_eq] > 0u"MPa"
        assert_namahanikombinovane_text_common(txtkomb6, VVkomb6)
        @test txtkomb6 == expected_txtkomb6
    end

    # Test 7: střih-krut kombinace
    @testset "střih-krut kombinace" begin
        VVkomb7, txtkomb7 = namahanikombinovane(vysledky = [VVstrih1, VVkrut1])
        @test haskey(VVkomb7, :sigma_eq)
        @test VVkomb7[:namahani] == "střih-krut"
        @test VVkomb7[:sigma_eq] > 0u"MPa"
        assert_namahanikombinovane_text_common(txtkomb7, VVkomb7)
        @test txtkomb7 == expected_txtkomb7
    end

    # Test 8: střih-ohyb kombinace
    @testset "střih-ohyb kombinace" begin
        VVkomb8, txtkomb8 = namahanikombinovane(vysledky = [VVstrih1, VVohyb1])
        @test haskey(VVkomb8, :sigma_eq)
        @test VVkomb8[:namahani] == "střih-ohyb"
        @test VVkomb8[:sigma_eq] > 0u"MPa"
        assert_namahanikombinovane_text_common(txtkomb8, VVkomb8)
        @test txtkomb8 == expected_txtkomb8
    end

    # Test 9: krut-ohyb kombinace
    @testset "krut-ohyb kombinace" begin
        VVkomb9, txtkomb9 = namahanikombinovane(vysledky = [VVkrut1, VVohyb1], k=5)
        @test haskey(VVkomb9, :sigma_eq)
        @test VVkomb9[:namahani] == "krut-ohyb"
        @test VVkomb9[:sigma_eq] > 0u"MPa"
        @test haskey(VVkomb9, :k)
        @test VVkomb9[:k] == 5
        assert_namahanikombinovane_text_common(txtkomb9, VVkomb9)
        @test txtkomb9 == expected_txtkomb9
    end

    # Test 10: Tresca kritérium
    @testset "Tresca kritérium" begin
        VVkomb10, txtkomb10 = namahanikombinovane(vysledky = [VVtah1, VVstrih1], kriterium = :Tresca)
        @test VVkomb10[:kriterium] == "Tresca"
        @test haskey(VVkomb10, :sigma_eq)
        @test VVkomb10[:sigma_eq] > 0u"MPa"
        assert_namahanikombinovane_text_common(txtkomb10, VVkomb10)
        @test txtkomb10 == expected_txtkomb10
    end

    # Test 11: Výstup bez textu
    @testset "výstup bez textu" begin
        VVkomb11 = namahanikombinovane(vysledky = [VVtah1, VVstrih1], return_text = false)
        @test isa(VVkomb11, Dict)
        @test haskey(VVkomb11, :sigma_eq)
        @test haskey(VVkomb11, :bezpecnost)
    end

    # Test 12: Vlastní dovolené napětí
    @testset "vlastní dovolené napětí" begin
        VVkomb12, _ = namahanikombinovane(vysledky = [VVtah1, VVstrih1], sigmaD = 100u"MPa")
        @test VVkomb12[:sigmaD] == 100u"MPa"
        @test VVkomb12[:sigma_eq] > 0u"MPa"
    end

    # Test 13: Inverzní pořadí vstupů
    @testset "inverzní pořadí vstupů" begin
        VVkomb_norm, txtkomb_norm = namahanikombinovane(vysledky = [VVtah1, VVstrih1])
        VVkomb_inv, txtkomb_inv = namahanikombinovane(vysledky = [VVstrih1, VVtah1])
        @test VVkomb_norm[:sigma_eq] == VVkomb_inv[:sigma_eq]
        @test VVkomb_norm[:bezpecnost] == VVkomb_inv[:bezpecnost]
        @test txtkomb_norm == txtkomb_inv
        assert_namahanikombinovane_text_common(txtkomb_norm, VVkomb_norm)
        assert_namahanikombinovane_text_common(txtkomb_inv, VVkomb_inv)
        @test txtkomb_norm == expected_txtkomb1
    end

end
