## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypočet plochy pro různé tvary dle zkratky označeni.
# ver: 2026-02-27
## Funkce: profilyvlcnS()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnS.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnS(vstupni_promenne)
## Vstupní proměnné:
# tvar1 - slovník (Dict) s informacemi o tvaru, např.:
#    Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm")
#    Dict("info" => "KR", "D" => 30u"mm")
#    Dict("info" => "TRKR", "D" => 30u"mm", "d" => 20u"mm")
#    Dict("info" => "4HR", "a" => 20u"mm")
#    Dict("info" => "6HR", "s" => 20u"mm")
#    Dict("info" => "TR4HR", "a" => 20u"mm", "b" => 10u"mm", "t" => 4u"mm")
# velicina - hledaná veličina: 
#    :S - Plocha průřezu [mm²]
## Výstupní proměnné:
# vystupni_promenne - Struktura (Dict) s rozměry profilu a
#   případně i s vypočtenými vlastnostmi. V tomto případě plocha S.
## Použité balíčky:
# Unitful
## Použité uživatelské funkce:
# StrojniSoucasti.hrana
## Příklad:
# tvar = Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm") # Definice tvaru plošné tyče o rozměrech 20 mm x 10 mm
# S, vzorec = profilyvlcnS(tvar, :S) # Plocha plošné tyče
#   vrátí plochu a použitý vzorec
###############################################################
## Použité proměnné vnitřní:
#
using Unitful

function profilyvlcnS(tvar1::Dict, velicina::Symbol)
    info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrátí hodnotu nebo missing

    # -----------------------------------------------------------
    # Plochá tyč nebo obdélník
    if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
        a, b = getv(:a), getv(:b)
        if getv(:R) === missing
            return a*b, "a*b"
        else
            R = getv(:R)
            Sr = StrojniSoucasti.hrana(string("R",ustrip(u"mm",R)))
            Sr = Sr[:S] * u"mm^2"
            return a*b-4*Sr, "a*b - 4*S(R)"
        end
    # -----------------------------------------------------------
    # Kruhová tyč
    elseif info == "KR" # Kruhová tyč
        D = getv(:D)
        return pi*(D/2)^2, "π*(D/2)²"
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        D, d = getv(:D), getv(:d)
        return pi*(D^2 - d^2)/4, "π*(D² - d²)/4"
    # -----------------------------------------------------------
    # Čtyřhranná tyč
    elseif info == "4HR" # Čtyřhranná tyč
        a = getv(:a)
        if getv(:R) === missing
            return a^2, "a²"
        else
            R = getv(:R)
            Sr = StrojniSoucasti.hrana(string("R",ustrip(u"mm",R)))
            Sr = Sr[:S] * u"mm^2"
            return a^2-4*Sr, "a² - 4*S(R)"
        end
    # -----------------------------------------------------------
    # Šestihranná tyč
    elseif info == "6HR" # Šestihranná tyč
        s = getv(:s)
        return (3/4)*s^2, "3/4*s²"
    # -----------------------------------------------------------
    # Trubka čtyřhranná
    elseif info == "TR4HR" # Trubka čtyřhranná
        a, b, t = getv(:a), getv(:b), getv(:t)
        return a*b - (a-2t)*(b-2t), "a*b - (a-2t)*(b-2t)"
    # -----------------------------------------------------------
    # neznámý tvar
    else
        error("Neznámý tvar: $info pro veličinu $velicina")
    end

end
