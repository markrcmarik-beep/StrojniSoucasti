# ver: 2026-01-17

using TOML

include("materialytypes.jl")

const MATERIALY_DB = TOML.parsefile(joinpath(@__DIR__, "materialydatabase.toml"))

"""
    materialy(name::AbstractString)::Material

Vrátí Material struct s vlastnostmi materiálu z databáze.

# Argumenty
- name::AbstractString`: Označení materiálu (např. "S235", "S235JR+N")

# Vrací
- Material`: Struct s kompletními vlastnostmi materiálu

# Příklad
julia
# mat = materialy("S235")
# println(mat.Re)  # 235.0

"""
function materialy(name::AbstractString)::Material
    haskey(MATERIALY_DB, name) || error("Materiál '$name' není v databázi")
    
    row = MATERIALY_DB[name]
    
    return Material(
        get(row, "name", name)::String,
        get(row, "standard", "")::String,
        Float64(get(row, "Re", 0.0)),
        Float64(get(row, "Rm_min", 0.0)),
        Float64(get(row, "Rm_max", 0.0)),
        Float64(get(row, "A", 0.0)),
        Float64(get(row, "KV", 0.0)),
        Float64(get(row, "T_KV", 0.0)),
        Bool(get(row, "weldable", false)),
        Float64(get(row, "thickness_max", 0.0)),
        Float64(get(row, "E", 0.0)),
        Float64(get(row, "G", 0.0)),
        Float64(get(row, "ny", 0.0)),
        Float64(get(row, "rho", 0.0))
    )
end
