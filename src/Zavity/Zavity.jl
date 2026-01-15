module Zavity

export ThreadSpec, Zavity

"""
    ThreadSpec

Struktura popisující závit.
"""
struct ThreadSpec
    name::String
    typ::Symbol
    d::Float64
    pitch::Float64
end

include("DefaultPitch.jl")
include("DatabazeMetric.jl")
include("DatabazePipe.jl")

using .DefaultPitch
using .DatabazeMetric
using .DatabazePipe

# ---------------------------------------------------------
# Parser označení závitu
# ---------------------------------------------------------

function parse_designation(s::String)
    s = replace(strip(s), "," => ".")
    S = uppercase(s)

    # -----------------------------
    # METRICKÉ ZÁVITY
    # -----------------------------
    if startswith(S, "M")
        m = match(r"^M(\d+(?:\.\d+)?)(?:x(\d+(?:\.\d+)?))?$", S)
        m === nothing && error("Neplatné označení metrického závitu: $s")

        d = parse(Float64, m.captures[1])
        p = m.captures[2]

        pitch = isnothing(p) ? get_default_pitch(d) : parse(Float64, p)
        key = "M$(d)x$(pitch)"

        return key, :metric, d, pitch
    end

    # -----------------------------
    # TRUBKOVÉ ZÁVITY
    # -----------------------------
    if startswith(S, "TR")
        m = match(r"^TR(\d+(?:\.\d+)?)[xX](\d+(?:\.\d+)?)$", S)
        m === nothing && error("Neplatné označení trubkového závitu: $s")

        d = parse(Float64, m.captures[1])
        pitch = parse(Float64, m.captures[2])
        key = "TR$(d)x$(pitch)"

        return key, :pipe, d, pitch
    end

    error("Neznámý typ závitu: $s")
end

# ---------------------------------------------------------
# Funktor Zavity – volání jako Zavity()("M8")
# ---------------------------------------------------------

struct Zavity end

function (z::Zavity)(designation::String)
    key, typ, d, pitch = parse_designation(designation)

    if typ === :metric
        # Pokud existuje v databázi → použij ji
        if haskey(METRIC_DB, key)
            return METRIC_DB[key]
        end
        # Jinak vytvoř dynamicky
        return ThreadSpec(key, :metric, d, pitch)
    end

    if typ === :pipe
        return get(PIPE_DB, key, ThreadSpec(key, :pipe, d, pitch))
    end
end

end # module
