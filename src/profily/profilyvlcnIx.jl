## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet kvadratickeho momentu Ix, Iy pro ruzne tvary dle zkratky oznaceni.
# ver: 2026-05-21
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
# velicina - hledaná veličina: 
#    :Ix - Kvadratický moment průřezu [mm⁴]
#    :Iy - Kvadratický moment průřezu [mm⁴]
#    :Ixy - Kvadratický moment průřezu [mm⁴]
## Výstupní proměnné:
# vystupni_promenne - Struktura (Dict) s rozměry profilu a
#   případně i s vypočtenými vlastnostmi. V tomto případě Ix, Iy, Ixy.
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
function profilyvlcnIx(tvar1::Dict, velicina::Symbol = :Ix, natoceni=0)
    info = tvar1[:info] # Ziskani informace o tvaru
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrati hodnotu nebo missing
    to_num(v, name::Symbol) = begin
        v === missing && error("Chybi parametr: $name")
        v isa Number || error("Parametr $name musi byt cislo.")
        v / oneunit(v)
    end
    getn(k::Symbol) = to_num(getv(k), k)

    angle = mod(natoceni, 2*pi) # Normalizace natočení do rozsahu [0, 2π)
    isrot(x, y) = isapprox(x, y; atol=1e-12, rtol=0.0) # Porovnani natočení s tolerancí

    # Podpora :Iy delegaci na :Ix (rotace o 90 deg)
    #if velicina == :Iy
    #    return profilyvlcnIx(tvar1, :Ix, angle + pi/2) # Rotace Ix o 90 deg pro Iy
    #end
    # -----------------------------------------------------------
    # Plocha tyc nebo obdelnik
    if info in Set(["PLO", "OBD"])
        if velicina == :Ixy
            if isrot(angle, 0) || isrot(angle, pi/2) || isrot(angle, pi) || isrot(angle, 3*pi/2)
                return 0, "0"
            else
                Ix, _ = profilyvlcnIx(tvar1, :Ix, 0)
                Iy, _ = profilyvlcnIx(tvar1, :Iy, 0)
                return (-Ix+Iy)/2 * sin(2*angle), "(-Ix+Iy)/2 * sin(2*angle)"
            end
        elseif velicina == :Ix
            a, b = getn(:a), getn(:b)
            if isrot(angle, 0) || isrot(angle, pi)
                return a*b^3/12, "a*b^3/12"
            elseif isrot(angle, pi/2) || isrot(angle, 3*pi/2)
                return b*a^3/12, "b*a^3/12"
            else
                Ix, _ = profilyvlcnIx(tvar1, :Ix, 0)
                Iy, _ = profilyvlcnIx(tvar1, :Iy, 0)
                return (Ix + Iy)/2 + (Ix - Iy)/2 * cos(2*angle), "(Ix + Iy)/2 + (Ix - Iy)/2 * cos(2*angle)"
            end
        elseif velicina == :Iy
            return profilyvlcnIx(tvar1, :Ix, angle + pi/2) # Rotace Ix o 90 deg pro Iy
        elseif velicina == :Imin
            Ix, _ = profilyvlcnIx(tvar1, :Ix, 0)
            Iy, _ = profilyvlcnIx(tvar1, :Iy, 0)
            Ixy, _ = profilyvlcnIx(tvar1, :Ixy, 0)
            return (Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ), "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        elseif velicina == :Imax
            Ix, _ = profilyvlcnIx(tvar1, :Ix, 0)
            Iy, _ = profilyvlcnIx(tvar1, :Iy, 0)
            Ixy, _ = profilyvlcnIx(tvar1, :Ixy, 0)
            return (Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ), "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Kruhova tyc
    elseif info == "KR"
        if velicina == :Ixy
            return 0, "0"
        elseif velicina == :Ix || velicina == :Iy
            D = getn(:D)
            return pi/64*D^4, "pi/64*D^4"
        elseif velicina == :Imin || velicina == :Imax
            D = getn(:D)
            return pi/64*D^4, "pi/64*D^4"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Trubka kruhova
    elseif info == "TRKR"
        if velicina == :Ixy
            return 0, "0"
        elseif velicina == :Ix || velicina == :Iy
            D, d = getn(:D), getn(:d)
            return pi/64*(D^4 - d^4), "pi/64*(D^4 - d^4)"
        elseif velicina == :Imin || velicina == :Imax
            D, d = getn(:D), getn(:d)
            return pi/64*(D^4 - d^4), "pi/64*(D^4 - d^4)"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Ctyrhranna tyc
    elseif info == "4HR"
        if velicina == :Ixy
            if isrot(angle, 0) || isrot(angle, pi/2) || isrot(angle, pi) || isrot(angle, 3*pi/2)
                return 0, "0"
            else
                Ix, _ = profilyvlcnIx(tvar1, :Ix, 0)
                Iy, _ = profilyvlcnIx(tvar1, :Iy, 0)
                return (-Ix+Iy)/2 * sin(2*angle), "(-Ix+Iy)/2 * sin(2*angle)"
            end
        elseif velicina == :Ix
            if isrot(angle, 0) || isrot(angle, pi/2) || isrot(angle, pi) || isrot(angle, 3*pi/2)
                a = getn(:a)
                return a^4/12, "a^4/12"
            else
                Ix, _ = profilyvlcnIx(tvar1, :Ix, 0)
                Iy, _ = profilyvlcnIx(tvar1, :Iy, 0)
                return (Ix + Iy)/2 + (Ix - Iy)/2 * cos(2*angle), "(Ix + Iy)/2 + (Ix - Iy)/2 * cos(2*angle)"
            end
        elseif velicina == :Iy
            return profilyvlcnIx(tvar1, :Ix, angle + pi/2)
        elseif velicina == :Imin
            Ix, _ = profilyvlcnIx(tvar1, :Ix, 0)
            Iy, _ = profilyvlcnIx(tvar1, :Iy, 0)
            Ixy, _ = profilyvlcnIx(tvar1, :Ixy, 0)
            return (Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ), "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        elseif velicina == :Imax
            Ix, _ = profilyvlcnIx(tvar1, :Ix, 0)
            Iy, _ = profilyvlcnIx(tvar1, :Iy, 0)
            Ixy, _ = profilyvlcnIx(tvar1, :Ixy, 0)
            return (Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ), "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Sestihranna tyc (0rad lezi na plose)
    elseif info == "6HR"
        if velicina == :Ixy
            if isrot(angle, 0) || isrot(angle, 2*pi/6) || isrot(angle, 4*pi/6) || isrot(angle, 6*pi/6) || isrot(angle, 8*pi/6) || isrot(angle, 10*pi/6) || isrot(angle, 12*pi/6)
                return 0, "0"
            else
                Ix, _ = profilyvlcnIx(tvar1, :Ix, 0)
                Iy, _ = profilyvlcnIx(tvar1, :Iy, 0)
                return (-Ix+Iy)/2 * sin(2*angle), "(-Ix+Iy)/2 * sin(2*angle)"
            end
        elseif velicina == :Ix
            s = getn(:s) # Strana šestihranu
            n = round(Int, angle / (pi/6)) # Určení indexu natočení pro šestihrannou tyč
            if angle in (0, 2*pi/6, 4*pi/6, 6*pi/6, 8*pi/6, 10*pi/6, 12*pi/6)
                return 5*sqrt(3)/144*s^4, "5*sqr(3)/144*s^4"
            elseif angle in (pi/6, 3*pi/6, 5*pi/6, 7*pi/6, 9*pi/6, 11*pi/6)
                return 5/96*s^4, "5/96*s^4"
            else
                Ix_hod, _ = profilyvlcnIx(tvar1, :Ix, 0)
                Iy_hod, _ = profilyvlcnIx(tvar1, :Iy, 0)
                Ixy_hod, _ = profilyvlcnIx(tvar1, :Ixy, 0)
                return (Ix_hod*Iy_hod - Ixy_hod^2) / (Iy_hod*sqrt(Ix_hod^2 + Iy_hod^2 - 2*Ixy_hod^2) - Ix_hod*sqrt(Ix_hod^2 + Iy_hod^2 - 2*Ixy_hod^2)), "(Ix*Iy - Ixy^2) / (Iy*sqrt(Ix^2 + Iy^2 - 2*Ixy^2) - Ix*sqrt(Ix^2 + Iy^2 - 2*Ixy^2))"
            end
        elseif velicina == :Iy
            return profilyvlcnIx(tvar1, :Ix, angle + pi/2) # Rotace Ix o 90 deg pro Iy
        elseif velicina == :Imin
            Ix, _ = profilyvlcnIx(tvar1, :Ix, 0)
            Iy, _ = profilyvlcnIx(tvar1, :Iy, 0)
            Ixy, _ = profilyvlcnIx(tvar1, :Ixy, 0)
            return (Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ), "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        elseif velicina == :Imax
            Ix, _ = profilyvlcnIx(tvar1, :Ix, 0)
            Iy, _ = profilyvlcnIx(tvar1, :Iy, 0)
            Ixy, _ = profilyvlcnIx(tvar1, :Ixy, 0)
            return (Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ), "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Trubka ctyrhranna
elseif info == "TR4HR"
    a, b, t = getn(:a), getn(:b), getn(:t)
    # Zakladni hodnoty v lokalnich osach
    Ix0 = (a*b^3 - (a-2t)*(b-2t)^3) / 12
    Iy0 = (b*a^3 - (b-2t)*(a-2t)^3) / 12
    Ixy0 = 0
    if velicina == :Ix
        if isrot(angle, 0) || isrot(angle, pi/2) || isrot(angle, pi) || isrot(angle, 3*pi/2)
            return (a*b^3 - (a-2t)*(b-2t)^3) / 12, "(a*b^3/12)-((a-2t)*(b-2t)^3/12)"
        else
            return (Ix0 + Iy0)/2 + (Ix0 - Iy0)/2 * cos(2*angle), 
                "(Ix0 + Iy0)/2 + (Ix0 - Iy0)/2 * cos(2*angle)"
        end
    elseif velicina == :Iy
        if isrot(angle, 0) || isrot(angle, pi/2) || isrot(angle, pi) || isrot(angle, 3*pi/2)
            return (b*a^3 - (b-2t)*(a-2t)^3) / 12, "(b*a^3/12)-((b-2t)*(a-2t)^3/12)"
        else
            return profilyvlcnIx(tvar1, :Ix, angle + pi/2) # Rotace Ix o 90 deg pro Iy
        end
    elseif velicina == :Ixy
        return (-(Ix0 - Iy0)/2 * sin(2*angle) + Ixy0 * cos(2*angle),
            "-(Ix0 - Iy0)/2*sin(2*angle) + Ixy0*cos(2*angle)")
    elseif velicina == :Imin
        return ((Ix0 + Iy0)/2 - sqrt(((Ix0 - Iy0)/2)^2 + Ixy0^2),
            "(Ix0 + Iy0)/2 - sqrt(((Ix0 - Iy0)/2)^2 + Ixy0^2)")
    elseif velicina == :Imax
        return ((Ix0 + Iy0)/2 + sqrt(((Ix0 - Iy0)/2)^2 + Ixy0^2),
            "(Ix0 + Iy0)/2 + sqrt(((Ix0 - Iy0)/2)^2 + Ixy0^2)")
    else
        error("Nepodporovana velicina: $velicina pro tvar $info")
    end
    # -----------------------------------------------------------
    # Neznamy tvar
    else
        error("Neznamy tvar: $info pro velicinu $velicina")
    end

    error("Nepodporovana velicina: $velicina pro tvar $info")
end
