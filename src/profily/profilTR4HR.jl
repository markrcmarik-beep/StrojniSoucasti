## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí Profil struct s vlastnostmi profilu TR4HR z databáze.
# ver: 2026-01-18
## Funkce: profilTR4HR()
#
## Cesta uvnitř balíčku:
# balicek/src/profilTR4HR.jl
#
## Vzor:
## vystupni_promenne = profilTR4HR(vstupni_promenne)
## Vstupní proměnné:
# - name::AbstractString: Označení profilu (např. "TR4HR 20x20x2", "TR4HR20x2")
## Výstupní proměnné:
# - Profil struct s vlastnostmi profilu nebo nothing, pokud profil neexistuje.
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
# profilTR4HRtypes.jl, profilTR4HR.toml
## Příklad:
# prof = profilTR4HR("TR4HR 20x20x2")
# println(prof.a)  # 20.0
# println(prof.b)  # 20.0
# println(prof.t)  # 2.0
###############################################################
## Použité proměnné vnitřní:
#

using TOML

include("profiltypes.jl")

const TR4HR_DB = TOML.parsefile(joinpath(@__DIR__, "profilTR4HR.toml"))

function profilTR4HR(name::AbstractString)::Union{Profil_TR4HR, Nothing}

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
            b = a
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
    R_val = t/3 + t # výchozí poloměr
    if R_val >= 8
        R_val = 8
    end
    #R_val = row["R"][idx] # odpovídající poloměr

    return Profil_TR4HR(
        string(oznaceni), # název profilu
        get(row, "standard", "")::String, # norma (nepovinné)
        a, # rozměr a
        b, # rozměr b
        t, # tloušťka
        R_val, # poloměr
        get(row, "material", String[])::Vector{String}
    )
end
