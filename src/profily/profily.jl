## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce řeší textové označení tvaru profilu dle ČSN a vrací
# strukturu s rozměry. Volitelně lze zadat výpočet vlastností
# profilu (plocha, momenty setrvačnosti, průřezové moduly…).
# ver: 2026-07-16
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
#   "Ixy" - kvadratický moment součinitele [mm^4] (pro výpočet I pro dané natočení)
#   "Imin" - minimální moment setrvačnosti [mm^4]
#   "Imax" - maximální moment setrvačnosti [mm^4]
#   "Wx" - průřezový modul pro ohyb pro osu x [mm^3]
#   "Wy" - průřezový modul pro ohyb pro osu y [mm^3]
#   "Wo" - průřezový modul pro ohyb (dle natočení) [mm^3]
#   "Ip", "Jp" - polární moment setrvačnosti [mm^4]
#   "It", "Jt" - torzní moment [mm^3]
#   "J" - polární (torzní) moment setrvačnosti pro krut [mm^4]
#   "Wk" - průřezový modul pro krut [mm^3]
#   "Wt" - torzní průřezový modul [mm^3]
#   "Wp" - Průřezový modul pro krut polární [mm^3]
#   "ix" -
#   "iy" -
#   "i" -
#   "Sx" -
#   "sx" -
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

"""
    profily(inputStr::AbstractString, args::AbstractString...; natoceni::Number=0)

Vrátí rozměry a volitelně i výpočty vlastností profilu z textového označení.

# Argumenty
- `inputStr`: textové označení profilu dle ČSN, např. `"PLO 20x10"`, `"I 80 ČSN425550"`.
- `args`: nepovinné názvy vlastností, které se mají vypočítat, např. `"S"`, `"Ix"`, `"Iy"`.
- `natoceni`: volitelný úhel natočení profilu v radiánech (nebo ve stupních).

# Příklad
```julia
using StrojniSoucasti
profily("PLO 20x10")
profily("TRKR 100x10R3", "S", "Ix", "Iy")
```
"""
function profily(inputStr::AbstractString, args::AbstractString... ; natoceni::Number=0)
    dopln_jednotku(hod, cil_jednotka) = hod isa Unitful.AbstractQuantity ?
    uconvert(cil_jednotka, hod) : hod * cil_jednotka
    # -----------------------------------------------------------
    # 1) Normalizace vstupu a extrakce základních rozměrů
    # -----------------------------------------------------------
    # prefixes - seznam podporovaných prefixů pro rozlišení typu profilu 
    # (nejdříve dlouhý poté kratší prefix) např. "IPE" před "I", aby se předešlo chybám při hledání
    prefixes = ("OBD", "PLO", "4HR", "6HR",
        "KR", "TRKR", 
        "TR4HR", "IPE", "I") # seznam podporovaných prefixů pro rozlišení typu profilu (nejdříve dlouhý poté kratší prefix) např. "IPE" před "I", aby se předešlo chybám při hledání
    vlastnosti = [
        "S", "Ix", "Iy", "Ixy", "Imin", "Imax", "I", "ex", "ey", "eo", 
        "Wx", "Wy", "Wo", "Jp", "Jt", "J", "rmax", "Wp", "Wt", "Wk", 
        "ix", "iy", "i", "Sx", "sx", "T"] # seznam podporovaných vlastností
    prefixes_norm = ("ČSN", "ISO", "DIN", "EN", "PN", "GOST", "BS", "ASTM", "JIS") # seznam podporovaných norem pro rozlišení typu profilu (např. "ČSN", "ISO", "DIN")
    norma = nothing # proměnná pro uložení extrahované normy (např. "ČSN425550")
    zkratka = nothing # proměnná pro uložení zkratky normy (např. "ČSN")
    norma_extracted = nothing
    zkratka_extracted = nothing
    dims = nothing # resetujeme dims, protože výsledkem má být Dict s rozměry
    if any(p -> startswith(inputStr, p), prefixes) # vstup začíná jedním z požadovaných prefixů
        profile = first(filter(p -> startswith(inputStr, p), prefixes)) # najde první shodu s prefixem
        dimPart = replace(inputStr, profile => "") |> strip # odstraní prefix a zbaví se mezer 
        dims = Dict{Symbol,Any}() # vytvoříme Dict pro uložení rozměrů
        # Extrakce normy z dimPart
        for norm in prefixes_norm # pro každý prefix normy např. norm = "ČSN"
            # Case-insensitive hledání - testujeme lowercase verzi
            if occursin(lowercase(norm), lowercase(dimPart)) # pokud dimPart obsahuje normu, např. "ČSN"
                zkratka = norm # uložení informace o normě pro pozdější použití
                # Hledáme vzor "ČSN 425550" nebo "ČSN425550" nebo "ČSN 42 5550" - case insensitive
                match_norm = match(Regex("($(norm))\\s*([\\d\\s]+)", "i"), dimPart) # vyhledá normu s číslem (case insensitive)
                if match_norm !== nothing
                    norma = replace(match_norm.match |> strip, " " => "")  # odstranění všech mezer: ČSN425550
                    # Odstraníme normu z dimPart, zbude jen označení profilu (rozměry)
                    dimPart = replace(dimPart, match_norm.match => "", count=1) |> strip # odstraní normu z dimPart
                    break
                else
                    # Pokud nenajdeme vzor s číslem, ale najdeme pouze zkratku normy (např. "ČSN"), odstraníme ji
                    match_zkratka = match(Regex("\\b$(norm)\\b", "i"), dimPart)
                    if match_zkratka !== nothing
                        dimPart = replace(dimPart, match_zkratka.match => "", count=1) |> strip
                        break
                    end
                end
            end
        end
        # Uložit normu a zkratku do temp proměnných (pokud byly extrahány)
        norma_extracted = norma
        zkratka_extracted = zkratka
        # vstup začíná jedním z požadovaných prefixů, např. "PLO", "OBD", "KR", "TRKR", "4HR", "6HR", "TR4HR", "IPE", "I"
        dims[:standard] = norma # uložíme normu do dims (např. "ČSN425550")
        dims[:standard_info] = "Norma pro profil, např. ČSN425550" # uložíme informaci o normě do dims
        dims[:zkratka] = zkratka # uložíme původní informaci o normě (např. "ČSN") do dims
        if zkratka !== nothing
            dims[:zkratka_info] = "Zkratka pro normu, např. ČSN, ISO, DIN"
        end
        dims[:info] = profile # uložíme typ profilu do dims (např. "I", "IPE", "TR4HR", "PLO", "OBD", "KR", "TRKR", "4HR", "6HR")
    else
        error("Neplatný typ profilu. Očekává se jedna z hodnot: $prefixes.")
    end
    if isa(natoceni, Number) || (isa(natoceni, Unitful.AbstractQuantity) && unit(natoceni) in [u"°", u"rad"]) # pokud je natoceni číslo nebo jednotka úhlu (° nebo rad)
        dims[:natoceni] = dopln_jednotku(natoceni, u"rad") # uložíme natočení do dims (převedeme na radiany, pokud je zadáno ve stupních)
        natoceni = ustrip(dims[:natoceni]) # převedeme na number bez jednotky, protože budeme používat pro výpočet vlastností
    else
        error("Neplatný typ pro parametr natoceni. Očekává se číslo nebo jednotka úhlu (° nebo rad).")
    end
    for property in args # pro každý zadaný argument (vlastnost nebo natočení)
        property in vlastnosti || error("Neznámá vlastnost: $property. Podporované vlastnosti jsou $vlastnosti.") # kontrola, zda je zadaná vlastnost v seznamu podporovaných vlastností
    end
    clean = string(profile, " ", dimPart) # znovu sestaví čistý vstup pro hledání
    prof01 = nothing
    # -----------------------------------------------------------
    # 2) Rozlišení podle profilu (standard dle ČSN)
    # -----------------------------------------------------------
    if profile == "I" && prof01 === nothing
        prof01 = StrojniSoucasti.profil_I_CSN425550(clean)
        if prof01 !== nothing
            body01 = StrojniSoucasti.body_I_CSN425550(prof01, "ld", natoceni=0) # získáme body pro obrys profilu I dle ČSN 425550
            dims[:info] = "I" # informace o typu profilu
            # Přidáme extrahovanou normu, pokud byla v inputu
            if norma_extracted !== nothing
                dims[:standard] = norma_extracted
                dims[:zkratka] = zkratka_extracted
                dims[:zkratka_info] = "Zkratka pro normu, např. ČSN, ISO, DIN"
            end
            dims = profil_standart(dims, prof01, body01, inputStr, args, natoceni) # uložíme rozměry a vlastnosti do dims
            return dims
        end
    end
    if profile == "IPE" && prof01 === nothing
        prof01 = StrojniSoucasti.profil_IPE_CSN425553(clean)
        if prof01 !== nothing
            body01 = StrojniSoucasti.body_IPE_CSN425553(prof01, "ld", natoceni=0) # získáme body pro obrys profilu IPE dle ČSN 425553
            dims[:info] = "IPE"
            # Přidáme extrahovanou normu, pokud byla v inputu
            if norma_extracted !== nothing
                dims[:standard] = norma_extracted
                dims[:zkratka] = zkratka_extracted
                dims[:zkratka_info] = "Zkratka pro normu, např. ČSN, ISO, DIN"
            end
            dims = profil_standart(dims, prof01, body01, inputStr, args, natoceni) # uložíme rozměry a vlastnosti do dims
            return dims
        end
    end
    if profile == "TR4HR" && prof01 === nothing
        prof01 = StrojniSoucasti.profil_TR4HR_CSN425720(clean)
        if prof01 !== nothing
            body01 = StrojniSoucasti.body_TR4HR_CSN425720(prof01, "ld", natoceni=0) # získáme body pro obrys profilu TR4HR dle ČSN 425720
            dims[:info] = "TR4HR"
            # Přidáme extrahovanou normu, pokud byla v inputu
            if norma_extracted !== nothing
                dims[:standard] = norma_extracted
                dims[:zkratka] = zkratka_extracted
                dims[:zkratka_info] = "Zkratka pro normu, např. ČSN, ISO, DIN"
            end
            dims = profil_standart(dims, prof01, body01, inputStr, args, natoceni) # uložíme rozměry a vlastnosti do dims
            return dims
        end
    end
    if profile in ["PLO", "OBD", "KR", "TRKR", "4HR", "6HR"] && prof01 === nothing
        dims = StrojniSoucasti.profiltvary(clean)
        # Přidáme extrahovanou zkratku normy, pokud byla v inputu
        if dims !== nothing && zkratka_extracted !== nothing
            dims[:zkratka] = zkratka_extracted
            dims[:zkratka_info] = "Zkratka pro normu, např. ČSN, ISO, DIN"
            # Pokud máme i normu s čísly, přidáme ji
            if norma_extracted !== nothing
                dims[:standard] = norma_extracted
            end
        end
        # -----------------------------------------------------------
        # 3) Bez dalších parametrů → vracíme pouze rozměry
        # -----------------------------------------------------------
        if length(args) !== 0
            # -----------------------------------------------------------
            # 4) Pokud jsou zadány vlastnosti (S, Ix, Iy, J, Jp, Jt…) nebo 
            # hodnoty pro natočení, řeší profilyvlcn nebo přidá natočení
            # -----------------------------------------------------------
            for property in args # pro každý zadaný argument (vlastnost nebo natočení)
                property in vlastnosti || error("Neznámá vlastnost: $property. Podporované vlastnosti jsou $vlastnosti.") # kontrola, zda je zadaná vlastnost v seznamu podporovaných vlastností
                if isa(property, Number) || (isa(property, Unitful.AbstractQuantity) && unit(property) in [u"°", u"rad"])
                    dims[:natoceni] = dopln_jednotku(property, u"rad") # uložíme natočení do dims (převedeme na radiany, pokud je zadáno ve stupních)
                end
                if property isa AbstractString || property isa Symbol
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
                        hodnota, vzorec, info = StrojniSoucasti.profilyvlcn(dims, key, natoceni=natoceni) # volání výpočtu vlastnosti
                        dims[key] = hodnota # uložíme hodnotu vlastnosti
                        dims[Symbol(key, :_str)] = vzorec # uložíme vzorec jako string
                        dims[Symbol(key, :_info)] = info # uložíme informaci o vlastnosti
                    end
                else
                    error("Název vlastnosti musí být String, Symbol, Number nebo hodnota s jednotkami úhlu.")
                end
            end
        end
    else
        return nothing
    end
    return dims # vracíme rozměry + vlastnosti
end

# -------------------------------------------------------------
# F U N K C E
# -------------------------------------------------------------
# Pomocná funkce pro standardní profily (I, IPE, TR4HR, PLO, OBD, KR, TRKR, 4HR, 6HR)
function profil_standart(dims, prof01, body01, inputStr, args, natoceni)
    if prof01 !== nothing
        if hasproperty(prof01, :serie)
            prof01.serie !== nothing ? dims[:serie] = prof01.serie : nothing # informace o sérii profilu (např. 80 pro I 80)
        end
        # -----------------------------------------------------------
        # Rozměry profilu (a, b, c, d, d1, d2, e, s, h, t, t1, t2, R, R1, R2, sp, m, standard, zkratka, material)
        if hasproperty(prof01, :a)
            prof01.a !== nothing ? dims[:a] = prof01.a * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :b)
            prof01.b !== nothing ? dims[:b] = prof01.b * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :c)
            prof01.c !== nothing ? dims[:c] = prof01.c * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :d)
            prof01.d !== nothing ? dims[:d] = prof01.d * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :D)
            prof01.D !== nothing ? dims[:D] = prof01.D * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :d1)
            prof01.d1 !== nothing ? dims[:d1] = prof01.d1 * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :d2)
            prof01.d2 !== nothing ? dims[:d2] = prof01.d2 * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :e)
            prof01.e !== nothing ? dims[:e] = prof01.e * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :s)
            prof01.s !== nothing ? dims[:s] = prof01.s * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :h)
            prof01.h !== nothing ? dims[:h] = prof01.h * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :h1)
            prof01.h1 !== nothing ? dims[:h1] = prof01.h1 * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :h2)
            prof01.h2 !== nothing ? dims[:h2] = prof01.h2 * u"mm" : nothing # převod na jednotky mm
        end
        if hasproperty(prof01, :t)
            prof01.t !== nothing ? dims[:t] = prof01.t * u"mm" : nothing # tloušťka pásnice
        end
        if hasproperty(prof01, :t1)
            prof01.t1 !== nothing ? dims[:t1] = prof01.t1 * u"mm" : nothing # tloušťka pásnice
        end
        if hasproperty(prof01, :t2)
            prof01.t2 !== nothing ? (dims[:t2] = prof01.t2 * u"mm") : nothing # tloušťka pásnice a žebra
        end
        if hasproperty(prof01, :R)
            prof01.R !== nothing ? (dims[:R] = prof01.R * u"mm") : nothing # rádius přechodu mezi pásnicí a žebrem
        end
        if hasproperty(prof01, :R1)
            prof01.R1 !== nothing ? (dims[:R1] = prof01.R1 * u"mm") : nothing # rádius přechodu mezi pásnicí a žebrem
        end
        if hasproperty(prof01, :R2)
            prof01.R2 !== nothing ? (dims[:R2] = prof01.R2 * u"mm") : nothing # rádius přechodu mezi pásnicí a žebrem
        end
        if hasproperty(prof01, :sp)
            prof01.sp !== nothing ? (dims[:sp] = prof01.sp) : nothing # sklon pásnice [%]
        end
        if hasproperty(prof01, :m)
            prof01.m !== nothing ? (dims[:m] = prof01.m * u"kg"/u"m") : nothing # hmotnost na jednotku délky [kg/m]
        end
        if hasproperty(prof01, :standard)
            prof01.standard !== nothing ? (dims[:standard] = prof01.standard) : nothing # informace o normě (např. "ČSN 425550")
        end
        if hasproperty(prof01, :zkratka)
            prof01.zkratka !== nothing ? (dims[:zkratka] = prof01.zkratka) : nothing # zkratka pro rychlejší hledání v tabulce (např. "ČSN")
        end
        if hasproperty(prof01, :material)
            prof01.material !== nothing ? (dims[:material] = prof01.material) : nothing # informace o materiálu (např. ["10 000", "10 370.1", "11 373", "11 375", "11 523"])
        end
        # -----------------------------------------------------------
        # S - plocha průřezu
        if "S" in args # pokud je požadováno vypočítat plochu průřezu
            if hasproperty(prof01, :S) && prof01.S !== nothing
                S = prof01.S * u"mm^2" # plocha průřezu [mm^2]
            else
                S = StrojniSoucasti.polygon2plocha(body01) # plocha průřezu [mm^2] (výpočet z polygonu obrysu profilu)
                if S !== nothing
                    S = S * u"mm^2" # převod na jednotky mm^2
                else
                    S = nothing # pokud není plocha průřezu definována, necháme S jako nothing
                end
            end
            dims[:S] = S
        end
        # -----------------------------------------------------------
        # Ix - moment setrvačnosti kolem osy x
        if "Ix" in args # pokud je požadováno vypočítat moment setrvačnosti Ix
            hasproperty(prof01, :Ix) && prof01.Ix !== nothing ? (Ix = prof01.Ix * u"mm^4") : (Ix = nothing) # moment setrvačnosti Ix [mm^4]
            dims[:Ix] = Ix
        end
        # -----------------------------------------------------------
        # Iy - moment setrvačnosti kolem osy y
        if "Iy" in args # pokud je požadováno vypočítat moment setrvačnosti Iy
            hasproperty(prof01, :Iy) && prof01.Iy !== nothing ? (Iy = prof01.Iy * u"mm^4") : (Iy = nothing) # moment setrvačnosti Iy [mm^4]
            dims[:Iy] = Iy
        end
        # -----------------------------------------------------------
        # Ixy - vzájemný moment setrvačnosti (dle natoceni)
        if "Ixy" in args # pokud je požadováno vypočítat vzájemný moment setrvačnosti Ixy
            if natoceni == 0 || natoceni == 180*pi/180 || natoceni == 90*pi/180 || natoceni == 270*pi/180
                hasproperty(prof01, :Ixy) && prof01.Ixy !== nothing ? (Ixy = prof01.Ixy * u"mm^4") : (Ixy = nothing) # vzájemný moment setrvačnosti Ixy [mm^4]
            else
                # Výpočet vzájemného momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                Ix = profily(inputStr, "Ix")[:Ix] # moment setrvačnosti Ix
                Ix = ustrip(Ix) # bez jednotky
                Iy = profily(inputStr, "Iy")[:Iy] # moment setrvačnosti Iy
                Iy = ustrip(Iy) # bez jednotky
                Ixy = profily(inputStr, "Ixy")[:Ixy] # vzájemný moment setrvačnosti Ixy
                Ixy = ustrip(Ixy) # bez jednotky
                if Ix !== nothing && Iy !== nothing && Ixy !== nothing
                    Ixy = StrojniSoucasti.profilyIxy4natoceni(Ix, Iy, Ixy, natoceni) * u"mm^4" # funkce pro výpočet vzájemného momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                #Ixy = Ixy * u"mm^4"
                else
                    Ixy = nothing # pokud nemáme dostatek informací pro výpočet, necháme Ixy jako nothing
                end
            end
            dims[:Ixy] = Ixy
        end
        # -----------------------------------------------------------
        # Imin - minimální moment setrvačnosti
        if "Imin" in args # pokud je požadováno vypočítat minimální moment setrvačnosti
            if hasproperty(prof01, :Imin) && prof01.Imin !== nothing
                Imin = prof01.Imin * u"mm^4" # minimální moment setrvačnosti [mm^4]
            else
                # Výpočet minimálního momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                Ix = profily(inputStr, "Ix")[:Ix] # moment setrvačnosti Ix
                Ix = ustrip(Ix) # bez jednotky
                Iy = profily(inputStr, "Iy")[:Iy] # moment setrvačnosti Iy
                Iy = ustrip(Iy) # bez jednotky
                Ixy = profily(inputStr, "Ixy")[:Ixy] # vzájemný moment setrvačnosti Ixy
                Ixy = ustrip(Ixy) # bez jednotky
                if Ix !== nothing && Iy !== nothing && Ixy !== nothing
                    Imin = StrojniSoucasti.profilyIminmax4natoceni(Ix=Ix, Iy=Iy, Ixy=Ixy, natoceni=natoceni)[1] * u"mm^4" # funkce pro výpočet minimálního momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                else
                    Imin = nothing # pokud nemáme dostatek informací pro výpočet, necháme Imin jako nothing
                end
            end
            dims[:Imin] = Imin
        end
        # -----------------------------------------------------------
        # Imax - maximální moment setrvačnosti
        if "Imax" in args # pokud je požadováno vypočítat maximální moment setrvačnosti
            if hasproperty(prof01, :Imax) && prof01.Imax !== nothing
                Imax = prof01.Imax * u"mm^4" # maximální moment setrvačnosti [mm^4]
            else
                # Výpočet maximálního momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                Ix = profily(inputStr, "Ix")[:Ix] # moment setrvačnosti Ix
                Ix = ustrip(Ix) # bez jednotky
                Iy = profily(inputStr, "Iy")[:Iy] # moment setrvačnosti Iy
                Iy = ustrip(Iy) # bez jednotky
                Ixy = profily(inputStr, "Ixy")[:Ixy] # vzájemný moment setrvačnosti Ixy
                Ixy = ustrip(Ixy) # bez jednotky
                if Ix !== nothing && Iy !== nothing && Ixy !== nothing
                    Imax = StrojniSoucasti.profilyIminmax4natoceni(Ix=Ix, Iy=Iy, Ixy=Ixy, natoceni=natoceni)[2] * u"mm^4" # funkce pro výpočet maximálního momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                else
                    Imax = nothing # pokud nemáme dostatek informací pro výpočet, necháme Imax jako nothing
                end
            end
            dims[:Imax] = Imax
        end
        # -----------------------------------------------------------
        # I - moment setrvačnosti (dle natoceni)
        if "I" in args # pokud je požadováno vypočítat moment setrvačnosti dle natočení
            if natoceni == 0 || natoceni == 180*pi/180
                Ix = profily(inputStr, "Ix")[:Ix] # moment setrvačnosti Ix
                I = Ix
            elseif natoceni == 90*pi/180 || natoceni == 270*pi/180
                Iy = profily(inputStr, "Iy")[:Iy] # moment setrvačnosti Iy
                I = Iy
            else
                # Výpočet momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                Ix = profily(inputStr, "Ix")[:Ix] # moment setrvačnosti Ix
                Ix = ustrip(Ix) # bez jednotky
                Iy = profily(inputStr, "Iy")[:Iy] # moment setrvačnosti Iy
                Iy = ustrip(Iy) # bez jednotky
                Ixy = profily(inputStr, "Ixy")[:Ixy] # vzájemný moment setrvačnosti Ixy
                Ixy = ustrip(Ixy) # bez jednotky
                if Ix !== nothing && Iy !== nothing && Ixy !== nothing
                    I = StrojniSoucasti.profilyI4natoceni(Ix, Iy, Ixy, natoceni) * u"mm^4" # funkce pro výpočet momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                else
                    I = nothing # pokud nemáme dostatek informací pro výpočet, necháme I jako nothing
                end
            end
            dims[:I] = I
        end
        # -----------------------------------------------------------
        # ex - vzdálenost nejvzdálenějšího vlákna od neutrální osy x
        if "ex" in args # pokud je požadováno vypočítat vzdálenost těžiště od osy x
            if hasproperty(prof01, :ex) && prof01.ex !== nothing
                ex = prof01.ex * u"mm" # vzdálenost těžiště od osy x [mm]
            else
                ex = polygon2eonatoceni(body01, 0) # vzdálenost těžiště od osy x [mm]
            end
            dims[:ex] = ex
        end
        # -----------------------------------------------------------
        # ey - vzdálenost nejvzdálenějšího vlákna od neutrální osy y
        if "ey" in args # pokud je požadováno vypočítat vzdálenost těžiště od osy y
            if hasproperty(prof01, :ey) && prof01.ey !== nothing
                ey = prof01.ey * u"mm" # vzdálenost těžiště od osy y [mm]
            else
                ey = polygon2eonatoceni(body01, 90*pi/180) # vzdálenost těžiště od osy y [mm]
            end
            dims[:ey] = ey
        end
        # -----------------------------------------------------------
        # eo - vzdálenost nejvzdálenějšího vlákna od neutrální osy (dle natoceni)
        if "eo" in args # pokud je požadováno vypočítat vzdálenost těžiště od osy x (dle natoceni)
            if natoceni == 0 || natoceni == 180*pi/180
                ex = profily(inputStr, "ex")[:ex] # vzdálenost těžiště od osy x
                eo = ex
            elseif natoceni == 90*pi/180 || natoceni == 270*pi/180
                ey = profily(inputStr, "ey")[:ey] # vzdálenost těžiště od osy y
                eo = ey
            else
                eo = polygon2eonatoceni(body01, natoceni) # vzdálenost těžiště od osy (dle natoceni)
            end
            dims[:eo] = eo
        end
        # -----------------------------------------------------------
        # Wx - průřezový modul pro ohyb pro osu x
        if "Wx" in args # pokud je požadováno vypočítat průřezový modul pro ohyb pro osu x
            if hasproperty(prof01, :Wx) && prof01.Wx !== nothing
                Wx = prof01.Wx * u"mm^3" # průřezový modul pro ohyb pro osu x [mm^3]
            else
                Ix = profily(inputStr, "Ix")[:Ix] # moment setrvačnosti Ix
                ex = profily(inputStr, "ex")[:ex] # vzdálenost těžiště od osy x
                if Ix !== nothing && ex !== nothing
                    Wx = Ix / ex # průřezový modul pro ohyb pro osu x [mm^3]
                else
                    Wx = nothing
                end
            end
            dims[:Wx] = Wx
        end
        # -----------------------------------------------------------
        # Wy - průřezový modul pro ohyb pro osu y
        if "Wy" in args # pokud je požadováno vypočítat průřezový modul pro ohyb pro osu y
            if hasproperty(prof01, :Wy) && prof01.Wy !== nothing
                Wy = prof01.Wy * u"mm^3" # průřezový modul pro ohyb pro osu y [mm^3]
            else
                Iy = profily(inputStr, "Iy")[:Iy] # moment setrvačnosti Iy
                ey = profily(inputStr, "ey")[:ey] # vzdálenost těžiště od osy y
                if Iy !== nothing && ey !== nothing
                    Wy = Iy / ey # průřezový modul pro ohyb pro osu y [mm^3]
                else
                    Wy = nothing
                end
            end
            dims[:Wy] = Wy
        end
        if "Wo" in args # pokud je požadováno vypočítat průřezový modul pro ohyb
            if natoceni == 0 || natoceni == 180*pi/180
                Wx = profily(inputStr, "Wx")[:Wx] # průřezový modul pro ohyb pro osu x
                Wo = Wx
            elseif natoceni == 90*pi/180 || natoceni == 270*pi/180
                Wy = profily(inputStr, "Wy")[:Wy] # průřezový modul pro ohyb pro osu y
                Wo = Wy
            else
                I = profily(inputStr, "I")[:I] # moment setrvačnosti (dle natoceni)
                eo = profily(inputStr, "eo")[:eo] # vzdálenost těžiště od osy (dle natoceni)
                if I !== nothing && eo !== nothing
                    Wo = I / eo # průřezový modul pro ohyb (dle natoceni) [mm^3]
                else
                    Wo = nothing
                end
            end
            dims[:Wo] = Wo
        end
        if "Jp" in args # pokud je požadováno vypočítat polární moment setrvačnosti
            if hasproperty(prof01, :Jp) && prof01.Jp !== nothing
                dims[:Jp] = prof01.Jp * u"mm^4" # polární moment setrvačnosti [mm^4]
            else
                Ix = profily(inputStr, "Ix")[:Ix]
                Iy = profily(inputStr, "Iy")[:Iy]
                if Ix !== nothing && Iy !== nothing
                    dims[:Jp] = Ix + Iy
                else
                    dims[:Jp] = nothing
                end
            end
        end
        if "Jt" in args # pokud je požadováno vypočítat torsní moment setrvačnosti
            if hasproperty(prof01, :Jt) && prof01.Jt !== nothing
                dims[:Jt] = prof01.Jt * u"mm^4" # torsní moment setrvačnosti [mm^4]
            else
                dims[:Jt] = nothing
            end
        end
        if "J" in args # pokud je požadováno vypočítat torsní moment setrvačnosti
            if hasproperty(prof01, :J) && prof01.J !== nothing
                dims[:J] = prof01.J * u"mm^4" # torsní moment setrvačnosti [mm^4]
            else
                dims[:J] = nothing
            end
        end
        if "rmax" in args # pokud je požadováno vypočítat vzdálenost nejvzdálenějšího vlákna od osy otáčení (maximální poloměr)
            if hasproperty(prof01, :rmax) && prof01.rmax !== nothing
                dims[:rmax] = prof01.rmax * u"mm"
            else
                dims[:rmax] = nothing
            end
        end
        if "Wp" in args # pokud je požadováno vypočítat průřezový modul pro krut
            if hasproperty(prof01, :Wp) && prof01.Wp !== nothing
                dims[:Wp] = prof01.Wp * u"mm^3"
            else
                Jp = profily(inputStr, "Jp")[:Jp] # moment setrvačnosti Jp
                rmax = profily(inputStr, "rmax")[:rmax] # vzdálenost nejvzdálenějšího vlákna od osy otáčení (maximální poloměr)
                if Jp !== nothing && rmax !== nothing
                    dims[:Wp] = Jp / rmax # průřezový modul pro krut [mm^3]
                else
                    dims[:Wp] = nothing
                end
            end
        end
        if "Wt" in args # pokud je požadováno vypočítat průřezový modul pro krut (torsní modul)
            if hasproperty(prof01, :Wt) && prof01.Wt !== nothing
                Wt = prof01.Wt * u"mm^3"
            else
                Ixy = profily(inputStr, "Ixy")[:Ixy] # vzájemný moment setrvačnosti Ixy
                if Ixy !== nothing && Ixy === 0
                    Wp = profily(inputStr, "Wp")[:Wp] # průřezový modul pro krut Wp
                    Wt = Wp
                else
                    Jt = profily(inputStr, "Jt")[:Jt] # moment setrvačnosti Jt
                    rmax = profily(inputStr, "rmax")[:rmax] # vzdálenost nejvzdálenějšího vlákna od osy otáčení (maximální poloměr)
                    if Jt !== nothing && rmax !== nothing
                        Wt = Jt / rmax # průřezový modul pro krut [mm^3]
                    end
                    Wt = nothing
                end
            end
            dims[:Wt] = Wt
        end
        if "Wk" in args # pokud je požadováno vypočítat kroutící průřezový modul
            if hasproperty(prof01, :Wk) && prof01.Wk !== nothing
                Wk = prof01.Wk * u"mm^3"
            else
                Wt = profily(inputStr, "Wt")[:Wt] # kroutící průřezový modul Wt
                Wk = Wt
            end
            dims[:Wk] = Wk
        end
        if "ix" in args
            if hasproperty(prof01, :ix) && prof01.ix !== nothing
                ix = prof01.ix * u"mm"
            else
                Ix = profily(inputStr, "Ix")[:Ix]
                S = profily(inputStr, "S")[:S]
                (Ix!==nothing || S!==nothing) ? ix=sqrt(Ix/S) : ix=nothing
            end
            dims[:ix] = ix
        end
        if "iy" in args
            if hasproperty(prof01, :iy) && prof01.iy !== nothing
                iy = prof01.iy * u"mm"
            else
                Iy = profily(inputStr, "Iy")[:Iy]
                S = profily(inputStr, "S")[:S]
                (Iy!==nothing || S!==nothing) ? iy=sqrt(Iy/S) : iy=nothing
            end
            dims[:iy] = iy
        end
        if "i" in args
            if natoceni == 0 || natoceni == 180*pi/180
                i = profily(inputStr, "ix")[:ix]
            elseif natoceni == 90*pi/180 || natoceni == 270*pi/180
                i = profily(inputStr, "iy")[:iy]
            else
                i = nothing
            end
            dims[:i] = i
        end
        if "Sx" in args
            if hasproperty(prof01, :Sx) && prof01.Sx !== nothing
                Sx = prof01.Sx * u"mm^3"
            else
                Sx = nothing
            end
            dims[:Sx] = Sx
        end
        if "Sy" in args
            if hasproperty(prof01, :Sy) && prof01.Sy !== nothing
                Sy = prof01.Sy * u"mm^3"
            else
                Sy = nothing
            end
            dims[:Sy] = Sy
        end
        if "sx" in args
            if hasproperty(prof01, :sx) && prof01.sx !== nothing
                sx = prof01.sx * u"mm"
            else
                sx = nothing
            end
            dims[:sx] = sx
        end
        if "T" in args # těžiště
            if natoceni == 0 || natoceni == 180*pi/180
                if hasproperty(prof01, :T) && prof01.T !== nothing
                    T = prof01.T * u"mm"
                else
                    T = nothing
                end
            else
                T = nothing
            end
            dims[:T] = T
        end
        return dims
    else
        return nothing
    end

end
