## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-02-01
## Funkce: profilyvlcnIp()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnIp.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnIp(vstupni_promenne)
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

function profilyvlcnIp(tvar1::Dict, velicina::Symbol)
    info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrátí hodnotu nebo missing

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
        return pi/32*D^4, "π/32*D⁴"
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        D, d = getv(:D), getv(:d)
        return pi/32*(D^4 - d^4), "π/32*(D⁴ - d⁴)"
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
            Ip_num=StrojniSoucasti.torsion_J_TR4HR_numeric(ustrip(u"mm", a),
                ustrip(u"mm", b), ustrip(u"mm", t),
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

end
