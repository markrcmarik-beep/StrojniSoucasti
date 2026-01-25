## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí hodnotu meze únavy materiálu. Hodnota je určena na základě
# meze kluzu, meze pevnosti, druhu namáhání a způsobu zatížení.
# ver: 2025-11-13
## Funkce: mezUnavy()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/mezUnavy.jl
#
## Vzor:
## B = mezUnavy(Re, Rm, N::AbstractString, Z::AbstractString)
## Vstupní proměnné:
# Re - mez kluzu materiálu s jednotkou (např. 250u"MPa")
# Rm - mez pevnosti materiálu s jednotkou (např. 450u"MPa")
# N - druh namáhání jako řetězec: "tah", "tlak", "střih", "ohyb", "krut"
# Z - způsob zatížení jako řetězec: "statický", "pulzní", "dynamický", "rázový"
## Výstupní proměnné:
# B - dovolené napětí materiálu s jednotkou (MPa)
## Použité balíčky
# Unitful
## Použité uživatelské funkce:
# 
## Příklad:
# mazUnavy(250u"MPa", "tah", "statický")
#   vrátí mez únavy pro materiál s mezí kluzu 250 MPa při statickém tahu
#   => 100.0 MPa
# mazUnavy(450u"MPa", "ohyb", "dynamický")
#   vrátí mez únavy pro materiál s mezí pevnosti 450 MPa při dynamickém ohybu
#   => 108.0 MPa
###############################################################
## Použité proměnné vnitřní:
#
using Unitful, Unitful.DefaultSymbols

"""
    mezUnavy(Re, Rm, N::AbstractString, Z::AbstractString; tisk::Bool=false)


    mezUnavy(Re, Rm, N::AbstractString, Z::AbstractString; tisk::Bool=false)

Vrátí **mez únavy** (sigmae, taue …) podle meze kluzu `Re`, meze pevnosti `Rm`,
typu namáhání `N` a způsobu zatížení `Z`.

# Parametry
- `Re` - mez kluzu (např. `250u"MPa"`).
- `Rm` - mez pevnosti (např. `450u"MPa"`).
- `N`  - druh namáhání: `"tah"`, `"tlak"`, `"střih"`, `"ohyb"`, `"krut"`.
- `Z`  - typ zatížení: `"statický"`, `"pulzní"`, `"dynamický"`, `"rázový"`.
- `tisk` - volitelný výpis výsledků.

# Návratová hodnota
Slovník `Dict{String, Quantity}` s jednotkami `[MPa]`.
"""
function mezUnavy(Re, Rm, N::AbstractString, Z::AbstractString; tisk::Bool=false)
    # --- Ověření jednotek ---
    for (name, val) in [("Re", Re), ("Rm", Rm)]
        if !(val isa Unitful.Quantity)
            error("$name musí mít jednotku, např. 250u\"MPa\".")
        end
    end

    # --- Normalizace vstupů ---
    Nn = lowercase(replace(N, " " => ""))
    Zn = lowercase(replace(Z, " " => ""))

    povoleneN = ["tah", "tlak", "střih", "ohyb", "krut"]
    povoleneZ = ["statický", "pulzní", "dynamický", "rázový"]
    if !(Nn in povoleneN)
        error("Neznámý druh namáhání: $N. Povolené: $(join(povoleneN, ", ")).")
    end
    if !(Zn in povoleneZ)
        error("Neznámý způsob zatížení: $Z. Povolené: $(join(povoleneZ, ", ")).")
    end

    # --- Základní koeficient únavy podle typu zatížení ---
    # (nižší hodnota = větší namáhání = menší mez únavy)
    kZ = if Zn == "statický"
        1.0
    elseif Zn == "pulzní"
        0.8
    elseif Zn == "dynamický"
        0.6
    elseif Zn == "rázový"
        0.4
    else
        1.0
    end

    # --- Určení mezí únavy podle dostupných hodnot ---
    # pokud není zadáno Re nebo Rm, použij druhé dostupné
    Re_eff = isnothing(Re) ? Rm * 0.6 : Re
    Rm_eff = isnothing(Rm) ? Re * 1.3 : Rm

    # Základní meze únavy (přibližně podle ČSN/MATLAB poměrů)
    sigmae_tah   = Rm_eff * 0.40 * kZ       # tah/tlak
    sigmae_ohyb  = Rm_eff * 0.40 * kZ      # ohyb
    taue_smyk  = Rm_eff * 0.23 * kZ      # smyk
    taue_krut  = Rm_eff * 0.23 * kZ     # krut

    # --- Dovolené únavové napětí (pro porovnání s Re) ---
    sigmae_Re = Re_eff * 0.40 * kZ      # tah/tlak
    taue_Re = Re_eff * 0.25 * kZ     # smyk/krut

    # --- Výběr hlavní meze podle typu namáhání ---
    B = if Nn == ["tah", "tlak"]
        sigmae_tah
    elseif Nn == "ohyb"
        sigmae_ohyb
    elseif Nn == "střih"
        taue_smyk
    elseif Nn == "krut"
        taue_krut
    else
        sigmae_tah
    end

    if tisk
        println("─── Meze únavy ───")
        println("Namáhání: ", Nn)
        println("Zatížení: ", Zn)
        for (k,v) in sort(collect(B))
            println(rpad(k, 14), " = ", round(uconvert(u"MPa", v); sigdigits=5))
        end
        println("──────────────────")
    end

    return B
end