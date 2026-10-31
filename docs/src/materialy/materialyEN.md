## funkce `materialyEN`
## soubor `materialyEN.jl`
## Funkce Julia v1.13
###############################################################
## Popis funkce:
Vyhledá materiál podle značky nebo čísla EN v předané databázi a vrátí slovník
jeho údajů. Vyhledává v kategoriích oceli, litiny, pryže, neželezných kovů,
plastů a dřeva. Značka EN se hledá v poli `znacka_EN`, číslo EN v poli
`cislo_EN`.
## Vzor:
`vystupni_promenne = materialyEN(db, name)`
## Vstupní proměnné:
- `db` – otevřená databáze SQLite s tabulkami materiálů (např. `SQLite.DB`).
- `name::AbstractString` – značka nebo číslo materiálu podle EN, například
  `"S235JRG1"` nebo `"1.0036"`.
## Výstupní proměnné:
- `mat::Union{Dict{String, Any}, Nothing}` – slovník údajů o nalezeném
  materiálu, nebo `nothing`, pokud materiál v databázi nalezen nebyl.

Slovník obsahuje společné klíče, například `name`, `znacka_EN`, `cislo_EN`,
`name_CSN`, `norma_CSN`, `druh`, `VVnormy` a `VVdruh`. Dostupné klíče
s vlastnostmi a popisnými údaji závisí na druhu materiálu. Patří mezi ně
například `Re`, `Rm_min`, `Rm_max`, `A`, `E`, `G`, `ny`, `rho` a odpovídající
klíče jednotek s příponou `_unit`. Nevyplněné číselné vlastnosti mohou mít
hodnotu `missing`.

Příklady čtení:
   - `mat["znacka_EN"]` – značka materiálu podle EN
   - `mat["cislo_EN"]` – číselné označení materiálu podle EN
   - `mat["druh"]` – druh nebo bližší popis materiálu
   - `mat["Re"]` a `mat["Re_unit"]` – mez kluzu a její jednotka, jsou-li dostupné
## Příklad:
```julia
using StrojniSoucasti
using SQLite

db = SQLite.DB(joinpath(StrojniSoucasti.cesta_materialy, "materialy.db"))
mat = StrojniSoucasti.materialyEN(db, "S235JRG1")
if mat !== nothing
    println(mat["znacka_EN"], " (", mat["cislo_EN"], ")")
    println(mat["Re"], " ", mat["Re_unit"])
end
```




# Materialy

## Funkce `materialyEN`

```@docs
StrojniSoucasti.materialyEN
```

## Poznamky k databazim
- Materiály jsou načítány z databáze `materialy.db`.
- Značka EN se vyhledává v poli `znacka_EN` a číslo EN v poli `cislo_EN`.

## Priklady

```julia
using StrojniSoucasti
using SQLite

db = SQLite.DB(joinpath(StrojniSoucasti.cesta_materialy, "materialy.db"))
mat = StrojniSoucasti.materialyEN(db, "1.0036")
mat["druh"]
```
