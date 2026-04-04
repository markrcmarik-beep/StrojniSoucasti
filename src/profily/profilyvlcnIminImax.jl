## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet hlavních kvadratických momentů Imin, Imax.
# ver: 2026-02-28
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
#    Dict("info" => "KR", "D" => 20u"mm")
#    Dict("info" => "TRKR", "D" => 20u"mm", "d" => 10u"mm")
#    Dict("info" => "4HR", "a" => 20u"mm")
#    Dict("info" => "6HR", "s" => 20u"mm")
#    Dict("info" => "TR4HR", "a" => 20u"mm", "b" => 10u"mm", "t" => 4u"mm")
# velicina - hledaná veličina: :Imin nebo :Imax
# natoceni - úhel natočení [rad], volitelný (parametr pro Ix a Wo)
## Výstupní proměnné:
# vystupni_promenne - Struktura (Dict) s rozměry profilu a
#   případně i s vypočtenými vlastnostmi. V tomto případě Imin a Imax.
## Použité balíčky:
# ---
## Použité uživatelské funkce:
# profilyvlcnIx
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
###############################################################
function profilyvlcnIminImax(tvar1::Dict, velicina::Symbol, natoceni=0)
    info = tvar1[:info]
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing
    to_num(v, name::Symbol) = begin
        v === missing && error("Chybi parametr: $name")
        v isa Number || error("Parametr $name musi byt cislo.")
        v / oneunit(v)
    end
    getn(k::Symbol) = to_num(getv(k), k)

    if velicina != :Imin && velicina != :Imax
        error("Neznama velicina: $velicina")
    end

    # -----------------------------------------------------------
    # Plocha tyc nebo obdelnik
    if info in Set(["PLO", "OBD"])
        Ix, Ixtext = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, 0)
        Iy, Iytext = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, pi/2)
        Ixy, Ixytext = StrojniSoucasti.profilyvlcnIx(tvar1, :Ixy)
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
        D = getn(:D)
        return pi/64*D^4, "pi/64*D^4"

    # -----------------------------------------------------------
    # Trubka kruhova
    elseif info == "TRKR"
        D, d = getn(:D), getn(:d)
        return pi/64*(D^4 - d^4), "pi/64*(D^4 - d^4)"

    # -----------------------------------------------------------
    # čtvercový průřez
    elseif info == "4HR"
        a = getn(:a)
        return a^4/12, "a^4/12"
    # -----------------------------------------------------------
    # šestihranný průřez
    elseif info == "6HR"
        s = getn(:s)
        return s^4/6, "s^4/6"
    # -----------------------------------------------------------
    # trubka čtyřhranná
    elseif info == "TR4HR"
        a, b, t = getn(:a), getn(:b), getn(:t)
        return (a*b^3 - (a-2t)*(b-2t)^3)/12, "(a*b^3 - (a-2t)*(b-2t)^3)/12"
    # -----------------------------------------------------------
    # Neznámý tvar
    else
        error("Neznamy tvar: $info pro velicinu $velicina")
    end
end
