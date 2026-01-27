## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí Material struct s vlastnostmi materiálu z databáze.
# ver: 2026-01-26
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
#
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

const MATERIALY_DB_EN10025_2 = TOML.parsefile(joinpath(@__DIR__, 
    "materialydatabaseOcelEN10025_2.toml"))
const MATERIALY_DB_CSN = TOML.parsefile(joinpath(@__DIR__, 
    "materialydatabaseOcelCSN.toml"))

function materialy(name::AbstractString)::Union{MaterialOcel,
    Nothing}

    name = uppercase(strip(name)) # velká písmena
    name = replace(name, r"\s+" => "")   # odstranění všech mezer
    
    if haskey(MATERIALY_DB_EN10025_2, name) # materiál existuje v databázi
    
        row = MATERIALY_DB_EN10025_2[name]
        return MaterialOcel(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
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
    elseif haskey(MATERIALY_DB_CSN, name) # materiál existuje v databázi CSN
        
        row = MATERIALY_DB_CSN[name]
        return MaterialOcel(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
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
    #else
    #    return nothing
    end
    return nothing
end
