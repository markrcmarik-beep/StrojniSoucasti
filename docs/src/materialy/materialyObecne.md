## funkce `materialyObecne`
## soubor `materialyObecne.jl`
## Funkce Julia v1.13
###############################################################
## Popis funkce:
Vyhledá materiál podle obecného názvu v předané databázi a vrátí slovník jeho
údajů. Zadaný název porovnává s hodnotou `name` a postupně prohledává kategorie
oceli, litiny, pryže, neželezných kovů, plastů a dřeva. Nejde o vyhledávání
podle označení konkrétní normy; pro ně jsou určeny funkce `materialyCSN`,
`materialyEN`, `materialyDIN` a `materialyISO`.
## Vzor:
`vystupni_promenne = materialyObecne(db, name)`
## Vstupní proměnné:
- `db` – otevřená databáze SQLite s tabulkami materiálů (např. `SQLite.DB`).
- `name::AbstractString` – obecný název materiálu odpovídající hodnotě `name`
  v databázi, například `"NBR70"` nebo `"CuCr"`.
## Výstupní proměnné:
- `mat::Union{Dict{String, Any}, Nothing}` – slovník údajů o nalezeném
  materiálu, nebo `nothing`, pokud materiál v databázi nalezen nebyl.

Slovník obsahuje společné klíče, například `name`, `name_ISO`, `znacka_EN`,
`cislo_EN`, `name_CSN`, `name_DIN`, `norma_CSN`, `druh`, `VVnormy` a `VVdruh`.
Dostupné klíče s vlastnostmi a popisnými údaji závisí na druhu materiálu.
Patří mezi ně například `Re`, `Rm_min`, `Rm_max`, `A`, `E`, `G`, `ny`, `rho`
a odpovídající klíče jednotek s příponou `_unit`. Nevyplněné číselné
vlastnosti mohou mít hodnotu `missing`.

Příklady čtení:
   - `mat["name"]` – obecný název materiálu
   - `mat["druh"]` – druh nebo bližší popis materiálu
   - `mat["rho"]` a `mat["rho_unit"]` – hustota a její jednotka, jsou-li dostupné
   - `mat["E"]` a `mat["E_unit"]` – modul pružnosti a jeho jednotka, jsou-li dostupné
## Příklad:
```julia
using StrojniSoucasti
using SQLite

db = SQLite.DB(joinpath(StrojniSoucasti.cesta_materialy, "materialy.db"))
mat = StrojniSoucasti.materialyObecne(db, "NBR70")
if mat !== nothing
    println(mat["name"])
    println(mat["druh"])
end
```




# Materialy

## Funkce `materialyObecne`

```@docs
StrojniSoucasti.materialyObecne
```

## Poznamky k databazim
- Materiály jsou načítány z databáze `materialy.db`.
- Obecný název se vyhledává v poli `name` u jednotlivých typů materiálů.

## Priklady

```julia
using StrojniSoucasti
using SQLite

db = SQLite.DB(joinpath(StrojniSoucasti.cesta_materialy, "materialy.db"))
mat = StrojniSoucasti.materialyObecne(db, "CuCr")
mat["druh"]
```
