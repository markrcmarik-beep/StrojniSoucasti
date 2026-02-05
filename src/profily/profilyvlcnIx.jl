## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-02-01
## Funkce: profilyvlcnIx()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnIx.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnIx(vstupni_promenne)
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

function profilyvlcnIx(tvar1::Dict, velicina::Symbol, natoceni=0)
    info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrátí hodnotu nebo missing

    # Podpora :Iy delegací na :Ix (rotace o 90°)
    if velicina == :Iy
        return profilyvlcnIx(tvar1, :Ix, natoceni + pi/2)
    end

    # -----------------------------------------------------------
        # Plochá tyč nebo obdélník
        if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
            if velicina == :Ixy
                Ixy = 0
                Ixy_str = "0"
                return Ixy, Ixy_str
            elseif velicina == :Ix
                a, b = getv(:a), getv(:b)
                if natoceni in (0, pi, 2*pi)
                    return a*b^3/12, "a*b³/12"
                elseif natoceni in (pi/2, 3*pi/2)
                    return b*a^3/12, "b*a³/12"
                else
                    error("Neplatné natočení profilu: $info $natoceni rad pro $velicina")
                end
            end
        # -----------------------------------------------------------
        # Kruhová tyč
        elseif info == "KR" # Kruhová tyč
            if velicina == :Ixy
                Ixy = 0
                Ixy_str = "0"
                return Ixy, Ixy_str
            elseif velicina == :Ix
                D = getv(:D)
                return pi/64*D^4, "π/64*D⁴"
            end
        # -----------------------------------------------------------
        # Trubka kruhová
        elseif info == "TRKR" # Trubka kruhová
            if velicina == :Ixy
                Ixy = 0
                Ixy_str = "0"
                return Ixy, Ixy_str
            elseif velicina == :Ix
                D, d = getv(:D), getv(:d)
                return pi/64*(D^4 - d^4), "π/64*(D⁴ - d⁴)"
            end
        # -----------------------------------------------------------
        # Čtyřhranná tyč
        elseif info == "4HR" # Čtyřhranná tyč
            if velicina == :Ixy
                Ixy = 0
                Ixy_str = "0"
                return Ixy, Ixy_str
            elseif velicina == :Ix
                a = getv(:a)
                if natoceni in (0, pi/2, pi, 3*pi/2, 2*pi)
                return a^4/12, "a⁴/12"
                else
                    error("Neplatné natočení profilu: $info $natoceni rad pro $velicina")
                end
            end
        # -----------------------------------------------------------
        # Šestihranná tyč
        elseif info == "6HR" # Šestihranná tyč (0rad ležící na ploše)
            if velicina == :Ixy
                Ixy = 0
                Ixy_str = "0"
                return Ixy, Ixy_str
            elseif velicina == :Ix
                s = getv(:s)
                if natoceni in (0, 2*pi/6, 4*pi/6, 6*pi/6, 8*pi/6, 10*pi/6, 12*pi/6)
                    return 5*sqrt(3)/144*s^4, "5√3/144*s⁴"
                elseif natoceni in (pi/6, 3*pi/6, 5*pi/6, 7*pi/6, 9*pi/6, 11*pi/6)
                    return 5/96*s^4, "5/96*s⁴"
                else
                    error("Neplatné natočení profilu: $info $natoceni rad pro $velicina")
                end
            end
        # -----------------------------------------------------------
        # Trubka čtyřhranná
        elseif info == "TR4HR" # Trubka čtyřhranná
            if velicina == :Ixy
                Ixy = 0
                Ixy_str = "0"
                return Ixy, Ixy_str
            elseif velicina == :Ix
                a, b, t = getv(:a), getv(:b), getv(:t)
                return (a*b^3/12) - ((a-2t)*(b-2t)^3/12), "(a*b³/12)-((a-2t)*(b-2t)³/12)"
            end
        # -----------------------------------------------------------
        # neznámý tvar
        else
            error("Neznámý tvar: $info pro veličinu $velicina")
        end

end
