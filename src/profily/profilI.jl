## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí Profil_I struct s vlastnostmi I profilu z databáze.
# ver: 2026-04-10
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

const I_DB = TOML.parsefile(joinpath(@__DIR__, "profilI_CSN425550.toml"))

function profilI(name::AbstractString)::Union{Profil_I, Nothing}
    s = uppercase(strip(name))
    s = replace(s, r"\s+" => "")

    m = match(r"^(I|IPE|IPN|HEA|HEB|HEM)(\d+(?:\.\d+)?)$", s)
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
        #get(row, "standard", "")::String, # norma - textová hodnota
        "ČSN 42 5550",
        "norma - textová hodnota", # další informace o normě - textová hodnota
        Float64(get(row, "b", 0.0)), # b - šířka pásnice [mm]
        "mm",
        "šířka pásnice [mm]", # další informace o šířce pásnice - textová hodnota
        Float64(get(row, "h", 0.0)), # h  - výška profilu [mm]
        "mm",
        "výška profilu [mm]", # další informace o výšce profilu - textová hodnota
        Float64(get(row, "t1", 0.0)), # t1 - tloušťka stojiny [mm]
        "mm",
        "tloušťka stojiny [mm]", # další informace o tloušťce stojiny - textová hodnota
        Float64(get(row, "t2", 0.0)), # t2 - střední tloušťka pásnice [mm]
        "mm",
        "střední tloušťka pásnice [mm]", # další informace o tloušťce pásnice - textová hodnota
        Float64(get(row, "R", 0.0)), # R - poloměr zaoblení výškové spojnice [mm]
        "mm",
        "poloměr zaoblení výškové spojnice [mm]", # další informace o poloměru zaoblení výškové spojnice - textová hodnota
        Float64(get(row, "R1", 0.0)), # R1 - poloměr zaoblení vnitřní šířky pásnice [mm]
        "mm",
        "poloměr zaoblení vnitřní šířky pásnice [mm]", # další informace o poloměru zaoblení vnitřní šířky pásnice - textová hodnota
        get(row, "material", String[])::Vector{String}, # material - materiály - všechny textové hodnoty
        "materiály - všechny textové hodnoty" # další informace o materiálu - textová hodnota
    )
end

function _num_key(x::Float64)::String
    if x == floor(x)
        return string(Int(x))
    else
        return string(x)
    end
end
