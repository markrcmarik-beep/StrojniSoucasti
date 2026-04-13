## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí Profil_I struct s vlastnostmi I profilu z databáze.
# ver: 2026-04-13
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

const I_DB_CSN425550 = TOML.parsefile(joinpath(@__DIR__, "profilI_CSN425550.toml"))
const IPE_DB_CSN425553 = TOML.parsefile(joinpath(@__DIR__, "profilIPE_CSN425553.toml"))

function profilI(name::AbstractString)::Union{Profil_I, Nothing}
    s = uppercase(strip(name))
    s = replace(s, r"\s+" => "")

    m = match(r"^(I|IPE|IPN|HEA|HEB|HEM)(\d+(?:\.\d+)?)$", s)
    m === nothing && return nothing

    serie = String(m.captures[1])
    size_raw = String(m.captures[2])

    key_candidates = String[string(serie, size_raw)]
    size_val = parse(Float64, size_raw)
    normalized_key = string(serie, _num_key(size_val))
    normalized_key != key_candidates[1] && push!(key_candidates, normalized_key)

    db_candidates = serie == "IPE" ?
        ((IPE_DB_CSN425553, "\u010CSN 42 5553"), (I_DB_CSN425550, "\u010CSN 42 5550")) :
        ((I_DB_CSN425550, "\u010CSN 42 5550"),)

    row = nothing
    key = ""
    standard = ""
    for (db, db_standard) in db_candidates
        for key_candidate in key_candidates
            if haskey(db, key_candidate)
                row = db[key_candidate]
                key = key_candidate
                standard = db_standard
                break
            end
        end
        row === nothing || break
    end
    row === nothing && return nothing

    size_part = key[length(serie)+1:end]

    return Profil_I(
        string(serie, " ", size_part),
        serie,
        standard,
        "norma - textova hodnota",
        Float64(get(row, "h", 0.0)), # h - vyska profilu [mm]
        "mm",
        "vyska profilu [mm]",
        Float64(get(row, "b", 0.0)), # b - sirka pasnice [mm]
        "mm",
        "sirka pasnice [mm]",
        Float64(get(row, "t1", 0.0)), # t1 - tloustka stojiny [mm]
        "mm",
        "tloustka stojiny [mm]",
        Float64(get(row, "t2", 0.0)), # t2 - stredni tloustka pasnice [mm]
        "mm",
        "stredni tloustka pasnice [mm]",
        Float64(get(row, "R", 0.0)), # R - polomer zaobleni vyskove spojnice [mm]
        "mm",
        "polomer zaobleni vyskove spojnice [mm]",
        Float64(get(row, "R1", 0.0)), # R1 - polomer zaobleni vnitrni sirky pasnice [mm]
        "mm",
        "polomer zaobleni vnitrni sirky pasnice [mm]",
        Float64(get(row, "sp", 0.0)), # sp - sklon priruby [%]
        "%",
        "sklon priruby [%]",
        Float64(get(row, "m", 0.0)), # m - hmotnost [kg/m]
        "kg/m",
        "hmotnost [kg/m]",
        get(row, "material", String[])::Vector{String},
        "materialy - vsechny textove hodnoty",
        Float64(get(row, "S", 0.0)), # S - plocha prurezu [mm^2]
        "mm^2",
        "plocha prurezu [mm^2]",
        Float64(get(row, "Ix", 0.0)), # Ix - moment setrvacnosti podle osy x [mm^4]
        "mm^4",
        "moment setrvacnosti podle osy x [mm^4]",
        Float64(get(row, "Wx", 0.0)), # Wx - prurezovy modul podle osy x [mm^3]
        "mm^3",
        "prurezovy modul podle osy x [mm^3]",
        Float64(get(row, "ix", 0.0)), # ix - polomer setrvacnosti podle osy x [mm]
        "mm",
        "polomer setrvacnosti podle osy x [mm]",
        Float64(get(row, "Iy", 0.0)), # Iy - moment setrvacnosti podle osy y [mm^4]
        "mm^4",
        "moment setrvacnosti podle osy y [mm^4]",
        Float64(get(row, "Wy", 0.0)), # Wy - prurezovy modul podle osy y [mm^3]
        "mm^3",
        "prurezovy modul podle osy y [mm^3]",
        Float64(get(row, "iy", 0.0)), # iy - polomer setrvacnosti podle osy y [mm]
        "mm",
        "polomer setrvacnosti podle osy y [mm]",
        Float64(get(row, "Sx", get(row, "sx", 0.0))), # Sx - staticky moment podle osy x [mm^3]
        "mm^3",
        "staticky moment prurezu podle osy x [mm^3]"
    )
end

function _num_key(x::Float64)::String
    if x == floor(x)
        return string(Int(x))
    else
        return string(x)
    end
end
