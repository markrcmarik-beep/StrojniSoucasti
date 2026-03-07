## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypočet průřezový modul v krutu pro různé tvary dle zkratky označeni.
# ver: 2026-02-27
## Funkce: profilyvlcnWk()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnWk.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnWk(vstupni_promenne)
## Vstupní proměnné:
# tvar1 - slovník (Dict) s informacemi o tvaru, např.:
#    Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm")
#    Dict("info" => "KR", "D" => 30u"mm")
#    Dict("info" => "TRKR", "D" => 30u"mm", "d" => 20u"mm")
#    Dict("info" => "4HR", "a" => 20u"mm")
#    Dict("info" => "6HR", "s" => 20u"mm")
#    Dict("info" => "TR4HR", "a" => 20u"mm", "b" => 10u"mm", "t" => 4u"mm")
# velicina - hledaná veličina: 
#    :Wk - Průřezový modul v krutu [mm³]
## Výstupní proměnné:
# vystupni_promenne - Struktura (Dict) s rozměry profilu a
# případně i s vypočtenými vlastnostmi. V tomto případě 
# průřezový modul v krutu Wk.
## Použité balíčky:
# Unitful
## Použité uživatelské funkce:
#
## Příklad:
# tvar = Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm") # Definice 
#   tvaru plošné tyče o rozměrech 20 mm x 10 mm
# Wk, vzorec = profilyvlcnWk(tvar, :Wk) # Průřezový modul v krutu pro 
#   plošnou tyč vrátí Wk a použitý vzorec
###############################################################
## Použité proměnné vnitřní:
#
using Unitful

function profilyvlcnWk(tvar1::Dict, velicina::Symbol)
    info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrátí hodnotu nebo missing

    # -----------------------------------------------------------
    # Kruhová tyč
    if info == "KR" # Kruhová tyč
        D = getv(:D) # Průměr
        return pi/16*D^3, "π/16*D³"
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        D, d = getv(:D), getv(:d) # Vnější a vnitřní průměr
        return pi/16*(D^4 - d^4)/D, "π/16*(D⁴ - d⁴)/D"
    # -----------------------------------------------------------
    # Čtyřhranná tyč
    elseif info == "4HR" # Čtyřhranná tyč
        a = getv(:a) # Strana
        return 0.208*a^3, "0.208*a³"
    # -----------------------------------------------------------
    # Plochá tyč nebo obdélník
    elseif info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
        a, b = getv(:a), getv(:b) # Šířka a výška
        return a*b^3/3*(1 - 0.63*b/a + 0.052*(b/a)^5), 
            "a*b³/3*(1 - 0.63*b/a + 0.052*(b/a)^5)"
    # -----------------------------------------------------------
    # Šestihranná tyč
    elseif info == "6HR" # Šestihranná tyč
        s = getv(:s) # Strana
        return 0.17*s^3, "0.17*s³" # ??????????????????
    # -----------------------------------------------------------
    # neznámý tvar
    else
        error("Neznámý tvar: $info pro veličinu $velicina")
    end

end
