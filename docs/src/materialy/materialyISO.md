## funkce `materialyISO`
## soubor `materialyISO.jl`
## Funkce Julia v1.13
###############################################################
## Popis funkce:
Vyhledá materiál podle označení ISO v předané databázi a vrátí slovník jeho
údajů. Vyhledává v kategoriích oceli, litiny, pryže, neželezných kovů, plastů
a dřeva. Označení se porovnává s hodnotou `name_ISO` uloženou v databázi.
## Vzor:
`vystupni_promenne = materialyISO(db, name)`
## Vstupní proměnné:
- `db` – otevřená databáze SQLite s tabulkami materiálů (např. `SQLite.DB`).
- `name::AbstractString` – označení materiálu podle ISO, například `"Cu-ETP"`
  nebo `"PA 6-C/Oil"`.
## Výstupní proměnné:
- `mat::Union{Dict{String, Any}, Nothing}` – slovník údajů o nalezeném
  materiálu, nebo `nothing`, pokud materiál v databázi nalezen nebyl.

Slovník obsahuje společné klíče, například `name`, `name_ISO`, `name_CSN`,
`norma_CSN`, `druh`, `VVnormy` a `VVdruh`. Dostupné klíče s vlastnostmi a
popisnými údaji závisí na druhu materiálu. Patří mezi ně například `Re`,
`Rm_min`, `Rm_max`, `A`, `E`, `G`, `ny`, `rho` a odpovídající klíče jednotek
s příponou `_unit`. Nevyplněné číselné vlastnosti mohou mít hodnotu `missing`.

Příklady čtení:
   - `mat["name_ISO"]` – označení podle ISO
   - `mat["druh"]` – druh nebo bližší popis materiálu
   - `mat["rho"]` a `mat["rho_unit"]` – hustota a její jednotka, jsou-li dostupné
   - `mat["E"]` a `mat["E_unit"]` – modul pružnosti a jeho jednotka, jsou-li dostupné
## Příklad:
```julia
using StrojniSoucasti
using SQLite

db = SQLite.DB(joinpath(StrojniSoucasti.cesta_materialy, "materialy.db"))
mat = StrojniSoucasti.materialyISO(db, "Cu-ETP")
if mat !== nothing
    println(mat["name_ISO"])
    println(mat["rho"], " ", mat["rho_unit"])
end
```




# Materialy

## Funkce `materialyISO`

```@docs
StrojniSoucasti.materialyISO
```

## Poznamky k databazim
- Materiály jsou načítány z databáze `materialy.db`.
- Název ISO se vyhledává v poli `name_ISO` u jednotlivých typů materiálů.

## Priklady

```julia
using StrojniSoucasti
using SQLite

db = SQLite.DB(joinpath(StrojniSoucasti.cesta_materialy, "materialy.db"))
mat = StrojniSoucasti.materialyISO(db, "PA 6-C/Oil")
mat["druh"]
```
