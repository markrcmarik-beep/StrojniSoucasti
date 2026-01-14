# ver: 2026-01-08

include("materialytypes.jl")
include("materialydatabase.jl")

"""
    materialy(name::AbstractString)

Vrátí materiál ze databáze podle jeho jména.
"""
materialy(name::AbstractString) =
    haskey(MATERIAL_DB, name) ?
        MATERIAL_DB[name] :
        error("Materiál $name není v databázi")
