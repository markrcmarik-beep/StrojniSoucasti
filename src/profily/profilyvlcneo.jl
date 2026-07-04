## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet nejvzdálenějšího vlákna od neutrální osy (těžiště) průřezu 
# pro daný tvar profilu. Pro výpočet Wo (průřezový modul v ohybu). 
# Dle natočení profilu.
# ver: 2026-07-04
## Funkce: profilyvlcneo()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcneo.jl
#
## Vzor:
## vystupni_promenne = profilyvlcneo(vstupni_promenne)
## Vstupní proměnné:
# tvar1 - slovník (Dict) s informacemi o tvaru, např.:
#    Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm")
#    Dict("info" => "KR", "D" => 20u"mm")
#    Dict("info" => "TRKR", "D" => 20u"mm", "d" => 10u"mm")
#    Dict("info" => "4HR", "a" => 20u"mm")
#    Dict("info" => "6HR", "s" => 20u"mm")
#    Dict("info" => "TR4HR", "a" => 20u"mm", "b" => 10u"mm", "t" => 4u"mm")
# velicina - hledaná veličina: 
#    :eo - Vzdálenost nejvzdálenějšího vlákna od neutrální osy (těžiště) [mm] dle natočení (pro výpočet Wo)
#    :ex - Vzdálenost nejvzdálenějšího vlákna od neutrální osy (těžiště) x [mm] (pro výpočet Wx)
#    :ey - Vzdálenost nejvzdálenějšího vlákna od neutrální osy (těžiště) y [mm] (pro výpočet Wy)
# natoceni - natočení profilu v radiánech (0 = bez natočení)
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
function profilyvlcneo(tvar1::Dict, velicina::Symbol = :eo, natoceni=0)
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
        if velicina == :ex
            b = getn(:b)
            return b/2, "b/2"
        elseif velicina == :ey
            a = getn(:a)
            return a/2, "a/2"
        elseif velicina == :eo
            if isrot(angle, 0) || isrot(angle, pi)
                eo, eo_str = profilyvlcneo(tvar1, :ex)
            elseif isrot(angle, pi/2) || isrot(angle, 3*pi/2)
                eo, eo_str = profilyvlcneo(tvar1, :ey)
            else
                a, b = getn(:a), getn(:b)
                eo = 1/2 * (a * abs(sin(angle)) + b * abs(cos(angle)))
                eo_str = "1/2 * (a * abs(sin(angle)) + b * abs(cos(angle)))"
            end
            return eo, eo_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Kruhova tyc
    elseif info == "KR"
        if velicina == :ex || velicina == :ey || velicina == :eo
            D = getn(:D)
            return D/2, "D/2"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Trubka kruhova
    elseif info == "TRKR"
        if velicina == :ex || velicina == :ey || velicina == :eo
            D = getn(:D)
            return D/2, "D/2"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Ctyrhranna tyc
    elseif info == "4HR"
        if velicina == :ex
            if getv(:b) === missing
                a = getn(:a)
                ex, ex_str = a/2, "a/2"
            else
                b = getn(:b)
                ex, ex_str = b/2, "b/2"
            end
            return ex, ex_str
        elseif velicina == :ey
            a = getn(:a)
            ex, ex_str = a/2, "a/2"
            return ex, ex_str
        elseif velicina == :eo
            if isrot(angle, 0) || isrot(angle, pi)
                eo, eo_str = profilyvlcneo(tvar1, :ex)
            elseif isrot(angle, pi/2) || isrot(angle, 3/2*pi)
                eo, eo_str = profilvlcneo(tvar1, :ey)
            elseif getv(:b) === missing
                if isrot(angle, pi/4) || isrot(angle, 3*pi/4) || isrot(angle, 5*pi/4) || isrot(angle, 7*pi/4)
                    a = getn(:a)
                    eo = a/2 * sqrt(2)
                    eo_str = "a/2 * sqrt(2)"
                else
                    a = getn(:a)
                    eo = a/2 * (abs(cos(angle)) + abs(sin(angle)))
                    eo_str = "a/2 * (abs(cos(angle)) + abs(sin(angle)))"
                end
            else
                a, b = getv(:a), getv(:b)
                eo = 1/2 * (a * abs(sin(angle)) + b * abs(cos(angle)))
                eo_str = "1/2 * (a * abs(sin(angle)) + b * abs(cos(angle)))"
            end
            return eo, eo_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Sestihranna tyc (0rad lezi na plose)
    # Sestihranna tyc (s je vzdalenost mezi protilehlymi stranami)
    elseif info == "6HR"
        s = getn(:s) # Ziskani vzdalenosti mezi protilehlymi stranami
        if velicina == :ex
            return s/2, "s/2"
        elseif velicina == :ey
            return s/sqrt(3), "s/sqrt(3)"
        elseif velicina == :eo
            if isrot(angle, 0) || isrot(angle, 60*pi/180) || isrot(angle, 120*pi/180) || 
                isrot(angle, pi) || isrot(angle, 240*pi/180) || isrot(angle, 300*pi/180)
                eo, eo_str = profilyvlcneo(tvar1, :ex)
            elseif isrot(angle, 30*pi/180) || isrot(angle, 90*pi/180) || isrot(angle, 150*pi/180) || 
                isrot(angle, 210*pi/180) || isrot(angle, 270*pi/180) || isrot(angle, 330*pi/180)
                eo, eo_str = profilyvlcneo(tvar1, :ey)
            else
                eo = s / √3 * cos(abs(mod(angle + π/6, π/3) - π/6))
                eo_str = "s / √3 * cos(abs(mod(angle + π/6, π/3) - π/6))"
            end
            return eo, eo_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Trubka ctyrhranna
    elseif info == "TR4HR"
        if velicina == :ex
            b = getn(:b)
            return b/2, "b/2"
        elseif velicina == :ey
            a = getn(:a)
            return a/2, "a/2"
        elseif velicina == :eo
            if isrot(angle, 0) || isrot(angle, pi)
                eo, eo_str = profilyvlcneo(tvar1, :ex)
            elseif isrot(angle, pi/2) || isrot(angle, 3*pi/2)
                eo, eo_str = profilyvlcneo(tvar1, :ey)
            else
                a, b = getn(:a), getn(:b)
                eo = 1/2 * (a * abs(sin(angle)) + b * abs(cos(angle)))
                eo_str = "1/2 * (a * abs(sin(angle)) + b * abs(cos(angle)))"
            end
            return eo, eo_str
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
