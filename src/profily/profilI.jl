## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí Profil_I struct s vlastnostmi I profilu z databáze.
# ver: 2026-04-09
## Funkce: profilI()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profil/profilI.jl
#
## Vzor:
## vystupni_promenne = profilI(vstupni_promenne)
## Vstupní proměnné:
# - name::AbstractString: Označení profilu (např. "IPE100", "IPE 100", "hea100")
## Výstupní proměnné:
# - Profil_I struct s vlastnostmi profilu nebo nothing, pokud profil neexistuje.
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
# profiltypes.jl, profilI.toml
## Příklad:
# prof = profilI("IPE 100")
# println(prof.h)  # 100.0
# println(prof.b)  # 55.0
# println(prof.r)  # 7.0
###############################################################

using TOML

isdefined(@__MODULE__, :Profil_I) || include("profiltypes.jl")

const I_DB = TOML.parsefile(joinpath(@__DIR__, "profilI.toml"))

function _num_key(x::Float64)::String
    if x == floor(x)
        return string(Int(x))
    else
        return string(x)
    end
end

function profilI(name::AbstractString)::Union{Profil_I, Nothing}
    s = uppercase(strip(name))
    s = replace(s, r"\s+" => "")

    m = match(r"^(IPE|IPN|HEA|HEB|HEM)(\d+(?:\.\d+)?)$", s)
    m === nothing && return nothing

    serie = m.captures[1]
    size_raw = m.captures[2]

    key = string(serie, size_raw)
    if !haskey(I_DB, key)
        size_val = parse(Float64, size_raw)
        key = string(serie, _num_key(size_val))
        haskey(I_DB, key) || return nothing
    end

    row = I_DB[key]
    size_part = key[length(serie)+1:end]

    return Profil_I(
        string(serie, " ", size_part),
        serie,
        get(row, "standard", "")::String,
        Float64(get(row, "h", 0.0)),
        Float64(get(row, "b", 0.0)),
        Float64(get(row, "tw", 0.0)),
        Float64(get(row, "tf", 0.0)),
        Float64(get(row, "r", 0.0)),
        get(row, "material", String[])::Vector{String}
    )
end
