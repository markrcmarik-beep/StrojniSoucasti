## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet kvadratickeho momentu Ix, Iy pro ruzne tvary dle zkratky oznaceni.
# ver: 2026-02-28
## Funkce: profilyvlcnIx()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnIx.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnIx(vstupni_promenne)
## Vstupní proměnné:
# tvar1 - slovník (Dict) s informacemi o tvaru, např.:
#    Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm")
#    Dict("info" => "KR", "D" => 20u"mm")
#    Dict("info" => "TRKR", "D" => 20u"mm", "d" => 10u"mm")
#    Dict("info" => "4HR", "a" => 20u"mm")
#    Dict("info" => "6HR", "s" => 20u"mm")
#    Dict("info" => "TR4HR", "a" => 20u"mm", "b" => 10u"mm", "t" => 4u"mm")
# velicina - hledaná veličina: :Ix, :Iy, :Ixy
## Výstupní proměnné:
# vystupni_promenne - Struktura (Dict) s rozměry profilu a
#   případně i s vypočtenými vlastnostmi. V tomto případě Ix, Iy, Ixy.
## Použité balíčky:
# Unitful
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
using Unitful

function profilyvlcnIx(tvar1::Dict, velicina::Symbol, natoceni=0)
    info = tvar1[:info] # Ziskani informace o tvaru
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrati hodnotu nebo missing

    angle = mod(natoceni, 2*pi) # Normalizace natočení do rozsahu [0, 2π)
    isrot(x, y) = isapprox(x, y; atol=1e-12, rtol=0.0) # Porovnani natočení s tolerancí

    # Podpora :Iy delegaci na :Ix (rotace o 90 deg)
    if velicina == :Iy
        return profilyvlcnIx(tvar1, :Ix, angle + pi/2) # Rotace Ix o 90 deg pro Iy
    end

    # -----------------------------------------------------------
    # Plocha tyc nebo obdelnik
    if info in Set(["PLO", "OBD"])
        if velicina == :Ixy
            return 0, "0"
        elseif velicina == :Ix
            a, b = getv(:a), getv(:b)
            if isrot(angle, 0) || isrot(angle, pi)
                return a*b^3/12, "a*b^3/12"
            elseif isrot(angle, pi/2) || isrot(angle, 3*pi/2)
                return b*a^3/12, "b*a^3/12"
            else
                error("Neplatne natoceni profilu: $info $natoceni rad pro $velicina")
            end
        end

    # -----------------------------------------------------------
    # Kruhova tyc
    elseif info == "KR"
        if velicina == :Ixy
            return 0, "0"
        elseif velicina == :Ix
            D = getv(:D)
            return pi/64*D^4, "pi/64*D^4"
        end

    # -----------------------------------------------------------
    # Trubka kruhova
    elseif info == "TRKR"
        if velicina == :Ixy
            return 0, "0"
        elseif velicina == :Ix
            D, d = getv(:D), getv(:d)
            return pi/64*(D^4 - d^4), "pi/64*(D^4 - d^4)"
        end

    # -----------------------------------------------------------
    # Ctyrhranna tyc
    elseif info == "4HR"
        if velicina == :Ixy
            return 0, "0"
        elseif velicina == :Ix
            a = getv(:a)
            if isrot(angle, 0) || isrot(angle, pi/2) || isrot(angle, pi) || isrot(angle, 3*pi/2)
                return a^4/12, "a^4/12"
            else
                error("Neplatne natoceni profilu: $info $natoceni rad pro $velicina")
            end
        end

    # -----------------------------------------------------------
    # Sestihranna tyc (0rad lezi na plose)
    elseif info == "6HR"
        if velicina == :Ixy
            return 0, "0"
        elseif velicina == :Ix
            s = getv(:s)
            n = round(Int, angle / (pi/6))
            if !isrot(angle, n*(pi/6))
                error("Neplatne natoceni profilu: $info $natoceni rad pro $velicina")
            elseif iseven(n)
                return 5*sqrt(3)/144*s^4, "5*sqr(3)/144*s^4"
            else
                return 5/96*s^4, "5/96*s^4"
            end
        end

    # -----------------------------------------------------------
    # Trubka ctyrhranna
    elseif info == "TR4HR"
        if velicina == :Ixy
            return 0, "0"
        elseif velicina == :Ix
            a, b, t = getv(:a), getv(:b), getv(:t)
            return (a*b^3/12) - ((a-2t)*(b-2t)^3/12), "(a*b^3/12)-((a-2t)*(b-2t)^3/12)"
        end

    # -----------------------------------------------------------
    # Neznamy tvar
    else
        error("Neznamy tvar: $info pro velicinu $velicina")
    end

    error("Nepodporovana velicina: $velicina pro tvar $info")
end
