# Dokumentace k funkci `profily.jl`

## Popis
Funkce `profily.jl` slouží k analýze profilů a jejich vyhodnocení.

## Parametry
- `data`: (DataFrame) Tabulka obsahující vstupní data.
- `parametry`: (Dictionary) Slovník s parametry potřebnými pro analýzu.

## Známé tvary
- **PLO** obdélníková tyč
    PLO {a} , PLO {a}x{b}
    a - strana obdélníku x, strana čtverce
    b - strana obdélníku y
- **OBD** obdélníková tyč
    OBD {a} , OBD {a}x{b}
    a - strana obdélníku x, strana čtverce
    b - strana obdélníku y
- **4HR** obdélníková tyč
    4HR {a} , 4HR {a}x{b}
    a - strana obdélníku x, strana čtverce
    b - strana obdélníku y
- **KR** kruhová tyč
    KR {D} , ( KR {D}/{d} )
    D - velký průměr
    d - ( malý průměr )
- **TRKR** trubka kruhová
    TRKR {D}x{t}
    D - velký průměr
    t - tloušťka stěny
- **6HR** šestihranná tyč
    6HR {s}
    s - rozteč rovnoběžek šestihrannu (na klíč)
- **TR4HR** trubka čtyřhranná
    TR4HR {a}x{t} , TR4HR {a}x{a}x{t} , TR4HR {a}x{b}x{t}
    a - strana obdélníku x, strana čtverce
    b - strana obdélníku y
    t - tloušťka
- **I** I profil
    I {a}
    a - rozměr
- **IPE** IPE profil
    IPE {a}
    a - rozměr

## Návratové hodnoty
Vrací (List) seznam profilů vyhodnocených na základě zadaných dat a parametrů.

## Příklady
```julia
result = profily(data, parametry)
```

## Poznámky
Funkce vyžaduje správně naformátovaný DataFrame a může vyžadovat dodatečné knihovny pro analýzu dat.