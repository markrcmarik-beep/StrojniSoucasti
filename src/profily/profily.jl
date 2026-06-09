## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce řeší textové označení tvaru profilu dle ČSN a vrací
# strukturu s rozměry. Volitelně lze zadat výpočet vlastností
# profilu (plocha, momenty setrvačnosti, průřezové moduly…).
# ver: 2026-06-09
## Funkce: profily()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profily.jl
#
## Vzor:
## vystupni_promenne = profily(inputStr, args...; natoceni=0)
## Vstupní proměnné:
# inputStr - Textové označení tvaru profilu dle ČSN.
#   Podporované tvary:
#   "PLO {a}x{b}" - "PLO 20x10" - obdélníkový profil
#   "PLO {a}x{b}R{r}" - "PLO 20x10R3" - obdélníkový profil s rádiusem
#   "OBD {a}x{b}" - "OBD 20x10" - obdélníkový profil
#   "OBD {a}x{b}R{r}" - "OBD 20x10R3" - obdélníkový profil s rádiusem
#   "KR {D}" - "KR 20" - kruhový profil
#   "KR {D}/{d}" - "KR 20/10" - kruhový profil s vnitřním průměrem (trubka)
#   "TRKR {D}x{t}" - "TRKR 20x2" - trubkový kruhový profil
#   "4HR {a}" - "4HR 20" - čtyřhranný profil
#   "4HR {a}R{r}" - "4HR 20R3" - čtyřhranný profil s rádiusem
#   "4HR {a}x{b}" - "4HR 20x10" - čtyřhranný profil obdélníkový
#   "4HR {a}x{b}R{r}" - "4HR 20x10R3" - čtyřhranný profil obdélníkový s rádiusem
#   "6HR {s}" - "6HR 20" - šestihranný profil
#   "TR4HR {a}x{b}x{t}", "TR4HR {a}x{t}" - "TR4HR 20x20x2", "TR4HR 20x2" - trubkový čtyřhranný profil dle ČSN 425720
#   "TR4HR {a}x{b}x{t}", "TR4HR {a}x{t}" - "TR4HR 20x20x2", "TR4HR 20x2" - trubkový čtyřhranný profil
#   "TR4HR {a}x{b}x{t}R{r}", "TR4HR {a}x{t}R{r}" - "TR4HR 20x20x2R3", "TR4HR 20x2R3" - trubkový čtyřhranný profil s rádiusem
#   "I {n}" - I profil dle ČSN 425550
#   "IPE {n}" - IPE profil dle ČSN 425553
# args... - Volitelné názvy vlastností k výpočtu.
#   "S" - plocha průřezu [mm^2]
#   "I" - moment setrvačnosti (dle natoceni) [mm^4]
#   "Ix" - moment setrvačnosti Ix [mm^4]
#   "Iy" - moment setrvačnosti Iy [mm^4]
#   "Imin" - minimální moment setrvačnosti [mm^4] - zatím není implementováno
#   "Imax" - maximální moment setrvačnosti [mm^4] - zatím není implementováno
#   "Wo" - průřezový modul pro ohyb (dle natočení) [mm^3]
#   "Wx" - průřezový modul pro ohyb pro osu x [mm^3] - zatím není implementováno
#   "Wy" - průřezový modul pro ohyb pro osu y [mm^3] - zatím není implementováno
#   "Ip", "Jp" - polární moment setrvačnosti [mm^4]
#   "It", "Jt" - torzní moment [mm^3] (pro kruhové průřezy) - zatím není implementováno
#   "J" - polární (torzní) moment setrvačnosti pro krut [mm^4] - zatím není implementováno
#   "Wk" - průřezový modul pro krut [mm^3]
#   "Wt" - torzní průřezový modul [mm^3] (pro kruhové průřezy) - zatím není implementováno
# Natoceni - úhel natočení profilu (volitelný parametr pro výpočet Ix a Wo) (výchozí hodnota 0) [rad]
## Výstupní proměnné:
# dims - Struktura (Dict) s rozměry profilu a
#   případně i s vypočtenými vlastnostmi.
## Použité balíčky
# Unitful
## Použité uživatelské funkce:
# profilyCSN, profilyvlcn
## Příklad:
# dims = profily("PLO 20x10") # pouze rozměry
# println(dims[:a]) # => 20 mm
# println(dims[:b]) # => 10 mm
# dims = profily("KR 30") # pouze rozměry
# println(dims[:D]) # => 30 mm
# dims = profily("TRKR 50x5") # pouze rozměry
# println(dims[:D]) # => 50 mm
# println(dims[:d]) # => 40 mm
# println(dims[:t]) # => 5 mm
# dims = profily("4HR 25") # pouze rozměry
# println(dims[:a]) # => 25 mm
# dims = profily("OBD 40x20") # pouze rozměry
# println(dims[:a]) # => 40 mm
# println(dims[:b]) # => 20 mm
# dims = profily("6HR 15") # pouze rozměry
# println(dims[:s]) # => 15 mm
# dims = profily("TR4HR 60x40x4") # pouze rozměry
# println(dims[:a]) # => 60 mm
# println(dims[:b]) # => 40 mm
# println(dims[:t]) # => 4 mm
# dims = profily("TRKR 100x10R3", "S", "Ix", "Iy") # rozměry + vlastnosti
# println(dims[:D]) # => 100 mm
# println(dims[:d]) # => 80 mm
# println(dims[:t]) # => 10 mm
# println(dims[:S]) # => plocha v mm^2
# println(dims[:Ix]) # => moment setrvačnosti Ix v mm^4
# println(dims[:Iy]) # => moment setrvačnosti Iy v mm^4
# dims = profily("TR4HR 60x40x4") # pouze rozměry
# dims = profily("PLO 20x10", "S", "Ix", "Iy") # rozměry + vlastnosti
# dims = profily("TR4HR 50x30x5", "S", "Ix") # rozměry + vlastnosti U profilu
###############################################################
## Použité proměnné vnitřní:
#
using Unitful

function profily(inputStr::AbstractString, args::AbstractString... ; natoceni::Number=0)
    # -----------------------------------------------------------
    # 1) Normalizace vstupu a extrakce základních rozměrů
    # -----------------------------------------------------------
    #if occursin(r"^(OBD|PLO|KR|TRKF|TR4HR|I|IPE)", inputStr)
    prefixes = ("OBD", "PLO", "4HR", "6HR",
        "KR", "TRKR", 
        "TR4HR", "IPE", "I")
    if any(p -> startswith(inputStr, p), prefixes) # vstup začíná jedním z požadovaných prefixů
        profile = first(filter(p -> startswith(inputStr, p), prefixes)) # najde první shodu s prefixem
        dimPart = replace(inputStr, profile => "") |> strip # odstraní prefix a zbaví se mezer
        #println("vstup:", profile)
        # vstup začíná jedním z požadovaných prefixů
        dims = Dict{Symbol,Any}()
        dims[:info] = profile
    end
    dims = nothing # resetujeme dims, protože výsledkem má být Dict s rozměry
    clean = string(profile, " ", dimPart) # znovu sestaví čistý vstup pro hledání
    # -----------------------------------------------------------
    # 2) Rozlišení podle profilu (standard dle ČSN)
    # -----------------------------------------------------------
    if profile == "I"
        prof01 = StrojniSoucasti.profil_I_CSN425550(clean)
        if prof01 !== nothing
            dims = Dict{Symbol,Any}()
            dims[:info] = "I" # informace o typu profilu
            dims[:serie] = prof01.serie # informace o sérii profilu (např. 80 pro I 80)
            prof01.b !== nothing && (dims[:b] = prof01.b * u"mm") # převod na jednotky mm
            prof01.h !== nothing && (dims[:h] = prof01.h * u"mm") # převod na jednotky mm
            prof01.t1 !== nothing && (dims[:t1] = prof01.t1 * u"mm") # tloušťka pásnice
            prof01.t2 !== nothing && (dims[:t2] = prof01.t2 * u"mm") # tloušťka pásnice a žebra
            prof01.R !== nothing && (dims[:R] = prof01.R * u"mm") # rádius přechodu mezi pásnicí a žebrem
            prof01.R1 !== nothing && (dims[:R1] = prof01.R1 * u"mm") # rádius přechodu mezi pásnicí a žebrem
            prof01.m !== nothing && (dims[:m] = prof01.m * u"kg"/u"m") # hmotnost na jednotku délky [kg/m]
            prof01.standard !== nothing && (dims[:standard] = prof01.standard) # informace o normě (např. "ČSN 425550")
            prof01.material !== nothing && (dims[:material] = prof01.material) # informace o materiálu (např. ["10 000", "10 370.1", "11 373", "11 375", "11 523"])
            prof01.S !== nothing && (dims[:S] = prof01.S * u"mm^2") # plocha průřezu [mm^2]
            prof01.Ix !== nothing && (dims[:Ix] = prof01.Ix * u"mm^4") # moment setrvačnosti Ix [mm^4]
            prof01.Iy !== nothing && (dims[:Iy] = prof01.Iy * u"mm^4") # moment setrvačnosti Iy [mm^4]
            prof01.Wx !== nothing && (dims[:Wx] = prof01.Wx * u"mm^3") # průřezový modul pro ohyb pro osu x [mm^3]
            prof01.Wy !== nothing && (dims[:Wy] = prof01.Wy * u"mm^3") # průřezový modul pro ohyb pro osu y [mm^3]
            prof01.ix !== nothing && (dims[:ix] = prof01.ix * u"mm") # poloměr setrvačnosti pro osu x [mm]
            prof01.iy !== nothing && (dims[:iy] = prof01.iy * u"mm") # poloměr setrvačnosti pro osu y [mm]
            prof01.Sx !== nothing && (dims[:Sx] = prof01.Sx * u"mm^3") # průřezový modul pro ohyb pro osu x [mm^3]
            prof01.sx !== nothing && (dims[:sx] = prof01.sx * u"mm") # vzdálenost od neutrální osy k okraji pro osu x [mm]
        end
    elseif profile == "IPE"
        prof01 = StrojniSoucasti.profil_IPE_CSN425553(clean)
        if prof01 !== nothing
            dims = Dict{Symbol,Any}()
            dims[:info] = "IPE"
            dims[:serie] = prof01.serie
            prof01.b !== nothing && (dims[:b] = prof01.b * u"mm")
            prof01.h !== nothing && (dims[:h] = prof01.h * u"mm")
            prof01.t1 !== nothing && (dims[:t1] = prof01.t1 * u"mm")
            prof01.t2 !== nothing && (dims[:t2] = prof01.t2 * u"mm")
            prof01.R !== nothing && (dims[:R] = prof01.R * u"mm")
            prof01.R1 !== nothing && (dims[:R1] = prof01.R1 * u"mm")
            prof01.m !== nothing && (dims[:m] = prof01.m * u"kg"/u"m") # hmotnost na jednotku délky [kg/m]
            prof01.standard !== nothing && (dims[:standard] = prof01.standard)
            prof01.material !== nothing && (dims[:material] = prof01.material)
            if hasfield(typeof(prof01), :S) && prof01.S !== nothing
                dims[:S] = prof01.S * u"mm^2"
            end
            #prof01.S !== nothing && (dims[:S] = prof01.S * u"mm^2")
            prof01.Ix !== nothing && (dims[:Ix] = prof01.Ix * u"mm^4")
            prof01.Iy !== nothing && (dims[:Iy] = prof01.Iy * u"mm^4")
            prof01.Wx !== nothing && (dims[:Wx] = prof01.Wx * u"mm^3")
            prof01.Wy !== nothing && (dims[:Wy] = prof01.Wy * u"mm^3")
            prof01.ix !== nothing && (dims[:ix] = prof01.ix * u"mm")
            prof01.iy !== nothing && (dims[:iy] = prof01.iy * u"mm")
            prof01.Sx !== nothing && (dims[:Sx] = prof01.Sx * u"mm^3")
            prof01.sx !== nothing && (dims[:sx] = prof01.sx * u"mm")
        end
    elseif profile == "TR4HR"
        prof01 = StrojniSoucasti.profil_TR4HR_CSN425720(clean)
        if prof01 !== nothing
            dims = Dict{Symbol,Any}()
            dims[:info] = "TR4HR"
            prof01.a !== nothing && (dims[:a] = prof01.a * u"mm")
            prof01.b !== nothing && (dims[:b] = prof01.b * u"mm")
            prof01.t !== nothing && (dims[:t] = prof01.t * u"mm")
            prof01.R !== nothing && (dims[:R] = prof01.R * u"mm")
            prof01.m !== nothing && (dims[:m] = prof01.m * u"kg"/u"m") # hmotnost na jednotku délky [kg/m]
            prof01.standard !== nothing && (dims[:standard] = prof01.standard)
            prof01.material !== nothing && (dims[:material] = prof01.material)
            prof01.S !== nothing && (dims[:S] = prof01.S * u"mm^2")
            prof01.Ix !== nothing && (dims[:Ix] = prof01.Ix * u"mm^4")
            prof01.Iy !== nothing && (dims[:Iy] = prof01.Iy * u"mm^4")
            prof01.Wx !== nothing && (dims[:Wx] = prof01.Wx * u"mm^3")
            prof01.Wy !== nothing && (dims[:Wy] = prof01.Wy * u"mm^3")
            prof01.ix !== nothing && (dims[:ix] = prof01.ix * u"mm")
            prof01.iy !== nothing && (dims[:iy] = prof01.iy * u"mm")
            prof01.Sx !== nothing && (dims[:Sx] = prof01.Sx * u"mm^3")
            prof01.sx !== nothing && (dims[:sx] = prof01.sx * u"mm")
        else
            dims = StrojniSoucasti.profilyCSN(clean)
        end
    elseif profile in ["PLO", "OBD", "KR", "TRKR", "4HR", "6HR"]
        dims = StrojniSoucasti.profilyCSN(clean)
    else
        error("Neznámý profil: $profile. Podporované profily jsou PLO, OBD, KR, TRKR, 4HR, 6HR, TR4HR, I, IPE.")
    end
    if dims === nothing
        error("Profil: $clean nebyl nalezen.")
    end
    # -----------------------------------------------------------
    # 3) Bez dalších parametrů → vracíme pouze rozměry
    # -----------------------------------------------------------
    if length(args) == 0
        return dims # pouze rozměry
    #elseif length(args) >= 2
    #    natoceni = args(2) # druhý argument je natočení
    end
    # -----------------------------------------------------------
    # 4) Pokud jsou zadány vlastnosti (S, Ix, Iy, Ip…) nebo hodnoty pro natočení, řeší profilyvlcn nebo přidá natočení
    # -----------------------------------------------------------
    vlastnosti = ["S", "I", "Ix", "Iy", "Ixy", "Imin", "Imax", "Wo", "Wx", "Wy", "Ip", "Jp", "Jt", "J", "Wk", "Wt"]
    for property in args # pro každý zadaný argument (vlastnost nebo natočení)
        property in vlastnosti || error("Neznámá vlastnost: $property. Podporované vlastnosti jsou $vlastnosti.")
        if isa(property, Number) || (isa(property, Unitful.AbstractQuantity) && unit(property) in [u"°", u"rad"])
            dims[:natoceni] = property
        elseif property isa AbstractString || property isa Symbol
            key = Symbol(property) # převod na Symbol
            if haskey(dims, key)
                # Hodnota je už zadaná (např. z tabulky I/IPE), nepřepočítáváme ji.
                #if key == :S && (!(dims[key] isa Unitful.AbstractQuantity) || unit(dims[key]) == Unitful.NoUnits)
                #    dims[key] = dims[key] * u"mm^2"
                #end
                if !haskey(dims, Symbol(key, :_str))
                    dims[Symbol(key, :_str)] = ""
                end
            else
                hodnota, vzorec = StrojniSoucasti.profilyvlcn(dims, key, natoceni=natoceni) # volání výpočtu vlastnosti
                dims[key] = hodnota # uložíme hodnotu vlastnosti
                dims[Symbol(key, :_str)] = vzorec # uložíme vzorec jako string
            end
        else
            error("Název vlastnosti musí být String, Symbol, Number nebo hodnota s jednotkami úhlu.")
        end
    end

    return dims # vracíme rozměry + vlastnosti
end
