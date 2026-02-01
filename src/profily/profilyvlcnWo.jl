## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-02-01
## Funkce: profilyvlcnWo()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnWo.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnWo(vstupni_promenne)
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

function profilyvlcnWo(tvar1::Dict, velicina::Symbol, natoceni=0)
    info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrátí hodnotu nebo missing

    # -----------------------------------------------------------
    # Plochá tyč nebo obdélník
    if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
        a, b = getv(:a), getv(:b)
        if natoceni in (0, pi, 2*pi)
            return a*b^2/6, "a*b²/6"
        elseif natoceni in (pi/2, 3*pi/2)
            return b*a^2/6, "b*a²/6"
        else
            error("Neplatné natočení profilu: $natoceni rad pro $velicina")
        end
    # -----------------------------------------------------------
    # Kruhová tyč
    elseif info == "KR" # Kruhová tyč
        D = getv(:D)
        return pi/32*D^3, "π/32*D³"
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        D, d = getv(:D), getv(:d)
        return pi/32*(D^4 - d^4)/D, "π/32*(D⁴ - d⁴)/D"
    # -----------------------------------------------------------
    # Čtyřhranná tyč
    elseif info == "4HR" # Čtyřhranná tyč
        a = getv(:a)
        if natoceni in (0, pi/2, pi, 3*pi/2, 2*pi)
            return a^3/6, "a³/6"
        else
            error("Neplatné natočení profilu: $natoceni rad pro $velicina")
        end
    # -----------------------------------------------------------
    # Šestihranná tyč
    elseif info == "6HR" # Šestihranná tyč
        s = getv(:s)
        if natoceni in (0, 2*pi/6, 4*pi/6, 6*pi/6, 8*pi/6, 10*pi/6, 12*pi/6)
            return 5*sqrt(3)/72*s^3, "5√3/72*s³"
        elseif natoceni in (pi/6, 3*pi/6, 5*pi/6, 7*pi/6, 9*pi/6, 11*pi/6)
            return 5/48*s^3, "5/48*s³"
        else
            error("Neplatné natočení profilu: $natoceni rad pro $velicina")
        end
    # -----------------------------------------------------------
    # Trubka čtyřhranná
    elseif info == "TR4HR" # Trubka čtyřhranná
        a, b, t = getv(:a), getv(:b), getv(:t)
        if natoceni in (0, pi/2, pi, 3*pi/2, 2*pi)
            return (a*b^2/6) - ((a-2t)*(b-2t)^2/6), "(a*b²/6)-((a-2t)*(b-2t)²/6)"
        else
            error("Neplatné natočení profilu: $natoceni rad pro $velicina")
        end
    # -----------------------------------------------------------
    # neznámý tvar
    else
        error("Neznámý tvar: $info pro veličinu $velicina")
    end

end
