## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce řeší textové označení tvaru profilu dle ČSN a vrací
# strukturu s rozměry. Volitelně lze zadat výpočet vlastností
# profilu (plocha, momenty setrvačnosti, průřezové moduly…).
# ver: 2026-06-27
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
#   "Ixy" - kvadratický moment součinitele [mm^4] (pro výpočet I pro dané natočení) - zatím není implementováno
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
    vlastnosti = ["S", "Ix", "Iy", "Ixy", "Imin", "Imax", "I", "Wx", "Wy", "Wo", "Jp", "Jt", "J", "Wk", "Wt", "ix", "iy"] # seznam podporovaných vlastností
    prefixes_norm = ("ČSN", "ISO", "DIN", "EN", "PN", "GOST", "BS", "ASTM", "JIS") # seznam podporovaných norem pro rozlišení typu profilu (např. "ČSN", "ISO", "DIN")
    norma = nothing
    zkratka = nothing
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
            dims[:zkratka_info] = "Zkratka pro normu, např. $(zkratka)"
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
    # -----------------------------------------------------------
    # 2) Rozlišení podle profilu (standard dle ČSN)
    # -----------------------------------------------------------
    if profile == "I"
        prof01 = StrojniSoucasti.profil_I_CSN425550(clean)
        body01 = body_I_CSN425550(prof01, "ld", natoceni=0) # získáme body pro obrys profilu I dle ČSN 425550
        info = "I"
        if prof01 !== nothing
            dims[:info] = info # informace o typu profilu
            dims[:serie] = prof01.serie # informace o sérii profilu (např. 80 pro I 80)
            prof01.b !== nothing ? dims[:b] = prof01.b * u"mm" : nothing # převod na jednotky mm
            prof01.h !== nothing ? dims[:h] = prof01.h * u"mm" : nothing # převod na jednotky mm
            prof01.t1 !== nothing ? dims[:t1] = prof01.t1 * u"mm" : nothing # tloušťka pásnice
            prof01.t2 !== nothing ? (dims[:t2] = prof01.t2 * u"mm") : nothing # tloušťka pásnice a žebra
            prof01.R !== nothing ? (dims[:R] = prof01.R * u"mm") : nothing # rádius přechodu mezi pásnicí a žebrem
            prof01.R1 !== nothing ? (dims[:R1] = prof01.R1 * u"mm") : nothing # rádius přechodu mezi pásnicí a žebrem
            prof01.m !== nothing ? (dims[:m] = prof01.m * u"kg"/u"m") : nothing # hmotnost na jednotku délky [kg/m]
            prof01.standard !== nothing ? (dims[:standard] = prof01.standard) : nothing # informace o normě (např. "ČSN 425550")
            prof01.zkratka !== nothing ? (dims[:zkratka] = prof01.zkratka) : nothing # zkratka pro rychlejší hledání v tabulce (např. "ČSN")
            prof01.material !== nothing ? (dims[:material] = prof01.material) : nothing # informace o materiálu (např. ["10 000", "10 370.1", "11 373", "11 375", "11 523"])
            if "S" in args # pokud je požadováno vypočítat plochu průřezu
                hasproperty(prof01, :S) && prof01.S !== nothing ? (S = prof01.S * u"mm^2") : (S = nothing) # plocha průřezu [mm^2]
                dims[:S] = S
            end
            if "Ix" in args # pokud je požadováno vypočítat moment setrvačnosti Ix
                prof01.Ix !== nothing ? (Ix = prof01.Ix * u"mm^4") : (Ix = nothing) # moment setrvačnosti Ix [mm^4]
                dims[:Ix] = Ix
            end
            if "Iy" in args # pokud je požadováno vypočítat moment setrvačnosti Iy
                prof01.Iy !== nothing ? (Iy = prof01.Iy * u"mm^4") : (Iy = nothing) # moment setrvačnosti Iy [mm^4]
                dims[:Iy] = Iy
            end
            if "Ixy" in args # pokud je požadováno vypočítat vzájemný moment setrvačnosti Ixy
                if natoceni == 0 || natoceni == 180*pi/180 || natoceni == 90*pi/180 || natoceni == 270*pi/180
                    prof01.Ixy !== nothing ? (Ixy = prof01.Ixy * u"mm^4") : (Ixy = nothing) # vzájemný moment setrvačnosti Ixy [mm^4]
                else
                    # Výpočet vzájemného momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                    prof01.Ix !== nothing ? Ix = prof01.Ix : Ix = nothing # moment setrvačnosti Ix bez jednotky
                    prof01.Iy !== nothing ? Iy = prof01.Iy : Iy = nothing # moment setrvačnosti Iy bez jednotky
                    prof01.Ixy !== nothing ? Ixy = prof01.Ixy : Ixy = nothing # vzájemný moment setrvačnosti Ixy bez jednotky
                    if Ix !== nothing && Iy !== nothing && Ixy !== nothing
                        Ixy = profilyIxy4natoceni(Ix, Iy, Ixy * u"mm^4", natoceni) # funkce pro výpočet vzájemného momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                        #Ixy = Ixy * u"mm^4"
                    else
                        Ixy = nothing # pokud nemáme dostatek informací pro výpočet, necháme Ixy jako nothing
                    end
                end
                dims[:Ixy] = Ixy
            end
            if "Imin" in args # pokud je požadováno vypočítat minimální moment setrvačnosti
                prof01.Imin !== nothing ? (Imin = prof01.Imin * u"mm^4") : (Imin = profilyIminmax4natoceni(Ix=Ix, Iy=Iy, Ixy=Ixy, natoceni=natoceni)[1]) # minimální moment setrvačnosti [mm^4]
                dims[:Imin] = Imin
            end
            if "Imax" in args # pokud je požadováno vypočítat maximální moment setrvačnosti
                prof01.Imax !== nothing ? (Imax = prof01.Imax * u"mm^4") : (Imax = profilyIminmax4natoceni(Ix=Ix, Iy=Iy, Ixy=Ixy, natoceni=natoceni)[2]) # maximální moment setrvačnosti [mm^4]
                dims[:Imax] = Imax
            end
            if "I" in args || "Wo" in args # pokud je požadováno vypočítat moment setrvačnosti dle natočení
                if natoceni == 0 || natoceni == 180*pi/180
                    prof01.Ix !== nothing ? (I = prof01.Ix * u"mm^4") : (I = nothing) # moment setrvačnosti (dle natoceni) [mm^4]
                elseif natoceni == 90*pi/180 || natoceni == 270*pi/180
                    prof01.Iy !== nothing ? (I = prof01.Iy * u"mm^4") : (I = nothing) # moment setrvačnosti (dle natoceni) [mm^4]
                else
                    # Výpočet momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                    prof01.Ix !== nothing ? Ix = prof01.Ix : Ix = nothing # moment setrvačnosti Ix bez jednotky
                    prof01.Iy !== nothing ? Iy = prof01.Iy : Iy = nothing # moment setrvačnosti Iy bez jednotky
                    prof01.Ixy !== nothing ? Ixy = prof01.Ixy : Ixy = nothing # vzájemný moment setrvačnosti Ixy bez jednotky
                    if Ix !== nothing && Iy !== nothing && Ixy !== nothing
                        I = profilyI4natoceni(Ix, Iy, Ixy, natoceni) # funkce pro výpočet momentu setrvačnosti pro dané natočení (dle vzorce pro rotaci souřadnic)
                        #I = I * u"mm^4" # moment setrvačnosti (dle natoceni) [mm^4]
                    else
                        I = nothing # pokud nemáme dostatek informací pro výpočet, necháme I jako nothing
                    end
                end
                if "I" in args
                    dims[:I] = I
                end
                #prof01.I !== nothing ? (dims[:I] = prof01.I * u"mm^4") : (dims[:I] = nothing) # moment setrvačnosti (dle natoceni) [mm^4]
            end
            if "Wx" in args # pokud je požadováno vypočítat průřezový modul pro ohyb pro osu x
                prof01.Wx !== nothing ? (Wx = prof01.Wx * u"mm^3") : (Wx = nothing) # průřezový modul pro ohyb pro osu x [mm^3]
                dims[:Wx] = Wx
            end
            if "Wy" in args # pokud je požadováno vypočítat průřezový modul pro ohyb pro osu y
                prof01.Wy !== nothing ? (Wy = prof01.Wy * u"mm^3") : (Wy = nothing) # průřezový modul pro ohyb pro osu y [mm^3]
                dims[:Wy] = Wy
            end
            if "Wo" in args # pokud je požadováno vypočítat průřezový modul pro ohyb
                if natoceni == 0 || natoceni == 180*pi/180
                    prof01.Wx !== nothing ? (Wo = prof01.Wx * u"mm^3") : (Wo = nothing) # průřezový modul pro ohyb (dle natoceni) [mm^3]
                elseif natoceni == 90*pi/180 || natoceni == 270*pi/180
                    prof01.Wy !== nothing ? (Wo = prof01.Wy * u"mm^3") : (Wo = nothing) # průřezový modul pro ohyb (dle natoceni) [mm^3]
                else
                    prof01.Wo !== nothing ? (Wo = prof01.Wo * u"mm^3") : (Wo = profilyWo4natoceni(Ix, Iy, Ixy, natoceni)) # průřezový modul pro ohyb (dle natoceni) [mm^3]
                end
                dims[:Wo] = Wo
            end
            if "Jp" in args # pokud je požadováno vypočítat polární moment setrvačnosti
                prof01.Jp !== nothing ? (dims[:Jp] = prof01.Jp * u"mm^4") : (dims[:Jp] = nothing) # polární moment setrvačnosti [mm^4]
            end
            if "Jt" in args # pokud je požadováno vypočítat torsní moment setrvačnosti
                prof01.Jt !== nothing ? (dims[:Jt] = prof01.Jt * u"mm^4") : (dims[:Jt] = nothing) # torsní moment setrvačnosti [mm^4]
            end
            if "J" in args # pokud je požadováno vypočítat torsní moment setrvačnosti
                prof01.J !== nothing ? (dims[:J] = prof01.J * u"mm^4") : (dims[:J] = nothing) # torsní moment setrvačnosti [mm^4]
            end
            if "Wk" in args # pokud je požadováno vypočítat kroutící průřezový modul
                prof01.Wk !== nothing ? (dims[:Wk] = prof01.Wk * u"mm^3") : (dims[:Wk] = nothing) # kroutící průřezový modul [mm^3]
            end
            if "ix" in args
                prof01.ix !== nothing ? (ix = prof01.ix * u"mm") : (ix = nothing) # poloměr setrvačnosti pro osu x [mm]
                dims[:ix] = ix
            end
            if "iy" in args
                prof01.iy !== nothing ? (iy = prof01.iy * u"mm") : (iy = nothing) # poloměr setrvačnosti pro osu y [mm]
                dims[:iy] = iy
            end
            prof01.Sx !== nothing ? (dims[:Sx] = prof01.Sx * u"mm^3") : (dims[:Sx] = nothing) # průřezový modul pro ohyb pro osu x [mm^3]
            prof01.sx !== nothing ? (dims[:sx] = prof01.sx * u"mm") : (dims[:sx] = nothing) # vzdálenost od neutrální osy k okraji pro osu x [mm]
            # Přidáme extrahovanou normu, pokud byla v inputu
            if norma_extracted !== nothing
                dims[:standard] = norma_extracted
                dims[:zkratka] = zkratka_extracted
                dims[:zkratka_info] = "Zkratka pro normu, např. $(zkratka_extracted)"
            end
        end
    elseif profile == "IPE"
        prof01 = StrojniSoucasti.profil_IPE_CSN425553(clean)
        if prof01 !== nothing
            dims[:info] = "IPE"
            dims[:serie] = prof01.serie
            prof01.b !== nothing ? (dims[:b] = prof01.b * u"mm") : nothing
            prof01.h !== nothing ? (dims[:h] = prof01.h * u"mm") : nothing
            prof01.t1 !== nothing ? (dims[:t1] = prof01.t1 * u"mm") : nothing
            prof01.t2 !== nothing ? (dims[:t2] = prof01.t2 * u"mm") : nothing
            prof01.R !== nothing ? (dims[:R] = prof01.R * u"mm") : nothing
            prof01.R1 !== nothing ? (dims[:R1] = prof01.R1 * u"mm") : nothing
            prof01.m !== nothing ? (dims[:m] = prof01.m * u"kg"/u"m") : nothing # hmotnost na jednotku délky [kg/m]
            prof01.standard !== nothing ? (dims[:standard] = prof01.standard) : nothing
            prof01.zkratka !== nothing ? (dims[:zkratka] = prof01.zkratka) : nothing # zkratka pro rychlejší hledání v tabulce
            prof01.material !== nothing ? (dims[:material] = prof01.material) : nothing
            if "S" in args
                prof01.S !== nothing ? (dims[:S] = prof01.S * u"mm^2") : nothing # plocha průřezu [mm^2]
            end
            #prof01.S !== nothing && (dims[:S] = prof01.S * u"mm^2")
            prof01.Ix !== nothing ? (dims[:Ix] = prof01.Ix * u"mm^4") : nothing
            prof01.Iy !== nothing ? (dims[:Iy] = prof01.Iy * u"mm^4") : nothing
            prof01.Ixy !== nothing ? (dims[:Ixy] = prof01.Ixy * u"mm^4") : nothing
            prof01.Wx !== nothing ? (dims[:Wx] = prof01.Wx * u"mm^3") : nothing
            prof01.Wy !== nothing ? (dims[:Wy] = prof01.Wy * u"mm^3") : nothing
            prof01.ix !== nothing ? (dims[:ix] = prof01.ix * u"mm") : nothing
            prof01.iy !== nothing ? (dims[:iy] = prof01.iy * u"mm") : nothing
            prof01.Sx !== nothing ? (dims[:Sx] = prof01.Sx * u"mm^3") : nothing
            prof01.sx !== nothing ? (dims[:sx] = prof01.sx * u"mm") : nothing
            # Přidáme extrahovanou zkratku normy, pokud byla v inputu (IPE)
            if zkratka_extracted !== nothing
                dims[:zkratka] = zkratka_extracted
                dims[:zkratka_info] = "Zkratka pro normu, např. $(zkratka_extracted)"
                # Pokud máme i normu s čísly, přidáme ji
                if norma_extracted !== nothing
                    dims[:standard] = norma_extracted
                end
            end
        end
    elseif profile == "TR4HR"
        prof01 = StrojniSoucasti.profil_TR4HR_CSN425720(clean)
        if prof01 !== nothing
            dims[:info] = "TR4HR"
            prof01.a !== nothing ? (dims[:a] = prof01.a * u"mm") : nothing
            prof01.b !== nothing ? (dims[:b] = prof01.b * u"mm") : nothing
            prof01.t !== nothing ? (dims[:t] = prof01.t * u"mm") : nothing
            prof01.R !== nothing ? (dims[:R] = prof01.R * u"mm") : nothing
            prof01.m !== nothing ? (dims[:m] = prof01.m * u"kg"/u"m") : nothing # hmotnost na jednotku délky [kg/m]
            prof01.standard !== nothing ? (dims[:standard] = prof01.standard) : nothing
            prof01.zkratka !== nothing ? (dims[:zkratka] = prof01.zkratka) : nothing # zkratka pro rychlejší hledání v tabulce
            prof01.material !== nothing ? (dims[:material] = prof01.material) : nothing
            if "S" in args
                prof01.S !== nothing ? (dims[:S] = prof01.S * u"mm^2") : nothing
            end
            prof01.Ix !== nothing ? (dims[:Ix] = prof01.Ix * u"mm^4") : nothing
            prof01.Iy !== nothing ? (dims[:Iy] = prof01.Iy * u"mm^4") : nothing
            prof01.Wx !== nothing ? (dims[:Wx] = prof01.Wx * u"mm^3") : nothing
            prof01.Wy !== nothing ? (dims[:Wy] = prof01.Wy * u"mm^3") : nothing
            prof01.ix !== nothing ? (dims[:ix] = prof01.ix * u"mm") : nothing
            prof01.iy !== nothing ? (dims[:iy] = prof01.iy * u"mm") : nothing
            prof01.Sx !== nothing ? (dims[:Sx] = prof01.Sx * u"mm^3") : nothing
            prof01.sx !== nothing ? (dims[:sx] = prof01.sx * u"mm") : nothing
            # Přidáme extrahovanou zkratku normy, pokud byla v inputu (TR4HR)
            if zkratka_extracted !== nothing
                dims[:zkratka] = zkratka_extracted
                dims[:zkratka_info] = "Zkratka pro normu, např. $(zkratka_extracted)"
                # Pokud máme i normu s čísly, přidáme ji
                if norma_extracted !== nothing
                    dims[:standard] = norma_extracted
                end
            end
        else
            dims = StrojniSoucasti.profilyCSN(clean)
            # Přidáme extrahovanou zkratku normy, pokud byla v inputu
            if dims !== nothing && zkratka_extracted !== nothing
                dims[:zkratka] = zkratka_extracted
                dims[:zkratka_info] = "Zkratka pro normu, např. $(zkratka_extracted)"
                # Pokud máme i normu s čísly, přidáme ji
                if norma_extracted !== nothing
                    dims[:standard] = norma_extracted
                end
            end
        end
    elseif profile in ["PLO", "OBD", "KR", "TRKR", "4HR", "6HR"]
        dims = StrojniSoucasti.profilyCSN(clean)
        # Přidáme extrahovanou zkratku normy, pokud byla v inputu
        if dims !== nothing && zkratka_extracted !== nothing
            dims[:zkratka] = zkratka_extracted
            dims[:zkratka_info] = "Zkratka pro normu, např. $(zkratka_extracted)"
            # Pokud máme i normu s čísly, přidáme ji
            if norma_extracted !== nothing
                dims[:standard] = norma_extracted
            end
        end
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
    # 4) Pokud jsou zadány vlastnosti (S, Ix, Iy, J, Jp, Jt…) nebo hodnoty pro natočení, řeší profilyvlcn nebo přidá natočení
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
