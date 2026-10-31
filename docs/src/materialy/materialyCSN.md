## funkce `materialyCSN`
## soubor `materialyCSN.jl`
## Funkce Julia v1.13
###############################################################
## Popis funkce:
Vyhledá materiál podle označení ČSN v předané databázi a vrátí slovník jeho
údajů. Rozpoznává oceli s číselným označením ze skupin 10–17 a 19 a materiály
se čtyřmístným označením skupiny 42. Výsledek podle nalezeného záznamu může
představovat ocel, litinu, pryž, neželezný kov nebo plast. Pro vyhledání se
používá také přesné označení zadané v databázi; plasty se vyhledávají tímto
přesným označením.
## Vzor:
`vystupni_promenne = materialyCSN(db, name)`
## Vstupní proměnné:
- `db` – otevřená databáze SQLite s tabulkami materiálů (např. `SQLite.DB`).
- `name::AbstractString` – označení materiálu. U číselného označení oceli
  nebo skupiny 42 lze zadat mezeru mezi skupinou a číslem a volitelný index
  za tečkou, například `"11 373"`, `"11 373.1"` nebo `"42 2420"`.
  U ocelí lze za označení připojit poznámky oddělené čárkou; rozpoznané
  varianty poznámek se sjednotí podle databáze poznámek.
## Výstupní proměnné:
- `mat::Union{Dict{String, Any}, Nothing}` – slovník údajů o nalezeném
  materiálu, nebo `nothing`, pokud materiál v databázi nalezen nebyl.

Slovník obsahuje společné klíče, například `name`, `name_CSN`, `norma_CSN`,
`druh`, `VVnormy`, `VVdruh`, `stav`, `zpracovani`, `vlastnosti` a `pouziti`.
Dostupné klíče s vlastnostmi závisí na druhu materiálu. Patří mezi ně například
`Re`, `Rm_min`, `Rm_max`, `A`, `E`, `G`, `ny`, `rho` a odpovídající klíče
jednotek s příponou `_unit`; pro ocel jsou k dispozici také údaje jako
`svaritelnost` a `Re_rozsahy`. Nevyplněné číselné vlastnosti mohou mít hodnotu
`missing`.

Příklady čtení:
   - `mat["name"]` – název materiálu
   - `mat["name_CSN"]` – označení podle ČSN
   - `mat["Re"]` a `mat["Re_unit"]` – mez kluzu a její jednotka, jsou-li dostupné
   - `mat["E"]` a `mat["E_unit"]` – modul pružnosti a jeho jednotka
## Příklad:
```julia
using StrojniSoucasti
using SQLite

db = SQLite.DB(joinpath(StrojniSoucasti.cesta_materialy, "materialy.db"))
mat = StrojniSoucasti.materialyCSN(db, "11 373")
if mat !== nothing
    println(mat["name_CSN"])
    println(mat["Re"], " ", mat["Re_unit"])
end
```




# Materialy

## Funkce `materialyCSN`

```@docs
StrojniSoucasti.materialyCSN
```

## Poznamky k databazim
- Materiály jsou načítány z databáze `materialy.db`.
- Varianty poznámek u označení ocelí se mapují podle `materialy_poznamky.toml`.

## Priklady

```julia
using StrojniSoucasti
using SQLite

db = SQLite.DB(joinpath(StrojniSoucasti.cesta_materialy, "materialy.db"))
mat = StrojniSoucasti.materialyCSN(db, "42 2420")
mat["druh"]
```
