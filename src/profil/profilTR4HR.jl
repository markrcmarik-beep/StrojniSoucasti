# ver: 2026-01-17
# Modul pro práci s profily TR4HR - umožňuje ukládat více hodnot pro parametry

using TOML

include("profilTR4HRtypes.jl")

const TR4HR_DB = TOML.parsefile(joinpath(@__DIR__, "profilTR4HR.toml"))

function profilTR4HR(name::AbstractString)::Union{Profil, Nothing}
    #r"^TR4HR(\d+)X(\d+)X(\d+)(R(\d+))?$"
    name = uppercase(strip(name))
    name = replace(s, r"\s+" => "")   # odstranění všech mezer
    haskey(TR4HR_DB, name) || return nothing
    
    row = TR4HR_DB[name]
    
    return Profil(
        get(row, "name", name)::String,
        get(row, "standard", "")::String,
        Float64(get(row, "a", 0.0)),
        Float64(get(row, "b", 0.0)),
        Float64(get(row, "t", 0.0)),
        Float64(get(row, "R", 0.0)),
        get(row, "material", "")::String
    )
end
