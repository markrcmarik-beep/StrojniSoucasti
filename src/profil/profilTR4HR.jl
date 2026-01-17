# ver: 2026-01-17
# Modul pro práci s profily TR4HR - umožňuje ukládat více hodnot pro parametry

using TOML

include("profilTR4HRtypes.jl")

const TR4HR_DB = TOML.parsefile(joinpath(@__DIR__, "profilTR4HR.toml"))

function profilTR4HR(name::AbstractString)::Union{Profil, Nothing}
    
    name = uppercase(strip(name)) # velká písmena
    name = replace(name, r"\s+" => "")   # odstranění všech mezer
    
    nadp = nothing
    
    # Zkusit rozebrat formát TR4HR_a_x_b_x_t
    m = match(r"^TR4HR(\d+)X(\d+)X(\d+)$", name)
    if m !== nothing
        a = parse(Int, m.captures[1])
        b = parse(Int, m.captures[2])
        t = parse(Int, m.captures[3])
        nadp = string(a, "x", b)
    else
        # Zkusit rozebrat formát TR4HR_a_x_t
        m = match(r"^TR4HR(\d+)X(\d+)$", name)
        if m !== nothing
            a = parse(Int, m.captures[1])
            t = parse(Int, m.captures[2])
            nadp = string(a)
        end
    end
        
    nadp === nothing && return nothing
    haskey(TR4HR_DB, nadp) || return nothing
    
    row = TR4HR_DB[nadp]
    
    return Profil(
        get(row, "name", "")::String,
        get(row, "standard", "")::String,
        Float64(get(row, "a", 0.0)),
        Float64(get(row, "b", 0.0)),
        Float64(get(row, "t", 0.0)),
        Float64(get(row, "R", 0.0)),
        get(row, "material", "")::String
    )
end
