## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-01-31
## Funkce: profilyvlcnS()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnS.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnS(vstupni_promenne)
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

function profilyvlcnS(tvar1::Dict)
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
            println("_______________________________________________________________________________________________________________________________________________________________________")
            error("Zaoblení R není implementováno.")
            R = getv(:R)
            println("a: ", a)
            println("b: ", b)
            println("R: ", ustrip(R))
            Sr = StrojniSoucasti.hrana(string("R",ustrip(R)))
            println("Sr: ", Sr)
            println("Sr before unit: ", Sr[:S])
            Sr = Sr[:S] * u"mm^2"
            println("Sr after unit: ", Sr)
            return a*b-4*Sr, "a*b"
            #return a*b, "a*b"
        end
    # -----------------------------------------------------------
    # Kruhová tyč
    elseif info == "KR" # Kruhová tyč
        D = getv(:D)
        return π*(D/2)^2, "π*(D/2)²"
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        D, d = getv(:D), getv(:d)
        return π*(D^2 - d^2)/4, "π*(D² - d²)/4"
    # -----------------------------------------------------------
    # Čtyřhranná tyč
    elseif info == "4HR" # Čtyřhranná tyč
        a = getv(:a)
        return a^2, "a²"
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
