# StrojniSoucasti

`StrojniSoucasti` je balíček v jazyce Julia pro technické výpočty ve strojírenství.
Zaměřuje se hlavně na:

- výpočty namáhání strojních součástí (tah, tlak, krut, střih, ohyb, kombinované namáhání),
- práci s materiály a dovolenými napětími,
- práci s profily,
- pomocné funkce pro ukládání výstupů a závity.

## Instalace

Balíček lze nainstalovat přes správce balíčků Julia:

```julia
using Pkg
Pkg.add(url="https://github.com/markrcmarik-beep/StrojniSoucasti")
```

Načtení balíčku:

```julia
using StrojniSoucasti
```

## Rychlý start

```julia
using StrojniSoucasti

mat = materialy("S235")
println(mat)

# příklad výpočtu namáhání v tahu
# (konkrétní vstupní parametry viz dokumentace funkcí)
# result = namahanitah(...)
```

## Hlavní exportované funkce

- `materialy`, `dovoleneNapeti`, `mezUnavy`
- `tvarprofilu`, `profily`
- `namahanitah`, `namahanitlak`, `namahanikrut`, `namahanistrih`
- `namahaniohyb`, `namahaniotl`, `namahanikombinovane`
- `ulozvypis`, `zavity`

## Dokumentace

Doplňující dokumentace je ve složce `docs/`.

## Kompatibilita

- Julia `1.12`

## Licence

Projekt je licencován pod licencí MIT. Podrobnosti viz soubor [LICENSE](LICENSE).
