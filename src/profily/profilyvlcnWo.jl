## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypočet průřezového modulu v ohybu Wo pro různé tvary dle zkratky označení.
# ver: 2026-07-06
## Funkce: profilyvlcnWo()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profilyvlcnWo.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnWo(vstupni_promenne)
## Vstupní proměnné:
# tvar1 - slovník (Dict) s informacemi o tvaru, např.:
#    Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm")
#    Dict("info" => "KR", "D" => 30u"mm")
#    Dict("info" => "TRKR", "D" => 20u"mm", "d" => 10u"mm")
#    Dict("info" => "4HR", "a" => 20u"mm")
#    Dict("info" => "6HR", "s" => 20u"mm")
#    Dict("info" => "TR4HR", "a" => 20u"mm", "b" => 10u"mm", "t" => 4u"mm")
# velicina - hledaná veličina: 
#    :Wo - Průřezový modul v ohybu [mm³]
## Výstupní proměnné:
# vystupni_promenne - Struktura (Dict) s rozměry profilu a
#   případně i s vypočtenými vlastnostmi. V tomto případě Wo.
## Použité balíčky:
# ---
## Použité uživatelské funkce:
#
## Příklad:
# tvar = Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm") # Definice 
#   tvaru plošné tyče s rozměry a=20 mm, b=10 mm
# Wo, vzorec = profilyvlcnWo(tvar, :Wo) # Vypočet průřezového modulu 
#   v ohybu pro tento tvar vrátí Wo a použitý vzorec
###############################################################
## Použité proměnné vnitřní:
#
function profilyvlcnWo(tvar1::Dict, velicina::Symbol = :Wo, natoceni=0)
    info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrati hodnotu nebo missing
    to_num(v, name::Symbol) = begin
        v === missing && error("Chybi parametr: $name")
        v isa Number || error("Parametr $name musi byt cislo.")
        v / oneunit(v)
    end
    getn(k::Symbol) = to_num(getv(k), k) # Získání numerické hodnoty parametru
    angle = mod(natoceni, 2*pi) # Normalizace úhlu do rozsahu [0, 2π)
    isrot(x, y) = isapprox(x, y; atol=1e-12, rtol=0.0) # Porovnani s toleranci pro rotace
    # -----------------------------------------------------------
    # Plochá tyč nebo obdélník
    if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
        if velicina == :Wx
            a, b = getn(:a), getn(:b)
            return a*b^2/6, "a*b²/6"
        elseif velicina == :Wy
            a, b = getn(:a), getn(:b)
            return b*a^2/6, "b*a²/6"
        elseif velicina == :Wo
            if isrot(angle, 0) || isrot(angle, pi)
                Wo, Wo_str = profilyvlcnWo(tvar1, :Wx)
            elseif isrot(angle, pi/2) || isrot(angle, 3*pi/2)
                Wo, Wo_str = profilyvlcnWo(tvar1, :Wy)
            else
                I = StrojniSoucasti.profilyvlcnI(tvar1, :I, angle)[1]
                eo = StrojniSoucasti.profilyvlcneo(tvar1, :eo, angle)[1]
                Wo, Wo_str = I / eo, "I / eo"
            end
            return Wo, Wo_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Kruhová tyč
    elseif info == "KR" # Kruhová tyč
        if velicina == :Wx || velicina == :Wy || velicina == :Wo
            getv(:d) === missing ? d = 0 : d = getn(:d) # Pokud není zadáno, předpokládáme, že jde o plnou kruhovou tyč
            D = getn(:D)
            if d == 0
                Wo, Wo_str = pi/32*D^3, "π/32*D³"
            else
                Wo, Wo_str = pi/32*(D^4 - d^4)/D, "π/32*(D⁴ - d⁴)/D"
            end
            return Wo, Wo_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        if velicina == :Wx || velicina == :Wy || velicina == :Wo
            D, d = getn(:D), getn(:d)
            if d == 0
                Wo, Wo_str = pi/32*D^3, "π/32*D³"
            else
                Wo, Wo_str = pi/32*(D^4 - d^4)/D, "π/32*(D⁴ - d⁴)/D"
            end
            return Wo, Wo_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Čtyřhranná tyč
    elseif info == "4HR" # Čtyřhranná tyč
        if velicina == :Wx
            a = getn(:a)
            if getv(:b) === missing
                return a^3/6, "a³/6"
            else
                b = getn(:b)
                return a*b^2/6, "a*b²/6"
            end
        elseif velicina == :Wy
            a = getn(:a)
            if getv(:b) === missing
                return a^3/6, "a³/6"
            else
                b = getn(:b)
                return b*a^2/6, "b*a²/6"
            end
        elseif velicina == :Wo
            if isrot(angle, 0) || isrot(angle, pi)
                Wo, Wo_str = profilyvlcnWo(tvar1, :Wx)
            elseif isrot(angle, pi/2) || isrot(angle, 3*pi/2)
                Wo, Wo_str = profilyvlcnWo(tvar1, :Wy)
            else
                I = StrojniSoucasti.profilyvlcnI(tvar1, :I, angle)[1]
                eo = StrojniSoucasti.profilyvlcneo(tvar1, :eo, angle)[1]
                Wo, Wo_str = I / eo, "I / eo"
            end
            return Wo, Wo_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Šestihranná tyč (0rad lezi na plose)
    # s = vzdalenost mezi protilehlymi stranami sestihranu.
    elseif info == "6HR" # Šestihranná tyč
        if velicina == :Wx
            s = getn(:s)
            return 5*sqrt(3)/72*s^3, "5√3/72*s³"
        elseif velicina == :Wy
            s = getn(:s)
            return 5/48*s^3, "5/48*s³"
        elseif velicina == :Wo
            s = getn(:s)
            if isrot(angle, 0) || isrot(angle, 2*pi/6) || isrot(angle, 4*pi/6) || isrot(angle, 6*pi/6) || isrot(angle, 8*pi/6) || isrot(angle, 10*pi/6) || isrot(angle, 12*pi/6)
                Wo, Wo_str = profilyvlcnWo(tvar1, :Wx)
            elseif isrot(angle, pi/6) || isrot(angle, 3*pi/6) || isrot(angle, 5*pi/6) || isrot(angle, 7*pi/6) || isrot(angle, 9*pi/6) || isrot(angle, 11*pi/6)
                Wo, Wo_str = profilyvlcnWo(tvar1, :Wy)
            else
                I = StrojniSoucasti.profilyvlcnI(tvar1, :I, angle)[1]
                eo = StrojniSoucasti.profilyvlcneo(tvar1, :eo, angle)[1]
                Wo, Wo_str = I / eo, "I / eo"
            end
            return Wo, Wo_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Trubka čtyřhranná
    elseif info == "TR4HR" # Trubka čtyřhranná
        if velicina == :Wx
            a, b, t = getn(:a), getn(:b), getn(:t)
            return (a*b^2/6) - ((a-2t)*(b-2t)^2/6), "(a*b²/6)-((a-2t)*(b-2t)²/6)"
        elseif velicina == :Wy
            a, b, t = getn(:a), getn(:b), getn(:t)
            return (b*a^2/6) - ((b-2t)*(a-2t)^2/6), "(b*a²/6)-((b-2t)*(a-2t)²/6)"
        elseif velicina == :Wo
            if isrot(angle, 0) || isrot(angle, pi)
                Wo, Wo_str = profilyvlcnWo(tvar1, :Wx)
            elseif isrot(angle, pi/2) || isrot(angle, 3*pi/2)
                Wo, Wo_str = profilyvlcnWo(tvar1, :Wy)
            else
                I = StrojniSoucasti.profilyvlcnI(tvar1, :I, angle)[1]
                eo = StrojniSoucasti.profilyvlcneo(tvar1, :eo, angle)[1]
                Wo, Wo_str = I / eo, "I / eo"
            end
            return Wo, Wo_str
        else
            error("Nepodporovana velicina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # neznámý tvar
    else
        error("Neznámý tvar: $info pro veličinu $velicina")
    end

end
