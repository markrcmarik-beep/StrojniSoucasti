## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet poloměru setrvačnosti pro ruzné tvary dle zkratky označení.
# ver: 2026-07-09
## Funkce: profilyvlcnixy()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnixy.jl
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
#    :ix - poloměr setrvačnosti pro osu x [mm]
#    :iy - poloměr setrvačnosti pro osu y [mm]
#    :i - poloměr setrvačnosti pro osu dle natočení [mm]
## Výstupní proměnné:
# vystupni_promenne - Struktura (Dict) s rozměry profilu a
#   případně i s vypočtenými vlastnostmi. V tomto případě ix, iy, i.
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
function profilyvlcnixy(tvar1::Dict, velicina::Symbol = :i, natoceni=0)
    info = tvar1[:info] # Ziskani informace o tvaru
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrati hodnotu nebo missing
    to_num(v, name::Symbol) = begin
        v === missing && error("Chybi parametr: $name")
        v isa Number || error("Parametr $name musí být číslo.")
        v / oneunit(v)
    end
    getn(k::Symbol) = to_num(getv(k), k)
    angle = mod(natoceni, 2*pi) # Normalizace natočení do rozsahu [0, 2π)
    isrot(x, y) = isapprox(x, y; atol=1e-12, rtol=0.0) # Porovnani natočení s tolerancí
    # -----------------------------------------------------------
    # Plocha tyc nebo obdelnik
    # -----------------------------------------------------------
    # Kruhova tyc
    # -----------------------------------------------------------
    # Trubka kruhova
    # -----------------------------------------------------------
    # Ctyrhranna tyc
    # -----------------------------------------------------------
    # 6HR - Sestihranna tyc (0rad lezi na plose)
    # -----------------------------------------------------------
    # TR4HR - Trubka ctyrhranna
    if info in Set(["PLO", "OBD", "KR", "TRKR", "4HR", "6HR", "TR4HR"])
        if velicina == :ix
            Ix = profilyvlcnI(tvar1, :Ix)
            S = profilyvlcnS(tvar1, :S)
            ix, ix_str = sqrt(Ix/S), "sqrt(Ix/S)"
            return ix, ix_str
        elseif velicina == :iy
            Iy = profilyvlcnI(tvar1, :Iy)
            S = profilyvlcnS(tvar1, :S)
            iy, iy_str = sqrt(Iy/S), "sqrt(Iy/S)"
            return iy, iy_str
        elseif velicina == :i
            if isrot(angle, 0) || isrot(angle, pi)
                i, i_str = profilyixy(tvar1, ix)
            elseif isrot(angle, pi/2) || isrot(angle, 3/2*pi)
                i, i_str = profilyixy(tvar1, iy)
            else
                I = profilyvlcnI(tvar1, :I, angle)
                S = profilyvlcnS(tvar1, :S)
                i, i_str = sqrt(I/S), "sqrt(I/S)"
            end
            return i, i_str
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
