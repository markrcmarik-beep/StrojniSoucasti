## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypočet plochy pro různé tvary dle zkratky označeni.
# ver: 2026-04-04
## Funkce: profilyvlcnS()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcnS.jl
#
## Vzor:
## vystupni_promenne = profilyvlcnS(vstupni_promenne)
## Vstupní proměnné:
# tvar1 - slovník (Dict) s informacemi o tvaru, např.:
#    Dict("info" => "PLO", "a" => 20, "b" => 10)
#    Dict("info" => "KR", "D" => 30)
#    Dict("info" => "TRKR", "D" => 30, "d" => 20)
#    Dict("info" => "4HR", "a" => 20)
#    Dict("info" => "6HR", "s" => 20)
#    Dict("info" => "TR4HR", "a" => 20, "b" => 10, "t" => 4)
# velicina - hledaná veličina: (nepovinné, default :S)
#    :S - Plocha průřezu [mm²]
## Výstupní proměnné:
# vystupni_promenne - Struktura (Dict) s rozměry profilu a
#   případně i s vypočtenými vlastnostmi. V tomto případě plocha S.
## Použité balíčky:
# ---
## Použité uživatelské funkce:
# StrojniSoucasti.hrana()
## Příklad:
# tvar = Dict("info" => "PLO", "a" => 20, "b" => 10) # Definice tvaru plošné tyče o rozměrech 20 mm x 10 mm
# S, vzorec = profilyvlcnS(tvar, :S) # Plocha plošné tyče
#   vrátí plochu a použitý vzorec
###############################################################
## Použité proměnné vnitřní:
#
function profilyvlcnS(tvar1::Dict, velicina::Symbol = :S)
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
    # Plochá tyč nebo obdélník
    if info in Set(["PLO", "OBD"]) # Plochá tyč nebo obdélník
        a, b = getn(:a), getn(:b)
        if getv(:R) === missing
            return a*b, "a*b" # Vrátí plochu a vzorec pro plochou tyč bez zaoblení
        else
            R = getn(:R)
            Sr = StrojniSoucasti.hrana("R$(R)")
            Sr = Sr[:S]
            return a*b-4*Sr, "a*b - 4*S(R)" # Vrátí plochu a vzorec pro plochu s odečtením zaoblení (4 zaoblení pro 4 rohy)
        end
    # -----------------------------------------------------------
    # Kruhová tyč
    elseif info == "KR" # Kruhová tyč
        D = getn(:D)
        return pi*(D/2)^2, "π*(D/2)²" # Vrátí plochu a vzorec pro plochu kruhové tyče
    # -----------------------------------------------------------
    # Trubka kruhová
    elseif info == "TRKR" # Trubka kruhová
        D, d = getn(:D), getn(:d)
        return pi*(D^2 - d^2)/4, "π*(D² - d²)/4" # Vrátí plochu a vzorec pro plochu kruhové trubky
    # -----------------------------------------------------------
    # Čtyřhranná tyč
    elseif info == "4HR" # Čtyřhranná tyč
        a = getn(:a)
        if getv(:R) === missing
            return a^2, "a²"
        else
            R = getn(:R)
            Sr = StrojniSoucasti.hrana("R$(R)")
            Sr = Sr[:S]
            return a^2-4*Sr, "a² - 4*S(R)" # Vrátí plochu a vzorec pro plochu čtyřhranné tyče s odečtením zaoblení (4 zaoblení pro 4 rohy)
        end
    # -----------------------------------------------------------
    # Šestihranná tyč
    elseif info == "6HR" # Šestihranná tyč
        s = getn(:s)
        return (3/4)*s^2, "3/4*s²" # Vrátí plochu a vzorec pro plochu šestihranné tyče
    # -----------------------------------------------------------
    # Trubka čtyřhranná
    elseif info == "TR4HR" # Trubka čtyřhranná
        a, b, t = getn(:a), getn(:b), getn(:t)
        return a*b - (a-2t)*(b-2t), "a*b - (a-2t)*(b-2t)" # Vrátí plochu a vzorec pro plochu čtyřhranné trubky
    # -----------------------------------------------------------
    # neznámý tvar
    else
        error("Neznámý tvar: $info pro veličinu: S") # Vyhodí chybu pro neznámý tvar a veličinu S
    end

end
