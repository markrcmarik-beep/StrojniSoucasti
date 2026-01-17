# ver: 2026-01-17

using TOML
include("zavitytypes.jl")
#include("load_db.jl")
#include("zavitylookup_toml.jl")

#export zavity, DbRecord
const ZAVITY_DB = TOML.parsefile(joinpath(@__DIR__, "zavityM.toml"))

function zavity(oznaceni::AbstractString)
    oznaceni = replace(oznaceni, "," => ".")
    RX_METRIC = r"^M(\d+)(?:[xX](\d+(?:\.\d+)?))?$"

    RX_TRAPEZ = r"^(?:TR|Tr|tr)(\d+)(?:[xX](\d+(?:\.\d+)?))?$"
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
    extra = merge(rec.extra, Dict(:typ => typ))
    return DbRecord(rec.name, rec.d, rec.p, extra)
end

function lookup_toml(db::Dict{String,Any}, key::AbstractString)
    haskey(db, key) || error("Položka '$key' nebyla nalezena.")

    row = db[key]

    return DbRecord(
        key,
        row["d"],
        get(row, "p", nothing),
        Dict(Symbol(k) => v for (k,v) in row if k ∉ ("d","p"))
    )
end
