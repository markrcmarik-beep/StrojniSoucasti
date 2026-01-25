## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí Material struct s vlastnostmi materiálu z databáze.
# ver: 2026-01-18
## Funkce: materialy()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/materialy/materialy.jl
#
## Vzor:
## vystupni_promenne = materialy(vstupni_promenne)
## Vstupní proměnné:
# - name::AbstractString: Označení materiálu (např. "S235", "S235JR+N")
## Výstupní proměnné:
# - Material struct s vlastnostmi materiálu nebo nothing, pokud materiál neexistuje.
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
# materialytypes.jl, materialydatabase.toml
## Příklad:
# julia
# mat = materialy("S235")
# println(mat.Re)  # 235.0
###############################################################
## Použité proměnné vnitřní:
#
using TOML

include("materialytypes.jl")

const MATERIALY_DB = TOML.parsefile(joinpath(@__DIR__, "materialydatabase.toml"))

function materialy(name::AbstractString)::Material
    name = uppercase(strip(name)) # velká písmena
    name = replace(name, r"\s+" => "")   # odstranění všech mezer
    haskey(MATERIALY_DB, name) || return nothing
    
    row = MATERIALY_DB[name]
    
    return Material(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
        Float64(get(row, "Re", 0.0)), # meze kluzu
        Float64(get(row, "Rm_min", 0.0)), # meze pevnosti
        Float64(get(row, "Rm_max", 0.0)), # meze pevnosti max
        Float64(get(row, "A", 0.0)), # prodloužení
        Float64(get(row, "KV", 0.0)), # houževnatost KV
        Float64(get(row, "T_KV", 0.0)), # teplota KV
        Bool(get(row, "weldable", false)), # svařitelnost
        Float64(get(row, "thickness_max", 0.0)), # max tloušťka
        Float64(get(row, "E", 0.0)), # modul pružnosti
        Float64(get(row, "G", 0.0)), # modul smyku
        Float64(get(row, "ny", 0.0)), # Poissonovo číslo
        Float64(get(row, "rho", 0.0)) # hustota
    )
end
