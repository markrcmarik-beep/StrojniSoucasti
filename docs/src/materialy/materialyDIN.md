## funkce `materialyDIN`
## soubor `materialyDIN.jl`
## Funkce Julia v1.13
###############################################################
## Popis funkce:
Vyhledá materiál podle označení DIN v předané databázi a vrátí slovník jeho
údajů. Vyhledává v kategoriích oceli, litiny, pryže, neželezných kovů, plastů
a dřeva. Označení se porovnává s hodnotou `name_DIN` uloženou v databázi.
## Vzor:
`vystupni_promenne = materialyDIN(db, name)`
## Vstupní proměnné:
- `db` – otevřená databáze SQLite s tabulkami materiálů (např. `SQLite.DB`).
- `name::AbstractString` – označení materiálu podle DIN, například `"C45"`
  nebo `"GG25"`.
## Výstupní proměnné:
- `mat::Union{Dict{String, Any}, Nothing}` – slovník údajů o nalezeném
  materiálu, nebo `nothing`, pokud materiál v databázi nalezen nebyl.

Slovník obsahuje společné klíče, například `name`, `name_DIN`, `name_CSN`,
`norma_CSN`, `druh`, `VVnormy` a `VVdruh`. Dostupné klíče s vlastnostmi a
popisnými údaji závisí na druhu materiálu. Patří mezi ně například `Re`,
`Rm_min`, `Rm_max`, `A`, `E`, `G`, `ny`, `rho` a odpovídající klíče jednotek
s příponou `_unit`. Nevyplněné číselné vlastnosti mohou mít hodnotu `missing`.

Příklady čtení:
   - `mat["name_DIN"]` – označení podle DIN
   - `mat["druh"]` – druh nebo bližší popis materiálu
   - `mat["Re"]` a `mat["Re_unit"]` – mez kluzu a její jednotka, jsou-li dostupné
   - `mat["E"]` a `mat["E_unit"]` – modul pružnosti a jeho jednotka, jsou-li dostupné
## Příklad:
```julia
using StrojniSoucasti
using SQLite

db = SQLite.DB(joinpath(StrojniSoucasti.cesta_materialy, "materialy.db"))
mat = StrojniSoucasti.materialyDIN(db, "C45")
if mat !== nothing
    println(mat["name_DIN"])
    println(mat["druh"])
end
```




# Materialy

## Funkce `materialyDIN`

```@docs
StrojniSoucasti.materialyDIN
```

## Poznamky k databazim
- Materiály jsou načítány z databáze `materialy.db`.
- Označení DIN se vyhledává v poli `name_DIN` u jednotlivých typů materiálů.

## Priklady

```julia
using StrojniSoucasti
using SQLite

db = SQLite.DB(joinpath(StrojniSoucasti.cesta_materialy, "materialy.db"))
mat = StrojniSoucasti.materialyDIN(db, "GG25")
mat["druh"]
```
