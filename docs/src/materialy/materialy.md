## funkce `materialy.jl`
## Funkce Julia v1.12
###############################################################
## Popis funkce:
Vrátí Material struct s vlastnostmi materiálu z databáze.
## Vzor:
`vystupni_promenne = materialy(vstupni_promenne)`
## Vstupní proměnné:
- `name::AbstractString - Označení materiálu (např. "S235", "11373", "S235JR+N"). Před vyhledáním se oříznou okraje, odstraní mezery a převádí se na velká písmena.
## Výstupní proměnné:
- `mat::Union{MaterialOcel, MaterialKovy, MaterialLitina, MaterialPryz, Nothing} - Datová struktura s vlastnostmi materiálu z databází EN10025-2/ČSN, nebo `nothing`, pokud materiál nebyl nalezen.
Typicky dostupná pole:
   - společná pro všechny typy: `name`, `standard`, `druh`, `A`, `A_unit`, `E`, `E_unit`, `G`, `G_unit`, `ny`, `ny_unit`, `rho`, `rho_unit`
   - pouze pro `MaterialOcel` a `MaterialKovy`: `Re`, `Re_unit`, `Rm_min`, `Rm_min_unit`, `Rm_max`, `Rm_max_unit`
   - pouze pro `MaterialOcel`: `KV`, `T_KV`, `weldable`, `thickness_max`
   - pouze pro `MaterialLitina`: `Rm_tah`, `Rm_tlak`, `tau_lim`, `HB_min`, `HB_max` (+ jejich *_unit)
   - pouze pro `MaterialPryz`: `hardness`, `hardness_unit`
Příklady čtení:
   - `mat.name`::String
   - `mat.Re`::Float64 (jen `MaterialOcel`, `MaterialKovy`)
   - `mat.Re_unit`::String (jen `MaterialOcel`, `MaterialKovy`)
   - `mat.E`::Float64
   - `mat.E_unit`::String
   - `mat.G`::Float64
   - `mat.G_unit`::String
## Příklad:
```julia
using StrojniSoucasti
mat = materialy("11373")
StrojniSoucasti.MaterialOcel("11 373", "ČSN 41 1373", "konstrukční ocel", 250.0, "MPa", 370.0, "MPa", 370.0, "MPa", 7.0, "%", 27.0, "J", 20.0, "°C", true, 200.0, "mm", 210.0, "GPa", 81.0, "GPa", 0.3, "-", 7850.0, "kg/m^3")
```




# Materialy

## Funkce `materialy`

```@docs
materialy
```

## Poznamky k databazim
- EN10025-2: `materialydatabaseOcelEN10025_2.toml`
- CSN: `materialydatabaseOcelCSN.toml`

## Priklady

```julia
mat = materialy("S235")
mat.Re
```
