# Profily

Tato stránka dokumentuje funkci `profily`, která slouží k parsování označení profilů a výpočtu jejich geometrických a průřezových charakteristik.

## Dokumentace k funkci `profily.jl`
## Funkce Julia v1.12
###############################################################
## Popis funkce:
Funkce řeší textové označení tvaru profilu dle ČSN a vrací strukturu s rozměry. Volitelně lze zadat výpočet vlastností profilu (plocha, momenty setrvačnosti, průřezové moduly…).

## Vzor:
vystupni_promenne = profily(inputStr, args...; natoceni=0)
## Vstupní proměnné:
- `inputStr` - Textové označení tvaru profilu dle ČSN.
**Podporované tvary:**
*"PLO {a}x{b}" - "PLO 20x10"* - obdélníkový profil
*"PLO {a}x{b}R{r}" - "PLO 20x10R3"* - obdélníkový profil s rádiusem
*"OBD {a}x{b}" - "OBD 20x10"* - obdélníkový profil
*"OBD {a}x{b}R{r}" - "OBD 20x10R3"* - obdélníkový profil s rádiusem
- *"KR {D}" - "KR 20"* - kruhový profil
- *"KR {D}/{d}" - "KR 20/10"* - kruhový profil s vnitřním průměrem (trubka)
- *"TRKR {D}x{t}" - "TRKR 20x2"* - trubkový kruhový profil
- *"4HR {a}" - "4HR 20"* - čtyřhranný profil
- *"4HR {a}R{r}" - "4HR 20R3"* - čtyřhranný profil s rádiusem
- *"4HR {a}x{b}" - "4HR 20x10"* - čtyřhranný profil obdélníkový
- *"4HR {a}x{b}R{r}" - "4HR 20x10R3"* - čtyřhranný profil obdélníkový s rádiusem
- *"6HR {s}" - "6HR 20"* - šestihranný profil
- *"TR4HR {a}x{b}x{t}", "TR4HR {a}x{t}" - "TR4HR 20x20x2", "TR4HR 20x2"* - trubkový čtyřhranný profil dle ČSN 425720
- *"TR4HR {a}x{b}x{t}", "TR4HR {a}x{t}" - "TR4HR 20x20x2", "TR4HR 20x2"* - trubkový čtyřhranný profil
- *"TR4HR {a}x{b}x{t}R{r}", "TR4HR {a}x{t}R{r}" - "TR4HR 20x20x2R3", "TR4HR 20x2R3"* - trubkový čtyřhranný profil s rádiusem
- *"I {n}"* - I profil dle ČSN 425550
- *"IPE {n}"* - IPE profil dle ČSN 425553
- `args...` - Volitelné názvy vlastností k výpočtu.
- *"S", "A"* - plocha průřezu [mm^2]
- *"I"* - moment setrvačnosti (dle natoceni) [mm^4]
- *"Ix"* - moment setrvačnosti Ix [mm^4]
- *"Iy"* - moment setrvačnosti Iy [mm^4]
- *"Ixy"* - kvadratický moment součinitele [mm^4] (pro výpočet I pro dané natočení)
- *"Imin"* - minimální moment setrvačnosti [mm^4]
- *"Imax"* - maximální moment setrvačnosti [mm^4]
- *"Wx"* - průřezový modul pro ohyb pro osu x [mm^3]
- *"Wy"* - průřezový modul pro ohyb pro osu y [mm^3]
- *"Wo"* - průřezový modul pro ohyb (dle natočení) [mm^3]
- *"Ip", "Jp"* - polární moment setrvačnosti [mm^4]
- *"It", "Jt"* - torzní moment [mm^3]
- *"J"* - polární (torzní) moment setrvačnosti pro krut [mm^4]
- *"Wk"* - průřezový modul pro krut [mm^3]
- *"Wt"* - torzní průřezový modul [mm^3]
- *"Wp"* - Průřezový modul pro krut polární [mm^3]
- *"ix"* -
- *"iy"* -
- *"i"* -
- *"Sx"* -
- *"sx"* -
- `Natoceni` - úhel natočení profilu (volitelný parametr pro výpočet Ix a Wo) (výchozí hodnota 0) [rad]
## Výstupní proměnné:
- `dims` - Struktura (Dict) s rozměry profilu a případně i s vypočtenými vlastnostmi.
## Příklad:
```julia
dims = profily("PLO 20x10") # pouze rozměry
println(dims[:a]) # => 20 mm
println(dims[:b]) # => 10 mm
dims = profily("KR 30") # pouze rozměry
println(dims[:D]) # => 30 mm
dims = profily("TRKR 50x5") # pouze rozměry
println(dims[:D]) # => 50 mm
println(dims[:d]) # => 40 mm
println(dims[:t]) # => 5 mm
dims = profily("4HR 25") # pouze rozměry
println(dims[:a]) # => 25 mm
dims = profily("OBD 40x20") # pouze rozměry
println(dims[:a]) # => 40 mm
println(dims[:b]) # => 20 mm
dims = profily("6HR 15") # pouze rozměry
println(dims[:s]) # => 15 mm
dims = profily("TR4HR 60x40x4") # pouze rozměry
println(dims[:a]) # => 60 mm
println(dims[:b]) # => 40 mm
println(dims[:t]) # => 4 mm
dims = profily("TRKR 100x10R3", "S", "Ix", "Iy") # rozměry + vlastnosti
println(dims[:D]) # => 100 mm
println(dims[:d]) # => 80 mm
println(dims[:t]) # => 10 mm
println(dims[:S]) # => plocha v mm^2
println(dims[:Ix]) # => moment setrvačnosti Ix v mm^4
println(dims[:Iy]) # => moment setrvačnosti Iy v mm^4
dims = profily("TR4HR 60x40x4") # pouze rozměry
dims = profily("PLO 20x10", "S", "Ix", "Iy") # rozměry + vlastnosti
dims = profily("TR4HR 50x30x5", "S", "Ix") # rozměry + vlastnosti U profilu
```

## Popis
Funkce `profily.jl` slouží k analýze profilů a jejich vyhodnocení.

## Parametry
- `data`: (DataFrame) Tabulka obsahující vstupní data.
- `parametry`: (Dictionary) Slovník s parametry potřebnými pro analýzu.

## Známé tvary
- **PLO** obdélníková tyč
    PLO {a} , PLO {a}x{b}
    a - strana obdélníku x, strana čtverce
    b - strana obdélníku y
- **OBD** obdélníková tyč
    OBD {a} , OBD {a}x{b}
    a - strana obdélníku x, strana čtverce
    b - strana obdélníku y
- **4HR** obdélníková tyč
    4HR {a} , 4HR {a}x{b}
    a - strana obdélníku x, strana čtverce
    b - strana obdélníku y
- **KR** kruhová tyč
    KR {D} , ( KR {D}/{d} )
    D - velký průměr
    d - ( malý průměr )
- **TRKR** trubka kruhová
    TRKR {D}x{t}
    D - velký průměr
    t - tloušťka stěny
- **6HR** šestihranná tyč
    6HR {s}
    s - rozteč rovnoběžek šestihrannu (na klíč)
- **TR4HR** trubka čtyřhranná
    TR4HR {a}x{t} , TR4HR {a}x{a}x{t} , TR4HR {a}x{b}x{t}
    a - strana obdélníku x, strana čtverce
    b - strana obdélníku y
    t - tloušťka
- **I** I profil
    I {a}
    a - rozměr
- **IPE** IPE profil
    IPE {a}
    a - rozměr

## Návratové hodnoty
Vrací (List) seznam profilů vyhodnocených na základě zadaných dat a parametrů.

## Příklady
```julia
result = profily(data, parametry)
```

## Poznámky
Funkce vyžaduje správně naformátovaný DataFrame a může vyžadovat dodatečné knihovny pro analýzu dat.
