## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-02-01
## Funkce: profilyvlcnIminImax()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnIminImax.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnIminImax(vstupni_promenne)
## Vstupní proměnné:
#
## Výstupní proměnné:
#
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
using Unitful

function profilyvlcnIminImax(tvar1::Dict, velicina::Symbol, natoceni=0)
    info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrátí hodnotu nebo missing

    # -----------------------------------------------------------
    # Plochá tyč nebo obdélník
    if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
        Ix, _ = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, 0)
        Iy, _ = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, pi/2)
        Ixy, _ = StrojniSoucasti.profilyvlcnIx(tvar1, :Ixy)
        Ixy = Ixy * u"mm^4"
        if velicina == :Imin
            Imin_val = (Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )
            # Vzorec pro obdélník s Iy = b*a³/12 a Ix = a*b³/12
            Imin_str = "-sqrt((1//4)*((-(1//12)*(a^3)*b + (1//12)*a*(b^3))^2)) + (1//2)*((1//12)*(a^3)*b + (1//12)*a*(b^3))"
            return Imin_val, Imin_str
        elseif velicina == :Imax
            Imax_val = (Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )
            # Vzorec pro obdélník s Iy = b*a³/12 a Ix = a*b³/12
            Imax_str = "(Ix + Iy)/2 + √( ((Ix - Iy)/2)² + Ixy² )"
            return Imax_val, Imax_str
        end
    # -----------------------------------------------------------
    # Kruhová tyč
    elseif info == "KR" # Kruhová tyč
        D = getv(:D)
        return pi/64*D^4, "π/64*D⁴"
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        D, d = getv(:D), getv(:d)
        return pi/64*(D^4 - d^4), "π/64*(D⁴ - d⁴)"
    # -----------------------------------------------------------
    else
        error("Neznámý tvar: $info pro veličinu $velicina")
    end

end
