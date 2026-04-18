## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí TR4HR_CSN425720 struct s vlastnostmi profilu TR4HR z databáze.
# ver: 2026-04-18
## Funkce: profilTR4HR()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profil/profilTR4HR.jl
#
## Vzor:
## vystupni_promenne = profilTR4HR(vstupni_promenne)
## Vstupní proměnné:
# - name::AbstractString: Označení profilu (např. "TR4HR 20x20x2", "TR4HR20x2")
## Výstupní proměnné:
# - TR4HR_CSN425720 struct s vlastnostmi profilu nebo nothing, pokud profil neexistuje.
#   Vlastnosti TR4HR_CSN425720 struct:
#   - name::String: Název profilu
#   - standard::String: Norma (nepovinné)
#   - a::Float64: Rozměr a
#   - b::Float64: Rozměr b
#   - t::Float64: Tloušťka
#   - R::Float64: Poloměr (buď z databáze, nebo vypočítaný jako min(t + t/3, 8.0))
#   - material::Vector{String}: Seznam materiálů (nepovinné)
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
# profil_TR4HR_CSN425720.toml, num_to_string()
## Příklad:
# prof = profilTR4HR("TR4HR 20x20x2")
# println(prof.a)  # 20.0
# println(prof.b)  # 20.0
# println(prof.t)  # 2.0
# println(prof.R)  # 2.666...
###############################################################
## Použité proměnné vnitřní:
#

using TOML

struct TR4HR_CSN425720
    name::String
    standard::String
    a::Float64
    b::Float64
    t::Float64
    R::Float64
    material::Vector{String}
end

const TR4HR_DB = TOML.parsefile(joinpath(@__DIR__, "profil_TR4HR_CSN425720.toml"))

function profil_TR4HR_CSN425720(name::AbstractString)::Union{TR4HR_CSN425720, Nothing}

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
            nadpDB = num_to_string(a) * "x" * num_to_string(b) # nadpis v DB
            oznaceni = "TR4HR " * nadpDB * "x" * string(t) # označení
        elseif a == b
            nadpDB = num_to_string(a) # nadpis v DB
            oznaceni = "TR4HR " * nadpDB * "x" * string(t) # označení
        end
    else
        # Zkusit rozebrat formát TR4HR_a_x_t
        m = match(r"^TR4HR(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)$", name)
        if m !== nothing
            a = parse(Float64, m.captures[1]) # rozměr
            b = a
            t = parse(Float64, m.captures[2]) # tloušťka
            nadpDB = num_to_string(a) # nadpis v DB
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
    R_vec = get(row, "R", nothing)
    R_val = if R_vec isa AbstractVector && idx <= length(R_vec)
        Float64(R_vec[idx]) # poloměr z databáze (pokud je uveden)
    else
        min(t + t/3, 8.0) # výchozí poloměr
    end

    return TR4HR_CSN425720(
        string(oznaceni), # název profilu
        get(row, "standard", "")::String, # norma (nepovinné)
        a, # rozměr a
        b, # rozměr b
        t, # tloušťka
        R_val, # poloměr
        get(row, "material", String[])::Vector{String}
    )
end

# Pomocná funkce pro konverzi čísla na string bez zbytečných nul
function num_to_string(x::Float64)::String
    if x == floor(x)
        return string(Int(x))  # celočíslo bez tečky
    else
        return string(x)  # desetinné číslo
    end
end
