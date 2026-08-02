## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet torzní konstanty J, Jp, Jt pro různé tvary profilů.
# ver: 2026-07-06
## Funkce: profilyvlcnIp()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profilyvlcnJp.jl
#
## Vzor:
## J_hod, J_str = profilyvlcnJp(tvar1, velicina)
## Vstupní proměnné:
# tvar1 - slovník (Dict) s informacemi o tvaru profilu a jeho parametrech
#   :info - tvar profilu (řetězec, např. "PLO", "OBD", "KR", "TRKR", "4HR", "TR4HR", "6HR")
#   :a, :b, :t, :D, :d, :s - parametry profilu (v závislosti na tvaru)
# velicina - hledaná veličina (výchzí hodnota :Jt)
#   :Jp - Polární moment průřezu [mm³]
#   :Jt - Torzní konstanta [mm³]
## Výstupní proměnné:
# J_hod - hodnota polárního momentu průřezu s jednotkami
# J_str - vzorec použitý pro výpočet polárního momentu průřezu (string)
## Použité balíčky:
# 
## Použité uživatelské funkce:
# StrojniSoucasti.torsion_J_TR4HR_numeric(),
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
function profilyvlcnJ(tvar1::Dict, velicina::Symbol = :Jt)
    info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrati hodnotu nebo missing
    to_num(v, name::Symbol) = begin
        v === missing && error("Chybi parametr: $name")
        v isa Number || error("Parametr $name musi byt cislo.")
        v / oneunit(v)
    end
    getn(k::Symbol) = to_num(getv(k), k) # Získání numerické hodnoty parametru
    # -----------------------------------------------------------
    # Plochá tyč nebo obdélník
    if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
        a, b = getn(:a), getn(:b)
        if velicina == :Jp
            a, b = getn(:a), getn(:b)
            Jp, Jp_str = a*b*(a^2 + b^2)/12, "a*b*(a^2 + b^2)/12"
            return Jp, Jp_str
        elseif velicina == :Jt || velicina == :J
            a, b = getn(:a), getn(:b)
            if a <= b
                Jt, Jt_str = a*b^3/3*(1 - 0.63*a/b + 0.052*(a/b)^5), 
                    "a*b³/3*(1 - 0.63*a/b + 0.052*(a/b)^5)"
            else
                Jt, Jt_str = b*a^3/3*(1 - 0.63*b/a + 0.052*(b/a)^5), 
                    "b*a³/3*(1 - 0.63*a/b + 0.052*(a/b)^5)"
            end
            return Jt, Jt_str
        else
            error("Neznámá veličina: $velicina pro tvar: $info.")
        end
    # -----------------------------------------------------------
    # Kruhová tyč
    elseif info == "KR" # Kruhová tyč
        if velicina == :Jp || velicina == :Jt || velicina == :J
            getv(:d) === missing ? d = 0 : d = getn(:d)
            D = getn(:D)
            if d == 0
                J, J_str = pi/32*D^4, "π/32*D⁴"
            else
                J, J_str = pi/32*(D^4 - d^4), "π/32*(D⁴ - d⁴)"
            end
            return J, J_str
        else
            error("Neznámá veličina: $velicina pro tvar: $info.")
        end
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        if velicina == :Jp || velicina == :Jt || velicina == :J
            D, d = getn(:D), getn(:d)
            return pi/32*(D^4 - d^4), "π/32*(D⁴ - d⁴)"
        else
            error("Neznámá veličina: $velicina pro tvar: $info.")
        end
    # -----------------------------------------------------------
    # Čtyřhranná tyč
    elseif info == "4HR" # Čtyřhranná tyč
        if velicina == :Jp
            if getv(:b) === missing
                a = getn(:a)
                return 1/6*a^4, "1/6*a⁴" # Torzní konstanta
            else
                a, b = getn(:a), getn(:b)
                Jp, Jp_str = a*b*(a^2 + b^2)/12, "a*b*(a^2 + b^2)/12"
                return Jp, Jp_str
            end
        elseif velicina == :Jt || velicina == :J
            if getv(:b) === missing
                a = getn(:a)
                return 0.1406*a^4, "0.1406*a⁴" # Torzní konstanta
            else
                a, b = getn(:a), getn(:b)
                if a <= b
                    Jp, Jp_str = a*b^3/3*(1 - 0.63*a/b + 0.052*(a/b)^5), 
                        "a*b³/3*(1 - 0.63*a/b + 0.052*(a/b)^5)"
                else
                    Jp, Jp_str = b*a^3/3*(1 - 0.63*b/a + 0.052*(b/a)^5), 
                        "b*a³/3*(1 - 0.63*a/b + 0.052*(a/b)^5)"
                end
                return Jt, Jt_str
            end
        else
            error("Neznámá veličina: $velicina pro tvar: $info.")
        end
    # -----------------------------------------------------------
    # Trubka čtyřhranná
    elseif info == "TR4HR"
        if velicina == :Jp || velicina == :Jt || velicina == :J
            a, b, t = getn(:a), getn(:b), getn(:t)
            if min(a,b)*0.1 >= t
                return 2*(a-t)^2*(b-t)^2*t/((a-t)+(b-t)), 
                    "2*(a-t)²*(b-t)²*t/((a-t)+(b-t))" # ideálně t≤0.05min⁡(a,b) t≤0.05min(a,b) při t>0.1min⁡(a,b) t>0.1min(a,b) už chyba rychle roste
            elseif min(a,b)*0.5 > t
                return 2*(a-t)^2*(b-t)^2*t/((a-t)+(b-t))+2/3*(a+b)*t^3, 
                    "2*(a-t)²*(b-t)²*t/((a-t)+(b-t))+2/3*(a+b)*t³"
            else
                Ip_num=StrojniSoucasti.torsion_J_TR4HR_numeric(a,
                    b, t,
                    nx=150, ny=150, tol=1e-2, maxiter=50000) # numerické řeš.
                if isa(Ip_num, Number) && !isnan(Ip_num)
                    return Ip_num, "num. řešení"
                else
                    error("Nedefinovaný výpočet. Tvar: $info pro veličinu: $velicina. 
                        Selhalo numerické řešení. 'a'=$a 'b'=$b 't'=$t")
                end
            end
        else
            error("Neznámá veličina: $velicina pro tvar: $info.")
        end
    # -----------------------------------------------------------
    # Šestihranná tyč
    elseif info == "6HR" # Šestihranná tyč
        s = getn(:s)
        if velicina == :Jp
            return 5*sqrt(3)/8*s^4, "5*sqrt(3)/8*s⁴"
        elseif velicina == :Jt || velicina == :J
            return 1.013*s^4, "1.013*s⁴" # Torzní konstanta
        else
            error("Neznámá veličina: $velicina pro tvar: $info.")
        end
    # -----------------------------------------------------------
    # neznámý tvar
    else
        error("Neznámý tvar: $info pro veličinu $velicina.")
    end

end
