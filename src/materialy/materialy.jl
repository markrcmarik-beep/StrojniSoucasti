## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí Material struct s vlastnostmi materiálu z databáze.
# ver: 2026-03-09
## Funkce: materialy()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/materialy/materialy.jl
#
## Vzor:
## vystupni_promenne = materialy(vstupni_promenne)
## Vstupní proměnné:
# name::AbstractString
#   Označení materiálu (např. "S235", "11373", "S235JR+N").
#   Před vyhledáním se oříznou okraje, odstraní mezery a převádí se na velká písmena.
## Výstupní proměnné:
# mat::Union{MaterialOcel, MaterialKovy, MaterialLitina, Nothing}
#   Datová struktura s vlastnostmi materiálu z databází EN10025-2/ČSN,
#   nebo `nothing`, pokud materiál nebyl nalezen.
#   Typicky dostupná pole:
#   - společná pro všechny typy: `name`, `standard`, `druh`, `A`, `E`, `G`, `ny`, `rho`
#   - pouze pro `MaterialOcel` a `MaterialKovy`: `Re`, `Rm_min`, `Rm_max`
#   - pouze pro `MaterialOcel`: `KV`, `T_KV`, `weldable`, `thickness_max`
#   - pouze pro `MaterialLitina`: `Rm_tah`, `Rm_tlak`, `tau_lim`, `HB_min`, `HB_max`
#   Příklady čtení:
#   - `mat.name`::String
#   - `mat.Re`::Float64 (jen `MaterialOcel`, `MaterialKovy`)
#   - `mat.E`::Float64
#   - `mat.G`::Float64
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
# materialytypes.jl, materialydatabase.toml
## Příklad:
# julia
# vstup:
# mat = materialy("11373")
#
# použití:
# if mat !== nothing
#     println(typeof(mat))             # např. MaterialOcel
#     println("name = ", mat.name)
#     println("Re = ", mat.Re, " MPa")   # jen pro MaterialOcel/MaterialKovy
#     println("E  = ", mat.E,  " MPa")
#     println("G  = ", mat.G,  " MPa")
# else
#     println("Materiál nebyl nalezen.")
# end
#
# očekávaný výstup (pro existující ocel):
# MaterialOcel
# name = 11373
# Re = ... MPa
# E  = ... MPa
# G  = ... MPa
#
# očekávaný výstup (pro neexistující materiál):
# Materiál nebyl nalezen.
###############################################################
## Použité proměnné vnitřní:
#
using TOML

include("materialytypes.jl")

const MATERIALY_DB_EN10025_2 = TOML.parsefile(joinpath(@__DIR__, 
    "materialydatabaseOcelEN10025_2.toml"))
const MATERIALY_DB_OCEL_CSN = TOML.parsefile(joinpath(@__DIR__, 
    "materialydatabaseOcelCSN.toml"))
const MATERIALY_DB_KOVY_CSN = TOML.parsefile(joinpath(@__DIR__, 
    "materialydatabaseKovyCSN.toml"))
const MATERIALY_DB_LITINA_CSN = TOML.parsefile(joinpath(@__DIR__,
    "materialydatabaseLitinaCSN.toml"))

"""
    materialy(name::AbstractString) -> Union{MaterialOcel, MaterialKovy, MaterialLitina, Nothing}

Vrátí `MaterialOcel`, `MaterialKovy` nebo `MaterialLitina` s vlastnostmi
materiálu z databází EN10025-2 a ČSN.
Pokud materiál neexistuje, vrátí `nothing`.

Vstupy:
- `name`: označení materiálu (např. "S235", "S235JR+N"). Bílé znaky se odstraní,
  převádí se na velká písmena.

Výstup:
- `MaterialOcel`, `MaterialKovy`, `MaterialLitina` nebo `nothing`.

Příklad:
```julia
# vstup:
mat = materialy("11373")

# použití:
if mat !== nothing
    println(typeof(mat))             # např. MaterialOcel
    println("name = ", mat.name)
    println("Re = ", mat.Re, " MPa")   # jen pro MaterialOcel/MaterialKovy
    println("E  = ", mat.E,  " MPa")
    println("G  = ", mat.G,  " MPa")
else
    println("Materiál nebyl nalezen.")
end
```

Očekávaný výstup (pro existující ocel):
```text
MaterialOcel
name = 11373
Re = ... MPa
E  = ... MPa
G  = ... MPa
```

Očekávaný výstup (pro neexistující materiál):
```text
Materiál nebyl nalezen.
```
"""

function materialy(name::AbstractString)::Union{MaterialOcel,
    MaterialKovy,
    MaterialLitina,
    Nothing}

    name = uppercase(strip(name)) # velká písmena
    name = replace(name, r"\s+" => "")   # odstranění všech mezer
    
    if haskey(MATERIALY_DB_EN10025_2, name) # materiál existuje v databázi
    
        row = MATERIALY_DB_EN10025_2[name]
        return MaterialOcel(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
        get(row, "druh", "")::String, # norma (nepovinné)
        Float64(get(row, "Re", 0)), # meze kluzu
        Float64(get(row, "Rm_min", 0)), # meze pevnosti
        Float64(get(row, "Rm_max", 0)), # meze pevnosti max
        Float64(get(row, "A", 0)), # prodloužení
        Float64(get(row, "KV", 0)), # houževnatost KV
        Float64(get(row, "T_KV", 0)), # teplota KV
        Bool(get(row, "weldable", false)), # svařitelnost
        Float64(get(row, "thickness_max", 0)), # max tloušťka
        Float64(get(row, "E", 0)), # modul pružnosti
        Float64(get(row, "G", 0)), # modul smyku
        Float64(get(row, "ny", 0)), # Poissonovo číslo
        Float64(get(row, "rho", 0)) # hustota
    )
    elseif haskey(MATERIALY_DB_OCEL_CSN, name) # materiál existuje v databázi ČSN ocelí
        
        row = MATERIALY_DB_OCEL_CSN[name]
        return MaterialOcel(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
        get(row, "druh", "")::String, # norma (nepovinné)
        Float64(get(row, "Re", 0)), # meze kluzu
        Float64(get(row, "Rm_min", 0)), # meze pevnosti
        Float64(get(row, "Rm_max", 0)), # meze pevnosti max
        Float64(get(row, "A", 0)), # prodloužení
        Float64(get(row, "KV", 0)), # houževnatost KV
        Float64(get(row, "T_KV", 0)), # teplota KV
        Bool(get(row, "weldable", false)), # svařitelnost
        Float64(get(row, "thickness_max", 0)), # max tloušťka
        Float64(get(row, "E", 0)), # modul pružnosti
        Float64(get(row, "G", 0)), # modul smyku
        Float64(get(row, "ny", 0)), # Poissonovo číslo
        Float64(get(row, "rho", 0)) # hustota
    )
    elseif haskey(MATERIALY_DB_KOVY_CSN, name) # materiál existuje v databázi ČSN kovů
        
        row = MATERIALY_DB_KOVY_CSN[name]
        return MaterialKovy(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
        get(row, "druh", "")::String, # norma (nepovinné)
        Float64(get(row, "Re", 0)), # meze kluzu
        Float64(get(row, "Rm_min", 0)), # meze pevnosti
        Float64(get(row, "Rm_max", 0)), # meze pevnosti max
        Float64(get(row, "A", 0)), # prodloužení
        Float64(get(row, "E", 0)), # modul pružnosti
        Float64(get(row, "G", 0)), # modul smyku
        Float64(get(row, "ny", 0)), # Poissonovo číslo
        Float64(get(row, "rho", 0)) # hustota
    )
    elseif haskey(MATERIALY_DB_LITINA_CSN, name) # materiál existuje v databázi ČSN litin

        row = MATERIALY_DB_LITINA_CSN[name]
        return MaterialLitina(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
        get(row, "druh", "")::String, # typ litiny
        Float64(get(row, "Rm_tah", 0)), # mez pevnosti v tahu
        Float64(get(row, "Rm_tlak", 0)), # mez pevnosti v tlaku
        Float64(get(row, "tau_lim", 0.5 * Float64(get(row, "Rm_tah", 0)))), # mez smykové pevnosti
        Float64(get(row, "A", 0)), # prodloužení
        Float64(get(row, "HB_min", 0)), # tvrdost Brinell min
        Float64(get(row, "HB_max", 0)), # tvrdost Brinell max
        Float64(get(row, "E", 0)), # modul pružnosti
        Float64(get(row, "G", 0)), # modul smyku
        Float64(get(row, "ny", 0)), # Poissonovo číslo
        Float64(get(row, "rho", 0)) # hustota
    )
    #else
    #    return nothing
    end
    return nothing
end

