# StrojniSoucasti

`StrojniSoucasti` je balíček v jazyce Julia pro technické výpočty ve strojírenství.
Aktuálně pokrývá práci s materiály, dovolenými napětími, profily, základními druhy
namáhání, závity a ukládání textových výstupů.

## Co balíček umí

- **Materiály**: vyhledání vlastností materiálu z interních databází (`materialy`).
- **Dovolená napětí a únava**: výpočet `dovoleneNapeti` a `mezUnavy`.
- **Profily**: parsování označení profilů a výpočet průřezových charakteristik (`profily`, `tvarprofilu`).
- **Namáhání**: výpočty pro tah, tlak, krut, střih, ohyb, otlačení a kombinované stavy.
- **Závity**: načtení parametrů závitů podle označení (`zavity`).
- **Výstupy**: uložení textového výpisu do souboru (`ulozvypis`).

## Rychlý start

```julia
using StrojniSoucasti
using Unitful

# 1) Materiál
mat = materialy("S235")
Re = mat.Re * u"MPa"

# 2) Dovolené napětí pro tah
sigma_dov = dovoleneNapeti("tah", "statický"; Re=Re)

# 3) Jednoduchý výpočet namáhání v tahu
VV, txt = namahanitah(F=1000u"N", S=50u"mm^2", sigmaDt=sigma_dov)
```

Podrobný návod je v kapitole [Použití balíčku](pouziti.md) a kompletní seznam API v [API](api.md).
