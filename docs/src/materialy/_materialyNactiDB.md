## funkce `_materialyNactiDB`
## soubor `_materialyNactiDB.jl`
## Funkce Julia v1.13
###############################################################
## Popis funkce:
Interní pomocná funkce, která vyhledá materiál v předané databázi SQLite podle
zadaného sloupce a označení. Načte jeho společné údaje, vlastnosti a jednotky
a sestaví je do slovníku. Funkce je používána vyhledávacími funkcemi
`materialyCSN`, `materialyEN`, `materialyDIN`, `materialyISO` a
`materialyObecne`; pro běžné použití se doporučuje volat jednu z nich.
## Vzor:
`mat = StrojniSoucasti._materialyNactiDB(db, name, celeoznaceni, VVnormy, VVdruh)`
## Vstupní proměnné:
- `db` – otevřená databáze SQLite obsahující tabulky materiálů a veličin.
- `name` – název sloupce použitý pro vyhledání. Podle používané
  vyhledávací funkce jde například o `name`, `name_CSN`, `name_ISO`,
  `name_DIN`, `znacka_EN` nebo `cislo_EN`.
- `celeoznaceni` – hodnota, která se hledá v uvedeném sloupci.
- `VVnormy` – označení zdroje, které se vloží do výsledku jako `VVnormy`
  (například `"ČSN"`, `"EN"`, `"DIN"`, `"ISO"` nebo `"obecne"`).
- `VVdruh` – kategorie materiálu, která se vloží do výsledku jako `VVdruh`.
  Podporované hodnoty jsou `"ocel"`, `"litina"`, `"pryz"`,
  `"nezelezne kovy"`, `"plasty"` a `"drevo"`.
## Výstupní proměnné:
- `mat::Union{Dict{String, Any}, Nothing}` – slovník údajů nalezeného
  materiálu, nebo `nothing`, pokud záznam v databázi neexistuje.
  Nepodporovaná hodnota `VVdruh` vyvolá chybu.

Výsledek obsahuje klíče pro označení (`name`, `name_ISO`, `znacka_EN`,
`cislo_EN`, `name_CSN`, `name_DIN`), `norma_CSN`, `druh`, `VVnormy` a
`VVdruh`. Podle kategorie zahrnuje také popisné údaje a měřené vlastnosti,
například `Re`, `Rm_min`, `A`, `E`, `G`, `ny` a `rho`, s příslušnými klíči
jednotek `_unit`. Nedostupné číselné hodnoty jsou `missing`; nevyplněné textové
údaje jsou prázdné řetězce. Pro ocel obsahuje výsledek také `Re_rozsahy`
s hodnotami meze kluzu podle rozsahu tloušťky.
## Příklad:
```julia
using StrojniSoucasti
using SQLite

db = SQLite.DB(joinpath(StrojniSoucasti.cesta_materialy, "materialy.db"))
mat = StrojniSoucasti._materialyNactiDB(
    db, "name_CSN", "11373", "ČSN", "ocel")
if mat !== nothing
    println(mat["name_CSN"])
    println(mat["Re"], " ", mat["Re_unit"])
end
```




# Materialy

## Funkce `_materialyNactiDB`

```@docs
StrojniSoucasti._materialyNactiDB
```

## Poznamky k databazim
- Funkce pracuje s tabulkami materiálů a veličin v databázi `materialy.db`.
- Jde o interní pomocnou funkci; pro vyhledávání materiálů používejte
  uživatelské funkce podle požadovaného typu označení.

## Priklad

```julia
mat = StrojniSoucasti._materialyNactiDB(
    db, "name_CSN", "422420", "ČSN", "litina")
mat["druh"]
```
