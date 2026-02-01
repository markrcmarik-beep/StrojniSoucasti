## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vyřeší mechanické veličiny pro různé tvary dle zkratky označení.
# ver: 2026-02-01
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

function profilyvlcn(tvar1::Dict, velicina::Symbol; natoceni=0)
    info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrátí hodnotu nebo missing
    # -----------------------------------------------------------
    # S - Plocha [mm²]
    # -----------------------------------------------------------
    if velicina == :S  # Plocha [mm²]
        S_hod, S_str = StrojniSoucasti.profilyvlcnS(tvar1, velicina)
        return S_hod, S_str
    # -----------------------------------------------------------
    # Ip - Polární moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Ip  # Polární moment [mm⁴]
        Ip_hod, Ip_str = StrojniSoucasti.profilyvlcnIp(tvar1, velicina)
        return Ip_hod, Ip_str
    # -----------------------------------------------------------
    # Wk - Modul v krutu [mm³]
    # -----------------------------------------------------------
    elseif velicina == :Wk  # Modul v krutu [mm³]
        Wk_hod, Wk_str = StrojniSoucasti.profilyvlcnWk(tvar1, velicina)
        return Wk_hod, Wk_str
    # -----------------------------------------------------------
    # Ix - Kvadratický moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Ix  # Kvadratický moment [mm⁴]
        # -----------------------------------------------------------
        # Plochá tyč nebo obdélník
        if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
            a, b = getv(:a), getv(:b)
            if natoceni in (0, pi, 2*pi)
                return a*b^3/12, "a*b³/12"
            elseif natoceni in (pi/2, 3*pi/2)
                return b*a^3/12, "b*a³/12"
            else
                error("Neplatné natočení profilu: $natoceni rad pro $velicina")
            end
        # -----------------------------------------------------------
        # Kruhová tyč
        elseif info == "KR" # Kruhová tyč
            D = getv(:D)
            return pi/64*D^4, "π/64*D⁴"
        # -----------------------------------------------------------
        # Trubka kruhová
        elseif info == "TRKR" # Trubka kruhová
            D, d = getv(:D), getv(:d)
            return pi/64*(D^4 - d^4), "π/64*(D⁴ - d⁴)"
        # -----------------------------------------------------------
        # Čtyřhranná tyč
        elseif info == "4HR" # Čtyřhranná tyč
            a = getv(:a)
            if natoceni in (0, pi/2, pi, 3*pi/2, 2*pi)
                return a^4/12, "a⁴/12"
            else
                error("Neplatné natočení profilu: $natoceni rad pro $velicina")
            end
        # -----------------------------------------------------------
        # Šestihranná tyč
        elseif info == "6HR" # Šestihranná tyč (0rad ležící na ploše)
            s = getv(:s)
            if natoceni in (0, 2*pi/6, 4*pi/6, 6*pi/6, 8*pi/6, 10*pi/6, 12*pi/6)
                return 5*sqrt(3)/144*s^4, "5√3/144*s⁴"
            elseif natoceni in (pi/6, 3*pi/6, 5*pi/6, 7*pi/6, 9*pi/6, 11*pi/6)
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
            Iy, Iy_str = StrojniSoucasti.profilyvlcn(tvar1, :Ix, natoceni=pi/2)
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
            return pi/64*D^4, "π/64*D⁴"
        # -----------------------------------------------------------
        # Trubka kruhová
        elseif info == "TRKR" # Trubka kruhová
            D, d = getv(:D), getv(:d)
            return pi/64*(D^4 - d^4), "π/64*(D⁴ - d⁴)"
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
    # -----------------------------------------------------------
    # Neznámá veličina
    # -----------------------------------------------------------
    else
        error("Neznámá veličina: $velicina")
    end
    return nothing, nothing
end
