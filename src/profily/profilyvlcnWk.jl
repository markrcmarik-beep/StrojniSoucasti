## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-02-01
## Funkce: profilyvlcnWk()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnWk.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnWk(vstupni_promenne)
## Vstupní proměnné:
#
## Výstupní proměnné:
#
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
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
        D = getv(:D)
        return pi/16*D^3, "π/16*D³"
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        D, d = getv(:D), getv(:d)
        return pi/16*(D^4 - d^4)/D, "π/16*(D⁴ - d⁴)/D"
    # -----------------------------------------------------------
    # Čtyřhranná tyč
    elseif info == "4HR" # Čtyřhranná tyč
        a = getv(:a)
        return 0.208*a^3, "0.208*a³"
    # -----------------------------------------------------------
    # Plochá tyč nebo obdélník
    elseif info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
        a, b = getv(:a), getv(:b)
        return a*b^3/3*(1 - 0.63*b/a + 0.052*(b/a)^5), 
            "a*b³/3*(1 - 0.63*b/a + 0.052*(b/a)^5)"
    # -----------------------------------------------------------
    # Šestihranná tyč
    elseif info == "6HR" # Šestihranná tyč
        s = getv(:s)
        return 0.17*s^3, "0.17*s³" # ??????????????????
    # -----------------------------------------------------------
    # neznámý tvar
    else
        error("Neznámý tvar: $info pro veličinu $velicina")
    end

end
