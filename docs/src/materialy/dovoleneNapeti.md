## funkce `dovoleneNapeti` 
## soubor `dovoleneNapeti.jl`
###############################################################
## Popis funkce:
Vrátí dovolené napětí materiálu podle jedné z veličin v daném pořadí
(`Re`, `Rm`, `Rp0.1`, `Rp0.2`) , druhu namáhání `N`, způsobu zatížení `Z`.
## Vzor:
```julia
sigma = dovoleneNapeti(mez, N, Z)
```
## Vstupní proměnné:
- `mez`- Zapsat: `Re=...`, `Rm=...`, `Rp0.1=...`, `Rp0.2=...` mez bez jednotky (např. `250`), pokud je bez jednotky, jednotka MPa se doplní. Mez s jednotkou (např. `250u"MPa"`)
- `mat`- výstup z `materialy(...)`. Pokud není zadáno `Re`, použije se `mat.Re`.
- `N`- druh namáhání jako řetězec (např. `"tah"`, `"tlak"`, `"střih"`,
  `"ohyb"`, `"krut"`, kombinace jako `"tah-střih"`).
- `Z`- způsob zatížení jako řetězec (např. `"statický"`, `"pulzní"`,
  `"dynamický"`, `"rázový"`, kombinace jako `"statický-dynamický"`).
## Výstupní proměnné:
- `sigma` - dovolené napětí s jednotkou [`MPa`].
## Příklad:
```julia
dovoleneNapeti(250u"MPa", "tah", "statický")
```
vrátí dovolené napětí pro materiál s mezí kluzu 250 MPa při statickém tahu
```julia
=> 192.3076923076923 MPa
```
```julia
dovoleneNapeti(250u"MPa", "střih", "dynamický")
```
vrátí dovolené napětí pro materiál s mezí kluzu 250 MPa při dynamickém střihu
```julia
=> 57.73502691896258 MPa
```
