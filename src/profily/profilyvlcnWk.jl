## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypočet průřezový modul v krutu pro různé tvary dle zkratky označeni.
# ver: 2026-05-24
## Funkce: profilyvlcnWk()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profilyvlcnWk.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnWk(tvar1, velicina)
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
#    :Wt - Průřezový modul v krutu pro šestihrannou tyč [mm³]
## Výstupní proměnné:
# vystupni_promenne - Struktura (Dict) s rozměry profilu a
# případně i s vypočtenými vlastnostmi. V tomto případě 
# průřezový modul v krutu Wk.
## Použité balíčky:
#
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
function profilyvlcnWk(tvar1::Dict, velicina::Symbol = :Wt)
    info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrati hodnotu nebo missing
    to_num(v, name::Symbol) = begin
        v === missing && error("Chybi parametr: $name")
        v isa Number || error("Parametr $name musi byt cislo.")
        v / oneunit(v)
    end
    getn(k::Symbol) = to_num(getv(k), k)
    # -----------------------------------------------------------
    # Kruhová tyč
    if info == "KR" # Kruhová tyč
        if velicina == :Wk || velicina == :Wt
            getv(:d) === missing ? d = 0 : d = getn(:d)
            D = getn(:D)
            if d == 0
                Wk, Wk_str = pi/16*D^3, "π/16*D³"
            else
                Wk, Wk_str = pi/16*(D^4 - d^4)/D, "π/16*(D⁴ - d⁴)/D"
            end
            return Wk, Wk_str
        else
            error("Neznámá veličina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        if velicina == :Wk || velicina == :Wt
            D, d = getn(:D), getn(:d) # Vnější a vnitřní průměr
            Wk, Wk_str = pi/16*(D^4 - d^4)/D, "π/16*(D⁴ - d⁴)/D"
            return Wk, Wk_str
        else
            error("Neznámá veličina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Čtyřhranná tyč
    elseif info == "4HR" # Čtyřhranná tyč
        if velicina == :Wk
            a = getn(:a) # Strana
            return 0.208*a^3, "0.208*a³"
        elseif velicina == :Wt
            a = getn(:a) # Strana
            return 0.25*a^3, "0.25*a³"
        else
            error("Neznámá veličina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Plochá tyč nebo obdélník
    elseif info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
        if velicina == :Wk
            a, b = getn(:a), getn(:b) # Šířka a výška
            return 0.25*a*b^2, "0.25*a*b²"
        elseif velicina == :Wt
            a, b = getn(:a), getn(:b) # Šířka a výška
            return a*b^2/4*(1 - 0.63*b/a + 0.052*(b/a)^5), 
                "a*b²/4*(1 - 0.63*b/a + 0.052*(b/a)^5)"
        else
            error("Neznámá veličina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # Šestihranná tyč
    elseif info == "6HR" # Šestihranná tyč
        if velicina == :Wk
            s = getn(:s) # Strana
            return 0.17*s^3, "0.17*s³" # ??????????????????
        elseif velicina == :Wt
            s = getn(:s) # Strana
            return 0.17*s^3, "0.17*s³" # ??????????????????
        else
            error("Neznámá veličina: $velicina pro tvar $info")
        end
    # -----------------------------------------------------------
    # neznámý tvar
    else
        error("Neznámý tvar: $info pro veličinu $velicina")
    end

end
