## funkce `gammaM`
## soubor `gammaM.jl`
###############################################################
## Popis funkce:
Vrátí bezpečnostní faktor γM pro zadaný způsob zatížení a druh namáhání.
Podporuje jednoduché i kombinované zatížení a namáhání.
## Vzor:
```julia
gamma = gammaM(Z, N)
```
## Vstupní proměnné:
- `Z` - způsob zatížení, například `"statický"`, `"pulzní"` nebo jejich
  kombinace `"statický-dynamický"`.
- `N` - druh namáhání, například `"tah"`, `"střih"` nebo jejich kombinace
  `"tah-střih"`.

Argumenty lze zadat také v opačném pořadí: `gammaM(N, Z)`. U kombinovaného
namáhání lze zadat jednoduché zatížení; například `gammaM("statický",
"tah-střih")` použije kombinaci `"statický-statický"`.
## Výstupní proměnné:
- `gamma` - bezrozměrný bezpečnostní faktor γM.

Pokud kombinace zatížení a namáhání není podporována, funkce vyvolá chybu.
## Příklad:
```julia
using StrojniSoucasti

gammaM("statický", "tah")
# => 1.3

gammaM("statický", "tah-střih")
# => 1.73
```
