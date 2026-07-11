## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet kvadratickeho momentu Ix, Iy pro ruzne tvary dle zkratky oznaceni.
# ver: 2026-07-11
## Funkce: profilyvlcnI()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnI.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnI(vstupni_promenne)
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
function profilyvlcnI(tvar1::Dict, velicina::Symbol = :Ix, natoceni=0)
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
    # -----------------------------------------------------------
    # Plocha tyc nebo obdelnik
    if info in Set(["PLO", "OBD"])
        if velicina == :Ixy
            if isrot(angle, 0) || isrot(angle, pi/2) || isrot(angle, pi) || isrot(angle, 3*pi/2)
                return 0, "0"
            else
                Ix = profilyvlcnI(tvar1, :Ix)[1]
                Iy = profilyvlcnI(tvar1, :Iy)[1]
                Ixy = profilyvlcnI(tvar1, :Ixy)[1]
                Ixy, Ixy_str = profilyIxy4natoceni(Ix, Iy, Ixy, angle, true)
                return Ixy, Ixy_str
            end
        elseif velicina == :Ix
            a, b = getn(:a), getn(:b)
            return a*b^3/12, "a*b^3/12"
        elseif velicina == :Iy
            a, b = getn(:a), getn(:b)
            return b*a^3/12, "b*a^3/12"
        elseif velicina == :I
            if isrot(angle, 0) || isrot(angle, pi)
                I, I_str = profilyvlcnI(tvar1, :Ix)
            elseif isrot(angle, pi/2) || isrot(angle, 3*pi/2)
                I, I_str = profilyvlcnI(tvar1, :Iy)
            else
                Ix = profilyvlcnI(tvar1, :Ix)[1]
                Iy = profilyvlcnI(tvar1, :Iy)[1]
                Ixy = profilyvlcnI(tvar1, :Ixy)[1]
                I, I_str = profilyI4natoceni(Ix, Iy, Ixy, angle, true)
            end
            return I, I_str
        elseif velicina == :Imin
            Ix = profilyvlcnI(tvar1, :Ix)[1]
            Iy = profilyvlcnI(tvar1, :Iy)[1]
            Ixy = profilyvlcnI(tvar1, :Ixy)[1]
            Imin, _, Imin_str, _ = profilyIminmax(Ix, Iy, Ixy, true)
            return Imin, Imin_str
        elseif velicina == :Imax
            Ix = profilyvlcnI(tvar1, :Ix, 0)[1]
            Iy = profilyvlcnI(tvar1, :Iy, 0)[1]
            Ixy = profilyvlcnI(tvar1, :Ixy, 0)[1]
            _, Imax, _, Imax_str = profilyIminmax(Ix, Iy, Ixy, true)
            return Imax, Imax_str
            #return (Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ), "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Kruhova tyc
    elseif info == "KR"
        if velicina == :Ixy
            return 0, "0"
        elseif velicina == :Ix || velicina == :Iy || velicina == :I
            getv(:d) === missing ? d = 0 : d = getn(:d)
            D = getn(:D)
            if d == 0
                return pi/64*D^4, "pi/64*D^4"
            else
                return pi/64*(D^4 - d^4), "pi/64*(D^4 - d^4)"
            end
        elseif velicina == :Imin || velicina == :Imax
            getv(:d) === missing ? d = 0 : d = getn(:d)
            D = getn(:D)
            if d == 0
                return pi/64*D^4, "pi/64*D^4"
            else
                return pi/64*(D^4 - d^4), "pi/64*(D^4 - d^4)"
            end
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Trubka kruhova
    elseif info == "TRKR"
        if velicina == :Ixy
            return 0, "0"
        elseif velicina == :Ix || velicina == :Iy || velicina == :I
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
                Ix = profilyvlcnI(tvar1, :Ix)[1]
                Iy = profilyvlcnI(tvar1, :Iy)[1]
                Ixy = profilyvlcnI(tvar1, :Ixy)[1]
                Ixy, Ixy_str = profilyIxy4natoceni(Ix, Iy, Ixy, angle, true)
                return Ixy, Ixy_str
            end
        elseif velicina == :Ix
            if getv(:b) === missing
                a = getn(:a)
                return a^4/12, "a^4/12"
            else
                a, b = getn(:a), getn(:b)
                return a*b^3/12, "a*b^3/12"
            end
        elseif velicina == :Iy
            if getv(:b) === missing
                a = getn(:a)
                return a^4/12, "a^4/12"
            else
                a, b = getn(:a), getn(:b)
                return b*a^3/12, "b*a^3/12"
            end
        elseif velicina == :I
            if isrot(angle, 0) || isrot(angle, pi)
                I, I_str = profilyvlcnI(tvar1, :Ix)
            elseif isrot(angle, pi/2) || isrot(angle, 3*pi/2)
                I, I_str = profilyvlcnI(tvar1, :Iy)
            else
                Ix = profilyvlcnI(tvar1, :Ix)[1]
                Iy = profilyvlcnI(tvar1, :Iy)[1]
                Ixy = profilyvlcnI(tvar1, :Ixy)[1]
                I, I_str = profilyI4natoceni(Ix, Iy, Ixy, angle, true)
            end
            return I, I_str
        elseif velicina == :Imin
            Ix = profilyvlcnI(tvar1, :Ix, 0)[1]
            Iy = profilyvlcnI(tvar1, :Iy, 0)[1]
            Ixy = profilyvlcnI(tvar1, :Ixy, 0)[1]
            Imin, _, Imin_str, _ = profilyIminmax(Ix, Iy, Ixy, true)
            return Imin, Imin_str
        elseif velicina == :Imax
            Ix = profilyvlcnI(tvar1, :Ix, 0)[1]
            Iy = profilyvlcnI(tvar1, :Iy, 0)[1]
            Ixy = profilyvlcnI(tvar1, :Ixy, 0)[1]
            _, Imax, _, Imax_str = profilyIminmax(Ix, Iy, Ixy, true)
            return Imax, Imax_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # 6HR - Sestihranna tyc (0rad lezi na plose)
    # Sestihranna tyc (s je vzdalenost mezi protilehlymi stranami)
    elseif info == "6HR"
        # Regularni sestihran ma v tezisti izotropni matici setrvacnosti:
        # Ix = Iy a Ixy = 0 pro libovolne natoceni.
        # I_hex = 5*sqrt(3)/144*s^4
        if velicina == :Ixy
            if isrot(angle, 0) || isrot(angle, 30*pi/180) || isrot(angle, 60*pi/180) || 
                isrot(angle, 90*pi/180) || isrot(angle, 120*pi/180) || isrot(angle, 150*pi/180) ||
                isrot(angle, 180*pi/180) || isrot(angle, 210*pi/180) || isrot(angle, 240*pi/180) || 
                isrot(angle, 270*pi/180) || isrot(angle, 300*pi/180) || isrot(angle, 330*pi/180)
                return 0, "0"
            else
                Ix = profilyvlcnI(tvar1, :Ix)[1]
                Iy = profilyvlcnI(tvar1, :Iy)[1]
                Ixy = profilyvlcnI(tvar1, :Ixy)[1]
                Ixy, Ixy_str = profilyIxy4natoceni(Ix, Iy, Ixy, angle, true)
                return Ixy, Ixy_str
            end
        elseif velicina == :Ix
            s = getn(:s) # Strana šestihranu
            return 5*sqrt(3)/144*s^4, "5*sqrt(3)/144*s^4"
        elseif velicina == :Iy
            s = getn(:s) # Strana šestihranu
            return 5*sqrt(3)/144*s^4, "5*sqrt(3)/144*s^4"
        elseif velicina == :I
            if isrot(angle, 0) || isrot(angle, 60*pi/180) || isrot(angle, 120*pi/180) || 
                isrot(angle, 180*pi/180) || isrot(angle, 240*pi/180) || isrot(angle, 300*pi/180)
                I, I_str = profilyvlcnI(tvar1, :Ix)
            elseif isrot(angle, 30*pi/180) || isrot(angle, 90*pi/6) || isrot(angle, 150*pi/180) || 
                isrot(angle, 210*pi/180) || isrot(angle, 270*pi/180) || isrot(angle, 330*pi/180)
                I, I_str = profilyvlcnI(tvar1, :Iy)
            else
                Ix = profilyvlcnI(tvar1, :Ix)[1]
                Iy = profilyvlcnI(tvar1, :Iy)[1]
                Ixy = profilyvlcnI(tvar1, :Ixy)[1]
                I, I_str = profilyI4natoceni(Ix, Iy, Ixy, angle, true)
            end
            return I, I_str
        elseif velicina == :Imin
            Ix = profilyvlcnI(tvar1, :Ix, 0)[1]
            Iy = profilyvlcnI(tvar1, :Iy, 0)[1]
            Ixy = profilyvlcnI(tvar1, :Ixy, 0)[1]
            Imin, _, Imin_str, _ = profilyIminmax(Ix, Iy, Ixy, true)
            return Imin, Imin_str
        elseif velicina == :Imax
            Ix = profilyvlcnI(tvar1, :Ix, 0)[1]
            Iy = profilyvlcnI(tvar1, :Iy, 0)[1]
            Ixy = profilyvlcnI(tvar1, :Ixy, 0)[1]
            _, Imax, _, Imax_str = profilyIminmax(Ix, Iy, Ixy, true)
            return Imax, Imax_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # TR4HR - Trubka ctyrhranna
    elseif info == "TR4HR"
        if velicina == :Ixy
            if isrot(angle, 0) || isrot(angle, pi/2) || isrot(angle, pi) || isrot(angle, 3*pi/2)
                return 0, "0"
            else
                Ix = profilyvlcnI(tvar1, :Ix)[1]
                Iy = profilyvlcnI(tvar1, :Iy)[1]
                Ixy = profilyvlcnI(tvar1, :Ixy)[1]
                Ixy, Ixy_str = profilyIxy4natoceni(Ix, Iy, Ixy, angle, true)
                return Ixy, Ixy_str
            end
        elseif velicina == :Ix
            a, b, t = getn(:a), getn(:b), getn(:t)
            return (a*b^3 - (a-2t)*(b-2t)^3) / 12, "(a*b^3/12)-((a-2t)*(b-2t)^3/12)"
        elseif velicina == :Iy
            a, b, t = getn(:a), getn(:b), getn(:t)
            return (b*a^3 - (b-2t)*(a-2t)^3) / 12, "(b*a^3/12)-((b-2t)*(a-2t)^3/12)"
        elseif velicina == :I
            if isrot(angle, 0) || isrot(angle, pi)
                I, I_str = profilyvlcnI(tvar1, :Ix)
            elseif isrot(angle, pi/2) || isrot(angle, 3*pi/2)
                I, I_str = profilyvlcnI(tvar1, :Iy)
            else
                Ix = profilyvlcnI(tvar1, :Ix)[1]
                Iy = profilyvlcnI(tvar1, :Iy)[1]
                Ixy = profilyvlcnI(tvar1, :Ixy)[1]
                I, I_str = profilyI4natoceni(Ix, Iy, Ixy, angle, true)
            end
            return I, I_str
        elseif velicina == :Imin
            Ix = profilyvlcnI(tvar1, :Ix, 0)[1]
            Iy = profilyvlcnI(tvar1, :Iy, 0)[1]
            Ixy = profilyvlcnI(tvar1, :Ixy, 0)[1]
            Imin, _, Imin_str, _ = profilyIminmax(Ix, Iy, Ixy, true)
            return Imin, Imin_str
        elseif velicina == :Imax
            Ix = profilyvlcnI(tvar1, :Ix, 0)[1]
            Iy = profilyvlcnI(tvar1, :Iy, 0)[1]
            Ixy = profilyvlcnI(tvar1, :Ixy, 0)[1]
            _, Imax, _, Imax_str = profilyIminmax(Ix, Iy, Ixy, true)
            return Imax, Imax_str
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
