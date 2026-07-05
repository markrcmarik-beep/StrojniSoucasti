## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet nejvzdálenějšího vlákna od neutrální osy rotace průřezu 
# pro daný tvar profilu. Pro výpočet Wk (průřezový modul v krutu). 
# ver: 2026-07-05
## Funkce: profilyvlcnrmax()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnrmax.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnrmax(vstupni_promenne)
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
function profilyvlcnrmax(tvar1::Dict, velicina::Symbol = :rmax)
    info = tvar1[:info] # Ziskani informace o tvaru
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrati hodnotu nebo missing
    to_num(v, name::Symbol) = begin
        v === missing && error("Chybi parametr: $name")
        v isa Number || error("Parametr $name musi byt cislo.")
        v / oneunit(v)
    end
    getn(k::Symbol) = to_num(getv(k), k)

    isrot(x, y) = isapprox(x, y; atol=1e-12, rtol=0.0) # Porovnani natočení s tolerancí
    # -----------------------------------------------------------
    # Plocha tyc nebo obdelnik
    if info in Set(["PLO", "OBD"])
        if velicina == :rmax
            a = getn(:a)
            b = getn(:b)
            return sqrt(a^2 + b^2)/2, "sqrt(a^2 + b^2)/2"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Kruhova tyc
    elseif info == "KR"
        if velicina == :rmax
            D = getn(:D)
            return D/2, "D/2"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Trubka kruhova
    elseif info == "TRKR"
        if velicina == :rmax
            D = getn(:D)
            return D/2, "D/2"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Ctyrhranna tyc
    elseif info == "4HR"
        if velicina == :rmax
            if getv(:b) === missing
                a = getn(:a)
                rmax, rmax_str = a/2 * sqrt(2), "a/2 * sqrt(2)"
            else
                a, b = getn(:a), getn(:b)
                rmax, rmax_str = sqrt(a^2 + b^2)/2, "sqrt(a^2 + b^2)/2"
            end
            return rmax, rmax_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Sestihranna tyc (0rad lezi na plose)
    # Sestihranna tyc (s je vzdalenost mezi protilehlymi stranami)
    elseif info == "6HR"
        if velicina == :rmax
            s = getn(:s) # Ziskani vzdalenosti mezi protilehlymi stranami
            return s/sqrt(3), "s/sqrt(3)"
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Trubka ctyrhranna
    elseif info == "TR4HR"
        if velicina == :rmax
            a, b = getn(:a), getn(:b)
            rmax, rmax_str = sqrt(a^2 + b^2)/2, "sqrt(a^2 + b^2)/2"
            return rmax, rmax_str
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
