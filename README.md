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
```

## Hlavní exportované funkce

- `ulozvypis` - 
- `hridel` - 
### body
- `bddb2b` - 
- `bdu2b` - 
- `brsb2body` - 
- `burub2body` - 
- `buub2b` - 
- `bux2b` - 
- `posun_body` - 
- `rotuj_body` - 
- `ubru2bb` - 
- `uu2u` - 
### materialy
- `materialy` - 
- `dovoleneNapeti` - 
- `mezUnavy` - 
### namahani
- `namahanitah` - 
- `namahanitlak` - 
- `namahanikrut` - 
- `namahanistrih` - 
- `namahaniohyb` - 
- `namahaniotl` - 
- `namahanikombinovane` - 
- `StrojniSoucasti.namahanitahtext` - 
- `StrojniSoucasti.namahanitlaktext` - 
- `StrojniSoucasti.namahanikruttext` - 
- `StrojniSoucasti.namahanistrihtext` - 
- `StrojniSoucasti.namahaniohybtext` - 
- `StrojniSoucasti.namahanikombinovanetext` - 
### profily
- `profily` - Vypočítá průřezové charakteristiky pro zadaný profil (např. "L 20x20x3").
- `tvarprofilu` - Vrátí body pro vykreslení tvaru zadaného profilu.
- `StrojniSoucasti.body_drazka4pero` - Generuje body pro drážku pro pero.
- `StrojniSoucasti.body_drazka4vysec` - Generuje body pro drážku ve tvaru kruhové výseče.
- `StrojniSoucasti.body_drazka_obdelnik` - Generuje body pro obdélníkovou drážku.
- `StrojniSoucasti.body_profil_I` - Generuje body pro profil tvaru I.

### tolerance
- `tolerance` - 
### zavity
- `zavity` - 

## Dokumentace

Doplňující dokumentace je ve složce `docs/`.

## Kompatibilita

- Julia `1.12`

## Licence

Projekt je licencován pod licencí MIT. Podrobnosti viz soubor [LICENSE](LICENSE).
