## funkce `tolerance.jl`
## Funkce Julia v1.12
###############################################################
## Popis funkce:
Funkce pro výpočet tolerancí podle tabulek (ČSN/ISO). Funkce vrátí toleranci podle zápisu např. "40H8" nebo "10f7".
## Vzor:
`vystupni_promenne = tolerance(vstupni_promenne)`
## Vstupní proměnné:
- `spec::AbstractString` - Zápis tolerance ve formátu "40H8" nebo "10f7".
- `nominal::Real` - Jmenovitý rozměr v mm.
- `zone::AbstractString` - Zóna tolerance (např. "H" pro díru, "f" pro hřídel).
- `grade::Integer` - Stupeň tolerance (např. 7, 8, 9).
## Výstupní proměnné:
- `nominal` - Jmenovitý rozměr v mm.
- `zone` - Zóna tolerance.
- `grade` - Stupeň tolerance.
- `type` - Typ tolerance (:hole pro díru, :shaft pro hřídel).
- `es` - Horní mez tolerance (v mm).
- `ei` - Dolní mez tolerance (v mm).
- `min` - Minimální rozměr (v mm).
- `max` - Maximální rozměr (v mm).
- `tol` - Tolerance (v mm).
- `unit` - Jednotka (vždy "mm").
## Příklad:
```julia
using StrojniSoucasti

zavit_metricky = zavity("M10x1.25")
println("Metrický závit: Průměr d = $(zavit_metricky[:d]) mm, Stoupání p = $(zavit_metricky[:p]) mm")

zavit_trapezovy = zavity("TR20x4")
println("Trapézový závit: Průměr d = $(zavit_trapezovy[:d]) mm, Stoupání p = $(zavit_trapezovy[:p]) mm")
```