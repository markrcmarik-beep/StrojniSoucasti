## Funkce Julia
###############################################################
## Popis funkce:
# Funkce řeší textové označení tvaru profilu dle ČSN a vrací
# strukturu s rozměry. Volitelně lze zadat výpočet vlastností
# profilu (plocha, momenty setrvačnosti, průřezové moduly…).
# ver: 2025-12-30
## Funkce: tvarprofilu()
#
## Vzor:
## vystupni_promenne = tvarprofilu(vstupni_promenne)
## Vstupní proměnné:
# inputStr - Textové označení tvaru profilu dle ČSN.
#   Podporované tvary:
#   "PLO" - obdélníkový profil
#   "PLO _a_x_b_" - "PLO 20x10" - obdélníkový profil
#   "PLO _a_x_b_R_r_" - "PLO 20x10R3" - obdélníkový profil s rádiusem
#   "OBD" - obdélníkový profil
#   "OBD _a_x_b_" - "OBD 20x10" - obdélníkový profil
#   "OBD _a_x_b_R_r_" - "OBD 20x10R3" - obdélníkový profil s rádiusem
#   "KR" - kruhový profil
#   "KR _D_" - "KR 20" - kruhový profil
#   "TRKR" - trubkový kruhový profil
#   "TRKR _D_x_t_" - "TRKR 20x2" - trubkový kruhový profil
#   "4HR" - čtyřhranný profil
#   "4HR _a_" - "4HR 20" - čtyřhranný profil
#   "4HR _a_R_r_" - "4HR 20R3" - čtyřhranný profil s rádiusem
#   "4HR _a_x_b_" - "4HR 20x10" - čtyřhranný profil obdélníkový
#   "4HR _a_x_b_R_r_" - "4HR 20x10R3" - čtyřhranný profil obdélníkový s rá
#   "6HR" - šestihranný profil
#   "6HR _s_" - "6HR 20" - šestihranný profil
#   "TR4HR" - trubkový čtyřhranný profil
#   "TR4HR _a_x_b_x_t_" - "TR4HR 20x20x2" - trubkový čtyřhranný profil
#   "TR4HR _a_x_b_x_t_R_r_" - "TR4HR 20x20x2R3" - trubkový čtyřhranný profil s rádiusem
# args... - Volitelné názvy vlastností k výpočtu.
#   Např: "S", "Ix", "Iy", "Ip", "Wk", ...
## Výstupní proměnné:
# vystupni_promenne - Struktura (Dict) s rozměry profilu a
#   případně i s vypočtenými vlastnostmi.
## Použité balíčky
# Unitful
## Použité uživatelské funkce:
# tvarvlcn - Výpočet vlastností profilu dle zadaných rozměrů.
## Příklad:
# dims = tvarprofilu("PLO 20x10") # pouze rozměry
# println(dims[:a]) # => 20 mm
# println(dims[:b]) # => 10 mm
# dims = tvarprofilu("KR 30") # pouze rozměry
# println(dims[:D]) # => 30 mm
# dims = tvarprofilu("TRKR 50x5") # pouze rozměry
# println(dims[:D]) # => 50 mm
# println(dims[:d]) # => 40 mm
# println(dims[:t]) # => 5 mm
# dims = tvarprofilu("4HR 25") # pouze rozměry
# println(dims[:a]) # => 25 mm
# dims = tvarprofilu("OBD 40x20") # pouze rozměry
# println(dims[:a]) # => 40 mm
# println(dims[:b]) # => 20 mm
# dims = tvarprofilu("6HR 15") # pouze rozměry
# println(dims[:s]) # => 15 mm
# dims = tvarprofilu("TR4HR 60x40x4") # pouze rozměry
# println(dims[:a]) # => 60 mm
# println(dims[:b]) # => 40 mm
# println(dims[:t]) # => 4 mm
# dims = tvarprofilu("TRKR 100x10R3", "S", "Ix", "Iy") # rozměry + vlastnosti
# println(dims[:D]) # => 100 mm
# println(dims[:d]) # => 80 mm
# println(dims[:t]) # => 10 mm
# println(dims[:S]) # => plocha v mm^2
# println(dims[:Ix]) # => moment setrvačnosti Ix v mm^4
# println(dims[:Iy]) # => moment setrvačnosti Iy v mm^4
# dims = tvarprofilu("TR4HR 60x40x4") # pouze rozměry
# dims = tvarprofilu("PLO 20x10", "S", "Ix", "Iy") # rozměry + vlastnosti
# dims = tvarprofilu("TR4HR 50x30x5", "S", "Ix") # rozměry + vlastnosti U profilu
###############################################################
## Použité proměnné vnitřní:
#

using Unitful

function tvarprofilu(inputStr::AbstractString, args...)
    # -----------------------------------------------------------
    # 1) Normalizace vstupu
    # -----------------------------------------------------------
    clean = replace(strip(inputStr), r"\s+" => " ") # odstraní nadbytečné mezery
    parts = split(clean, " ") # rozdělí na profil a rozměry (např: SubString{String}["4HR", "50"])
    if length(parts) < 2
        error("Neplatný vstup: chybí rozměrová část.")
    end
    profile = uppercase(parts[1]) # první část je profil
    dimPart = parts[2] # zbytek je dimenzionální část (profil + rozměry)
    # Výsledná struktura jako Dict
    dims = Dict{Symbol,Any}()
    dims[:info] = profile
    # -----------------------------------------------------------
    # 2) Rozlišení podle profilu (standard dle ČSN)
    # -----------------------------------------------------------
    dims = StrojniSoucasti.tvarCSN(clean)
    # -----------------------------------------------------------
    # 3) Bez dalších parametrů → vracíme pouze rozměry
    # -----------------------------------------------------------
    if length(args) == 0
        return dims # pouze rozměry
    end
    # -----------------------------------------------------------
    # 4) Pokud jsou zadány vlastnosti (S, Ix, Iy, Ip…) nebo hodnoty pro natočení, řeší tvarvlcn nebo přidá natočení
    # -----------------------------------------------------------
    for property in args
        if isa(property, Number) || (isa(property, Unitful.AbstractQuantity) && unit(property) in [u"°", u"rad"])
            dims[:natoceni] = property
        elseif property isa AbstractString || property isa Symbol
            key = Symbol(property) # převod na Symbol
            hodnota, vzorec = StrojniSoucasti.tvarvlcn(dims, key) # volání výpočtu vlastnosti
            dims[key] = hodnota # uložíme hodnotu vlastnosti
            dims[Symbol(key, :_str)] = vzorec # uložíme vzorec jako string
        else
            error("Název vlastnosti musí být String, Symbol, Number nebo hodnota s jednotkami úhlu.")
        end
    end

    return dims # vracíme rozměry + vlastnosti
end