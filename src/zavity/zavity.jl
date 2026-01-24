## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce pro vyhledání parametrů závitů podle jejich označení.
# ver: 2026-01-20
## Funkce: zavity()
#
## Cesta uvnitř balíčku:
# balicek/src/zavity.jl
#
## Vzor:
## vystupni_promenne = zavity(vstupni_promenne)
## Vstupní proměnné:
# vstupni_promenne: Oznaceni závitu jako řetězec (např. "M8x1.25", "TR20x4", "G1/2").
## Výstupní proměnné:
# vystupni_promenne: Struktura DbRecord obsahující název závitu, 
#   průměr (d), stoupání (p) a další informace.
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
#
## Příklad:
# A = zavity("M8x1.25")
# println("Průměr: ", A.d, " mm, stoupání: ", A.p, " mm")
###############################################################
## Použité proměnné vnitřní:
#

using TOML
include("zavitytypes.jl")

#export zavity, DbRecord
const ZAVITY_DB = TOML.parsefile(joinpath(@__DIR__, "zavityM.toml"))

function zavity(oznaceni::AbstractString)
    oznaceni = replace(oznaceni, "," => ".")
    RX_METRIC = r"^(?:[mM])(\d+(?:\.\d+)?)(?:[xX](\d+(?:\.\d+)?))?$"
    RX_TRAPEZ = r"^(?:TR|Tr|tR|tr)(\d+(?:\.\d+)?)(?:[xX](\d+(?:\.\d+)?))?$"
    # detect type: metric, trapezoidal, pipe (trubkový) or unknown
    typ = :unknown
    # use the compiled regex values directly
    if match(RX_METRIC, oznaceni) !== nothing
        typ = :metric
    elseif match(RX_TRAPEZ, oznaceni) !== nothing
        typ = :trapez
    else
        # pipe/thread patterns: G, R, Rp, NPT, fractional inch (1/2), or inch quotes
        if match(r"(?i)^(?:G|R|Rp|NPT)\b", oznaceni) !== nothing ||
           match(r"^\d+\/(?:\d+)", oznaceni) !== nothing ||
           occursin('"', oznaceni) || occursin("inch", lowercase(oznaceni)) || occursin("bsp", lowercase(oznaceni))
            typ = :pipe
        end
    end
    # lookup entry in DB; attach detected type into the extra Dict before returning
    rec = lookup_toml(ZAVITY_DB, oznaceni)
    return DbRecord(rec.name, rec.d, rec.p)
end

function lookup_toml(db::Dict{String,Any}, key::AbstractString)
    haskey(db, key) || error("Položka '$key' nebyla nalezena.")
    row = db[key]
    return DbRecord(
        key,
        row["d"],
        get(row, "p", nothing)
    )
end
