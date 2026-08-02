## funkce `profiltvary.jl`
## Funkce Julia v1.12
###############################################################
## Popis funkce:
Funkce řeší textové označení tvaru dle ČSN a vrací strukturu s rozměry.
### Parametry
Funkce podporuje následující typy profilů:
- **PLO**: Popis pro PLO
- **OBD**: Popis pro OBD
- **KR**: Popis pro KR
- **TRKR**: Popis pro TRKR
- **4HR**: Popis pro 4HR
- **6HR**: Popis pro 6HR
- **I**: Popis pro I profily
- **TR4HR**: Popis pro TR4HR
## Vzor:
vystupni_promenne = profiltvary(inputStr)
## Vstupní proměnné:
- `inputStr` - Textové označení tvaru dle ČSN.
**Podporované tvary:**
- *"PLO"* - obdélníkový profil
*"PLO {a}x{b}" - "PLO 20x10"* - obdélníkový profil
*"PLO {a}x{b}R{r}" - "PLO 20x10R3*" - obdélníkový profil s rádiusem
- *"OBD"* - obdélníkový profil
*"OBD {a}x{b}" - "OBD 20x10"* - obdélníkový profil
*"OBD {a}x{b}R{r}" - "OBD 20x10R3"* - obdélníkový profil s rádiusem
- *"KR"* - kruhový profil
*"KR {D}" - "KR 20"* - kruhový profil
- *"TRKR"* - trubkový kruhový profil
*"TRKR {D}x{t}" - "TRKR 20x2"* - trubkový kruhový profil
- *"4HR"* - čtyřhranný profil
*"4HR {a}" - "4HR 20"* - čtyřhranný profil
*"4HR {a}R{r}" - "4HR 20R3"* - čtyřhranný profil s rádiusem
*"4HR {a}x{b}" - "4HR 20x10"* - čtyřhranný profil obdélníkový
*"4HR {a}x{b}R{r}" - "4HR 20x10R3"* - čtyřhranný profil obdélníkový s rá
- *"6HR"* - šestihranný profil
*"6HR {s}" - "6HR 20"* - šestihranný profil
- *"I"* - I profil bez zaoblení
*"I {n}" - "I 100"*
- *"TR4HR"* - trubkový čtyřhranný profil
*"TR4HR {a}x{b}x{t}" - "TR4HR 20x20x2"* - trubkový čtyřhranný profil
*"TR4HR {a}x{b}x{t}R{r}" - "TR4HR 20x20x2R3"* - trubkový čtyřhranný profil s rádiusem
- `args...` - (nepoužito)
## Výstupní proměnné:
- `dims` - Struktura (Dict) s rozměry a informacemi o tvaru, např.: Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm", "R" => 3u"mm")
## Příklad:
```julia
dims = profiltvary("PLO 20x10R3")
dims == Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm", "R" => 3u"mm")

dims = profilyCSN("KR 20")
dims == Dict("info" => "KR", "D" => 20u"mm")
```
