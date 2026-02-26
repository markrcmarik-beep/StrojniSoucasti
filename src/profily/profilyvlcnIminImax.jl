## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet hlavnich kvadratickych momentu Imin, Imax.
# ver: 2026-02-26
## Funkce: profilyvlcnIminImax()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnIminImax.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnIminImax(vstupni_promenne)
## Vstupní proměnné:
# tvar1 - slovník (Dict) s informacemi o tvaru, např.:
#    Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm")
# velicina - hledaná veličina: :Imin nebo :Imax
# natoceni - úhel natočení [rad], volitelný (parametr pro Ix a Wo)
## Výstupní proměnné:
# vystupni_promenne - Struktura (Dict) s rozměry profilu a
#   případně i s vypočtenými vlastnostmi. V tomto případě Imin a Imax.
## Použité balíčky:
# Unitful
## Použité uživatelské funkce:
# profilyvlcnIx
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
###############################################################

using Unitful

function profilyvlcnIminImax(tvar1::Dict, velicina::Symbol, natoceni=0)
    info = tvar1[:info]
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing

    if velicina != :Imin && velicina != :Imax
        error("Neznama velicina: $velicina")
    end

    # -----------------------------------------------------------
    # Plocha tyc nebo obdelnik
    if info in Set(["PLO", "OBD"])
        Ix, _ = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, 0)
        Iy, _ = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, pi/2)
        Ixy, _ = StrojniSoucasti.profilyvlcnIx(tvar1, :Ixy)
        Ixy = Ixy * u"mm^4"

        if velicina == :Imin
            Imin_val = (Ix + Iy)/2 - sqrt(((Ix - Iy)/2)^2 + Ixy^2)
            Imin_str = "-sqrt((1//4)*((-(1//12)*(a^3)*b + (1//12)*a*(b^3))^2)) + (1//2)*((1//12)*(a^3)*b + (1//12)*a*(b^3))"
            return Imin_val, Imin_str
        else
            Imax_val = (Ix + Iy)/2 + sqrt(((Ix - Iy)/2)^2 + Ixy^2)
            Imax_str = "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
            return Imax_val, Imax_str
        end

    # -----------------------------------------------------------
    # Kruhova tyc
    elseif info == "KR"
        D = getv(:D)
        return pi/64*D^4, "pi/64*D^4"

    # -----------------------------------------------------------
    # Trubka kruhova
    elseif info == "TRKR"
        D, d = getv(:D), getv(:d)
        return pi/64*(D^4 - d^4), "pi/64*(D^4 - d^4)"

    # -----------------------------------------------------------
    else
        error("Neznamy tvar: $info pro velicinu $velicina")
    end
end
