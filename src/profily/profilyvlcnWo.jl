## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypočet průřezového modulu v ohybu Wo pro různé tvary dle zkratky označení.
# ver: 2026-05-21
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
    getn(k::Symbol) = to_num(getv(k), k)
    # -----------------------------------------------------------
    # Plochá tyč nebo obdélník
    if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
        a, b = getn(:a), getn(:b)
        if natoceni in (0, pi, 2*pi)
            return a*b^2/6, "a*b²/6"
        elseif natoceni in (pi/2, 3*pi/2)
            return b*a^2/6, "b*a²/6"
        else
            Ix_hod, Ix_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, natoceni)
            Iy_hod, Iy_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Iy, natoceni)
            Ixy_hod, Ixy_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Ixy, natoceni)
            Wo_hod = (Ix_hod*Iy_hod - Ixy_hod^2) / (Iy_hod*sqrt(Ix_hod^2 + Iy_hod^2 - 2*Ixy_hod^2) - Ix_hod*sqrt(Ix_hod^2 + Iy_hod^2 - 2*Ixy_hod^2))
            Wo_str = "(Ix*Iy - Ixy^2) / (Iy*sqrt(Ix^2 + Iy^2 - 2*Ixy^2) - Ix*sqrt(Ix^2 + Iy^2 - 2*Ixy^2))"
            return Wo_hod, Wo_str # Vrátí hodnotu a vzorec pro průřezový modul v ohybu Wo (natočený o natoceni)
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
        if natoceni in (0, pi/2, pi, 3*pi/2, 2*pi)
            return a^3/6, "a³/6"
        else
            Ix_hod, Ix_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, natoceni)
            Iy_hod, Iy_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Iy, natoceni)
            Ixy_hod, Ixy_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Ixy, natoceni)
            Wo_hod = (Ix_hod*Iy_hod - Ixy_hod^2) / (Iy_hod*sqrt(Ix_hod^2 + Iy_hod^2 - 2*Ixy_hod^2) - Ix_hod*sqrt(Ix_hod^2 + Iy_hod^2 - 2*Ixy_hod^2))
            Wo_str = "(Ix*Iy - Ixy^2) / (Iy*sqrt(Ix^2 + Iy^2 - 2*Ixy^2) - Ix*sqrt(Ix^2 + Iy^2 - 2*Ixy^2))"
            return Wo_hod, Wo_str # Vrátí hodnotu a vzorec pro průřezový modul v ohybu Wo (natočený o natoceni)
        end
    # -----------------------------------------------------------
    # Šestihranná tyč (0rad lezi na plose)
    elseif info == "6HR" # Šestihranná tyč
        s = getn(:s)
        if natoceni in (0, 2*pi/6, 4*pi/6, 6*pi/6, 8*pi/6, 10*pi/6, 12*pi/6)
            return 5*sqrt(3)/72*s^3, "5√3/72*s³"
        elseif natoceni in (pi/6, 3*pi/6, 5*pi/6, 7*pi/6, 9*pi/6, 11*pi/6)
            return 5/48*s^3, "5/48*s³"
        else
            Ix_hod, Ix_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, natoceni)
            Iy_hod, Iy_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Iy, natoceni)
            Ixy_hod, Ixy_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Ixy, natoceni)
            Wo_hod = (Ix_hod*Iy_hod - Ixy_hod^2) / (Iy_hod*sqrt(Ix_hod^2 + Iy_hod^2 - 2*Ixy_hod^2) - Ix_hod*sqrt(Ix_hod^2 + Iy_hod^2 - 2*Ixy_hod^2))
            Wo_str = "(Ix*Iy - Ixy^2) / (Iy*sqrt(Ix^2 + Iy^2 - 2*Ixy^2) - Ix*sqrt(Ix^2 + Iy^2 - 2*Ixy^2))"
            return Wo_hod, Wo_str # Vrátí hodnotu a vzorec pro průřezový modul v ohybu Wo (natočený o natoceni)
        end
    # -----------------------------------------------------------
    # Trubka čtyřhranná
    elseif info == "TR4HR" # Trubka čtyřhranná
        a, b, t = getn(:a), getn(:b), getn(:t)
        if natoceni in (0, pi/2, pi, 3*pi/2, 2*pi)
            return (a*b^2/6) - ((a-2t)*(b-2t)^2/6), "(a*b²/6)-((a-2t)*(b-2t)²/6)"
        else
            Ix_hod, Ix_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, natoceni)
            Iy_hod, Iy_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Iy, natoceni)
            Ixy_hod, Ixy_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Ixy, natoceni)
            Wo_hod = (Ix_hod*Iy_hod - Ixy_hod^2) / (Iy_hod*sqrt(Ix_hod^2 + Iy_hod^2 - 2*Ixy_hod^2) - Ix_hod*sqrt(Ix_hod^2 + Iy_hod^2 - 2*Ixy_hod^2))
            Wo_str = "(Ix*Iy - Ixy^2) / (Iy*sqrt(Ix^2 + Iy^2 - 2*Ixy^2) - Ix*sqrt(Ix^2 + Iy^2 - 2*Ixy^2))"
            return Wo_hod, Wo_str # Vrátí hodnotu a vzorec pro průřezový modul v ohybu Wo (natočený o natoceni)
        end
    # -----------------------------------------------------------
    # neznámý tvar
    else
        error("Neznámý tvar: $info pro veličinu $velicina")
    end

end
