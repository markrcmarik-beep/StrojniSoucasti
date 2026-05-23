## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypočet průřezového modulu v ohybu Wo pro různé tvary dle zkratky označení.
# ver: 2026-05-23
## Funkce: profilyvlcnWo()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnWo.jl
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
        a, b = getn(:a), getn(:b)
        if isrot(angle, 0) || isrot(angle, pi) || isrot(angle, 2*pi)
            return a*b^2/6, "a*b²/6"
        elseif isrot(angle, pi/2) || isrot(angle, 3*pi/2)
            return b*a^2/6, "b*a²/6"
        else
            Ix_hod, _ = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, angle)
            ymax = 0.5*(abs(a*sin(angle)) + abs(b*cos(angle)))
            ymax > 0 || error("Nelze urcit ymax pro PLO/OBD.") # Kontrola (teoreticky vždy splneno)
            return Ix_hod / ymax, "Ix / ymax, kde ymax = (|a*sin(angle)| + |b*cos(angle)|)/2"
        end
    # -----------------------------------------------------------
    # Kruhová tyč
    elseif info == "KR" # Kruhová tyč
        D = getn(:D)
        return pi/32*D^3, "π/32*D³"
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        D, d = getn(:D), getn(:d)
        return pi/32*(D^4 - d^4)/D, "π/32*(D⁴ - d⁴)/D"
    # -----------------------------------------------------------
    # Čtyřhranná tyč
    elseif info == "4HR" # Čtyřhranná tyč
        a = getn(:a)
        if isrot(angle, 0) || isrot(angle, pi/2) || isrot(angle, pi) || isrot(angle, 3*pi/2) || isrot(angle, 2*pi)
            return a^3/6, "a³/6"
        else
            Ix_hod, _ = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, angle)
            ymax = 0.5*a*(abs(sin(angle)) + abs(cos(angle)))
            ymax > 0 || error("Nelze urcit ymax pro 4HR.") # Kontrola (teoreticky vždy splneno)
            return Ix_hod / ymax, "Ix / ymax, kde ymax = a*(|sin(angle)| + |cos(angle)|)/2"
        end
    # -----------------------------------------------------------
    # Šestihranná tyč (0rad lezi na plose)
    # s = vzdalenost mezi protilehlymi stranami sestihranu.
    elseif info == "6HR" # Šestihranná tyč
        s = getn(:s)
        if isrot(angle, 0) || isrot(angle, 2*pi/6) || isrot(angle, 4*pi/6) || isrot(angle, 6*pi/6) || isrot(angle, 8*pi/6) || isrot(angle, 10*pi/6) || isrot(angle, 12*pi/6)
            return 5*sqrt(3)/72*s^3, "5√3/72*s³"
        elseif isrot(angle, pi/6) || isrot(angle, 3*pi/6) || isrot(angle, 5*pi/6) || isrot(angle, 7*pi/6) || isrot(angle, 9*pi/6) || isrot(angle, 11*pi/6)
            return 5/48*s^3, "5/48*s³"
        else
            # Pro regularni sestihran je Ix konstantni, Wo urci krajni vlakno ymax.
            Ix_hod = 5*sqrt(3)/144*s^4
            a = s/sqrt(3)
            vrcholy = (
                ( a,    0.0),
                ( a/2,  s/2),
                (-a/2,  s/2),
                (-a,    0.0),
                (-a/2, -s/2),
                ( a/2, -s/2),
            )
            ymax = 0.0
            for (x, y) in vrcholy
                yrot = x*sin(angle) + y*cos(angle)
                ymax = max(ymax, abs(yrot))
            end
            ymax > 0 || error("Nelze urcit ymax pro 6HR.") # Kontrola (teoreticky vždy splneno)
            return Ix_hod / ymax, "Ix / ymax, kde Ix = 5*sqrt(3)/144*s^4 a ymax = max_i|x_i*sin(angle) + y_i*cos(angle)|"
        end
    # -----------------------------------------------------------
    # Trubka čtyřhranná
    elseif info == "TR4HR" # Trubka čtyřhranná
        a, b, t = getn(:a), getn(:b), getn(:t)
        if isrot(angle, 0) || isrot(angle, pi/2) || isrot(angle, pi) || isrot(angle, 3*pi/2) || isrot(angle, 2*pi)
            return (a*b^2/6) - ((a-2t)*(b-2t)^2/6), "(a*b²/6)-((a-2t)*(b-2t)²/6)"
        else
            Ix_hod, _ = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, angle)
            ymax = 0.5*(abs(a*sin(angle)) + abs(b*cos(angle)))
            ymax > 0 || error("Nelze urcit ymax pro TR4HR.") # Kontrola (teoreticky vždy splneno)
            return Ix_hod / ymax, "Ix / ymax, kde ymax = (|a*sin(angle)| + |b*cos(angle)|)/2"
        end
    # -----------------------------------------------------------
    # neznámý tvar
    else
        error("Neznámý tvar: $info pro veličinu $velicina")
    end

end
