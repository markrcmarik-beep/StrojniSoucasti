# ver: 2026-01-18
# Modul pro práci s profily TR4HR - umožňuje ukládat více hodnot pro parametry

using TOML

include("profilTR4HRtypes.jl")

const TR4HR_DB = TOML.parsefile(joinpath(@__DIR__, "profilTR4HR.toml"))

function profilTR4HR(name::AbstractString)::Union{Profil, Nothing}

    name = uppercase(strip(name)) # velká písmena
    name = replace(name, r"\s+" => "")   # odstranění všech mezer

    nadpDB = nothing
    oznaceni = nothing
    # Zkusit rozebrat formát TR4HR_a_x_b_x_t
    m = match(r"^TR4HR(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)$", name)
    if m !== nothing
        a = parse(Float64, m.captures[1]) # rozměr
        b = parse(Float64, m.captures[2]) # rozměr
        t = parse(Float64, m.captures[3]) # tloušťka
        if a < b # zajistit a >= b
            a, b = b, a  # zajistit a >= b
        end
        if a > b
        nadpDB = string(Int(a), "x", Int(b)) # nadpis v DB
        oznaceni = "TR4HR " * nadpDB * "x" * string(t) # označení
        elseif a == b
            nadpDB = string(Int(a)) # nadpis v DB
            oznaceni = "TR4HR " * nadpDB * "x" * string(t) # označení
        end
    else
        # Zkusit rozebrat formát TR4HR_a_x_t
        m = match(r"^TR4HR(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)$", name)
        if m !== nothing
            a = parse(Float64, m.captures[1]) # rozměr
            t = parse(Float64, m.captures[2]) # tloušťka
            nadpDB = string(Int(a)) # nadpis v DB
            oznaceni = "TR4HR " * nadpDB * "x" * string(t) # označení
        end
    end

    nadpDB === nothing && return nothing
    haskey(TR4HR_DB, nadpDB) || return nothing

    row = TR4HR_DB[nadpDB] # načíst řádek z DB
    t_vec = get(row, "t", Float64[]) # dostupné tloušťky
    if !(t in t_vec)
        return nothing
    end
    idx = findfirst(==(t), t_vec) # najít index tloušťky
    t = t_vec[idx] # vybraná tloušťka
    R_val = row["R"][idx] # odpovídající poloměr

    return Profil(
        string(oznaceni), # název profilu
        get(row, "standard", "")::String, # norma (nepovinné)
        Float64(get(row, "a", 0.0)), # rozměr a
        Float64(get(row, "b", 0.0)), # rozměr b
        Float64(t),
        Float64(R_val),
        get(row, "material", String[])::Vector{String}
    )
end
