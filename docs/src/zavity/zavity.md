## funkce `zavity.jl`
## Funkce Julia v1.12
###############################################################
## Popis funkce:
Funkce slouží k vyhledání parametrů závitů podle jejich standardního textového označení.
Podporuje metrické (M) a trapézové (Tr) závity. Data načítá z interních `.toml` databází.

## Vzor:
`vystupni_promenne = zavity(oznaceni)`

## Vstupní proměnné:
- `oznaceni` - Textové označení závitu jako řetězec.

**Podporované formáty:**
- **Metrický závit (M):**
  - `M{průměr}` (např. `"M8"`) - pro standardní stoupání.
  - `M{průměr}x{stoupání}` (např. `"M8x1"`) - pro jemné stoupání.
  - Rozpoznává `x` i `X` a desetinnou čárku i tečku.

- **Trapézový závit (Tr):**
  - `TR{průměr}x{stoupání}` (např. `"TR20x4"`).
  - Zápis `Tr`, `tR`, `tr` je také akceptován.

**Nepodporované závity:**
- Funkce v současné verzi nepodporuje trubkové závity (G, R, Rp, NPT, BSP atd.). Při pokusu o jejich použití vyhodí chybu.

## Výstupní proměnné:
- `vystupni_promenne` - Slovník `Dict{Symbol, Any}` obsahující parametry závitu:
  - `:name`: Označení závitu (String).
  - `:d`: Jmenovitý průměr závitu (Float64) [mm].
  - `:p`: Stoupání závitu (Float64) [mm].

## Příklad:
```julia
using StrojniSoucasti

zavit_metricky = zavity("M10x1.25")
println("Metrický závit: Průměr d = $(zavit_metricky[:d]) mm, Stoupání p = $(zavit_metricky[:p]) mm")

zavit_trapezovy = zavity("TR20x4")
println("Trapézový závit: Průměr d = $(zavit_trapezovy[:d]) mm, Stoupání p = $(zavit_trapezovy[:p]) mm")
```