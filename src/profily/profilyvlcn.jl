## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vyřeší mechanické veličiny pro různé tvary dle zkratky označení.
# ver: 2026-01-31
## Funkce: profilyvlcn()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcn.jl
#
## Vzor:
## (rozmer, text) = profilyvlcn(tvar::Dict, velicina::Symbol; natoceni=0)
## Vstupní proměnné:
# tvar – slovník (Dict) s informacemi o tvaru, např.:
#    Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm")
# velicina – hledaná veličina: 
#       S - Plocha průřezu [mm²]
#       Ip - Polární moment [mm⁴]
#       Wk - Průřezový modul v krutu [mm³]
#       Ix - Kvadratický moment [mm⁴]
#       Imin - Kvadratický moment minimální [mm⁴]
#       Wo - Průřezový modul v ohybu [mm³]
# natoceni – úhel natočení [rad], volitelný (parametr pro Ix a Wo)
## Výstupní proměnné:
# rozmer – hodnota veličiny s jednotkami (Unitful)
# text – vzorec použitý pro výpočet (string)
## Použité balíčky
# Unitful
## Použité uživatelské funkce:
#
## Příklad:
# tvar = Dict("info" => "KR", "D" => 30u"mm") # Definice tvaru kruhové tyče o průměru 30 mm
# S, vzorec = profilyvlcn(tvar, :S) # Plocha kruhové tyče
#   vrátí plochu a použitý vzorec
#   => S = 706.8583470577034 mm², vzorec = "π*(D/2)²"
#
###############################################################
## Použité proměnné vnitřní:
#

using Unitful
const π = pi # Pro zkrácení zápisu π místo pi v kódu

function profilyvlcn(tvar1::Dict, velicina::Symbol; natoceni=0)
    info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrátí hodnotu nebo missing
    # -----------------------------------------------------------
    # S - Plocha [mm²]
    # -----------------------------------------------------------
    if velicina == :S  # Plocha [mm²]
        # -----------------------------------------------------------
        # Plochá tyč nebo obdélník
        if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
            a, b = getv(:a), getv(:b)
            if getv(:R) === missing
                return a*b, "a*b"
            else
                R = getv(:R)
                return a*b, "a*b"
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
    # -----------------------------------------------------------
    # Ip - Polární moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Ip  # Polární moment [mm⁴]
        # -----------------------------------------------------------
        # Plochá tyč nebo obdélník
        if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
            a, b = getv(:a), getv(:b)
            if a >= b
                if 1 <= (a/b) && (a/b) <= 10
                    return a*b^3 *(1/3 - 0.21*b/a*(1 - b^4/12/a^4)), 
                        "a*b³ *(1/3 - 0.21*b/a*(1 - b⁴/12/a⁴))" # Torzní konstanta
                    #return a*b^3/3*(1 - 0.63*b/a + 0.052*(b/a)^5), 
                        #"a*b³/3*(1 - 0.63*b/a + 0.052*(b/a)^5)"
                elseif (a/b) > 10
                    return a*b^3 /3, "a*b³ /3" # Torzní konstanta
                else
                    error("Nedefinovaný výpočet. Tvar: $info pro veličinu: $velicina")
                end
            else
                if 1 <= (b/a) && (b/a) <= 10
                    return b*a^3 *(1/3 - 0.21*a/b*(1 - a^4/12/b^4)), 
                        "b*a³ *(1/3 - 0.21*a/b*(1 - a⁴/12/b⁴))" # Torzní konstanta
                elseif (b/a) > 10
                    return b*a^3 /3, "b*a³ /3" # Torzní konstanta
                else
                    error("Neznámý výpočet. Tvar: $info pro veličinu: $velicina")
                end
            end
        # -----------------------------------------------------------
        # Kruhová tyč
        elseif info == "KR" # Kruhová tyč
            D = getv(:D)
            return π/32*D^4, "π/32*D⁴"
        # -----------------------------------------------------------
        # Trubka kruhová
        elseif info == "TRKR" # Trubka kruhová
            D, d = getv(:D), getv(:d)
            return π/32*(D^4 - d^4), "π/32*(D⁴ - d⁴)"
        # -----------------------------------------------------------
        # Čtyřhranná tyč
        elseif info == "4HR" # Čtyřhranná tyč
            a = getv(:a)
            return 0.1406*a^4, "0.1406*a⁴" # Torzní konstanta
        # -----------------------------------------------------------
        # Trubka čtyřhranná
        elseif info == "TR4HR"
            a, b, t = getv(:a), getv(:b), getv(:t)
            if min(a,b)*0.1 >= t
                return 2*(a-t)^2*(b-t)^2*t/((a-t)+(b-t)), 
                    "2*(a-t)²*(b-t)²*t/((a-t)+(b-t))" # ideálně t≤0.05min⁡(a,b) t≤0.05min(a,b) při t>0.1min⁡(a,b) t>0.1min(a,b) už chyba rychle roste
            elseif min(a,b)*0.5 > t
                return 2*(a-t)^2*(b-t)^2*t/((a-t)+(b-t))+2/3*(a+b)*t^3, 
                    "2*(a-t)²*(b-t)²*t/((a-t)+(b-t))+2/3*(a+b)*t³"
            else
                Ip_num=StrojniSoucasti.torsion_J_TR4HR_numeric(ustrip(u"mm", a)
                    , ustrip(u"mm", b), ustrip(u"mm", t),
                    nx=150, ny=150, tol=1e-2, maxiter=50000) # numerické řeš.
                if isa(Ip_num, Number) && !isnan(Ip_num)
                    return Ip_num*u"mm^4", "num. řešení"
                else
                    error("Nedefinovaný výpočet. Tvar: $info pro veličinu: $velicina. 
                        Selhalo numerické řešení. 'a'=$a 'b'=$b 't'=$t")
                end
            end
        # -----------------------------------------------------------
        # Šestihranná tyč
        elseif info == "6HR" # Šestihranná tyč
            s = getv(:s)
            return 0.133*sqrt(3)/2*s^4, "0.133*sqrt(3)/2*s⁴"
            #return 0.154*s^4, "0.154*s⁴" # Torzní konstanta
        # -----------------------------------------------------------
        # neznámý tvar
        else
            error("Neznámý tvar: $info pro veličinu $velicina")
        end
    # -----------------------------------------------------------
    # Wk - Modul v krutu [mm³]
    # -----------------------------------------------------------
    elseif velicina == :Wk  # Modul v krutu [mm³]
        # -----------------------------------------------------------
        # Kruhová tyč
        if info == "KR" # Kruhová tyč
            D = getv(:D)
            return π/16*D^3, "π/16*D³"
        # -----------------------------------------------------------
        # Trubka kruhová
        elseif info == "TRKR" # Trubka kruhová
            D, d = getv(:D), getv(:d)
            return π/16*(D^4 - d^4)/D, "π/16*(D⁴ - d⁴)/D"
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
    # -----------------------------------------------------------
    # Ix - Kvadratický moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Ix  # Kvadratický moment [mm⁴]
        # -----------------------------------------------------------
        # Plochá tyč nebo obdélník
        if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
            a, b = getv(:a), getv(:b)
            if natoceni in (0, π, 2*π)
                return a*b^3/12, "a*b³/12"
            elseif natoceni in (π/2, 3*π/2)
                return b*a^3/12, "b*a³/12"
            else
                error("Neplatné natočení profilu: $natoceni rad pro $velicina")
            end
        # -----------------------------------------------------------
        # Kruhová tyč
        elseif info == "KR" # Kruhová tyč
            D = getv(:D)
            return π/64*D^4, "π/64*D⁴"
        # -----------------------------------------------------------
        # Trubka kruhová
        elseif info == "TRKR" # Trubka kruhová
            D, d = getv(:D), getv(:d)
            return π/64*(D^4 - d^4), "π/64*(D⁴ - d⁴)"
        # -----------------------------------------------------------
        # Čtyřhranná tyč
        elseif info == "4HR" # Čtyřhranná tyč
            a = getv(:a)
            if natoceni in (0, π/2, π, 3*π/2, 2*π)
                return a^4/12, "a⁴/12"
            else
                error("Neplatné natočení profilu: $natoceni rad pro $velicina")
            end
        # -----------------------------------------------------------
        # Šestihranná tyč
        elseif info == "6HR" # Šestihranná tyč (0rad ležící na ploše)
            s = getv(:s)
            if natoceni in (0, 2*π/6, 4*π/6, 6*π/6, 8*π/6, 10*π/6, 12*π/6)
                return 5*sqrt(3)/144*s^4, "5√3/144*s⁴"
            elseif natoceni in (π/6, 3*π/6, 5*π/6, 7*π/6, 9*π/6, 11*π/6)
                return 5/96*s^4, "5/96*s⁴"
            else
                error("Neplatné natočení profilu: $natoceni rad pro $velicina")
            end
        # -----------------------------------------------------------
        # Trubka čtyřhranná
        elseif info == "TR4HR" # Trubka čtyřhranná
            a, b, t = getv(:a), getv(:b), getv(:t)
            return (a*b^3/12) - ((a-2t)*(b-2t)^3/12), "(a*b³/12)-((a-2t)*(b-2t)³/12)"
        # -----------------------------------------------------------
        # neznámý tvar
        else
            error("Neznámý tvar: $info pro veličinu $velicina")
        end
    # -----------------------------------------------------------
    # Imin - Kvadratický moment minimální [mm⁴] ("Imin = (Ix + Iy)/2 - √( ((Ix - Iy)/2)² + Ixy² )")
    # -----------------------------------------------------------
    elseif velicina == :Imin  # Kvadratický moment mimimální [mm⁴]
        # -----------------------------------------------------------
        # Plochá tyč nebo obdélník
        if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
            Ix, Ix_str = StrojniSoucasti.profilyvlcn(tvar1, :Ix)
            Iy, Iy_str = StrojniSoucasti.profilyvlcn(tvar1, :Ix, natoceni=π/2)
            Ixy_str = "0"
            Ixy = 0u"mm^4" # Pro obdélník je Ixy=0
            Imin_val = (Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )
            #function Imin_val_str(Ix_str, Iy_str, Ixy_str)
            #    return "($Ix_str + $Iy_str)/2 - √( ( ($Ix_str - $Iy_str)/2 )² + $Ixy_str ² )"
            #end
            return Imin_val, "-sqrt((1//4)*((-(1//12)*(a^3)*b + (1//12)*a*(b^3))^2)) + (1//2)*((1//12)*(a^3)*b + (1//12)*a*(b^3))"
        # -----------------------------------------------------------
        # Kruhová tyč
        elseif info == "KR" # Kruhová tyč
            D = getv(:D)
            return π/64*D^4, "π/64*D⁴"
        # -----------------------------------------------------------
        # Trubka kruhová
        elseif info == "TRKR" # Trubka kruhová
            D, d = getv(:D), getv(:d)
            return π/64*(D^4 - d^4), "π/64*(D⁴ - d⁴)"
        else
            error("Neznámý tvar: $info pro veličinu $velicina")
        end
    # -----------------------------------------------------------
    # Wo - Průřezový modul v ohybu [mm³]
    # -----------------------------------------------------------
    elseif velicina == :Wo  # Modul v ohybu [mm³]
        # -----------------------------------------------------------
        # Plochá tyč nebo obdélník
        if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
            a, b = getv(:a), getv(:b)
            if natoceni in (0, π, 2*π)
                return a*b^2/6, "a*b²/6"
            elseif natoceni in (π/2, 3*π/2)
                return b*a^2/6, "b*a²/6"
            else
                error("Neplatné natočení profilu: $natoceni rad pro $velicina")
            end
        # -----------------------------------------------------------
        # Kruhová tyč
        elseif info == "KR" # Kruhová tyč
            D = getv(:D)
            return π/32*D^3, "π/32*D³"
        # -----------------------------------------------------------
        # Trubka kruhová
        elseif info == "TRKR" # Trubka kruhová
            D, d = getv(:D), getv(:d)
            return π/32*(D^4 - d^4)/D, "π/32*(D⁴ - d⁴)/D"
        # -----------------------------------------------------------
        # Čtyřhranná tyč
        elseif info == "4HR" # Čtyřhranná tyč
            a = getv(:a)
            if natoceni in (0, π/2, π, 3*π/2, 2*π)
                return a^3/6, "a³/6"
            else
                error("Neplatné natočení profilu: $natoceni rad pro $velicina")
            end
        # -----------------------------------------------------------
        # Šestihranná tyč
        elseif info == "6HR" # Šestihranná tyč
            s = getv(:s)
            if natoceni in (0, 2*π/6, 4*π/6, 6*π/6, 8*π/6, 10*π/6, 12*π/6)
                return 5*sqrt(3)/72*s^3, "5√3/72*s³"
            elseif natoceni in (π/6, 3*π/6, 5*π/6, 7*π/6, 9*π/6, 11*π/6)
                return 5/48*s^3, "5/48*s³"
            else
                error("Neplatné natočení profilu: $natoceni rad pro $velicina")
            end
        # -----------------------------------------------------------
        # Trubka čtyřhranná
        elseif info == "TR4HR" # Trubka čtyřhranná
            a, b, t = getv(:a), getv(:b), getv(:t)
            if natoceni in (0, π/2, π, 3*π/2, 2*π)
                return (a*b^2/6) - ((a-2t)*(b-2t)^2/6), "(a*b²/6)-((a-2t)*(b-2t)²/6)"
            else
                error("Neplatné natočení profilu: $natoceni rad pro $velicina")
            end
        # -----------------------------------------------------------
        # neznámý tvar
        else
            error("Neznámý tvar: $info pro veličinu $velicina")
        end
    # -----------------------------------------------------------
    # Neznámá veličina
    # -----------------------------------------------------------
    else
        error("Neznámá veličina: $velicina")
    end
    return nothing, nothing
end
