## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Načte informace o závitu podle jeho označení ze standardizované tabulky závitů.
# Podporovány jsou metrické (M) a trapézové (Tr) závity.
# ver: 2026-01-14
## Funkce:  = zavity(s::AbstractString)
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/zavity.jl
#
## Vzor:
#
## Vstupní proměnné:
# s - Řetězec označení závitu (např. "M8", "M8x1", "M10x1.5", "Tr20x4").
## Výstupní proměnné:
# 
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
# Z = zavity()
# z = Z("M8")
# z.name       # "M8x1.25"
# z.stoupani   # 1.25
# z.d          # 8.0
# z.typ        # :metric
################################################################
## Použité proměnné vnitřní:
#
module zavity

export ThreadSpec, zavity

"""
    ThreadSpec

Struktura popisující závit:
- `name`      – normalizované označení (např. "M8x1.25", "TR20x4")
- `typ`       – :metric nebo :pipe
- `d`         – jmenovitý průměr [mm]
- `stoupani`  – stoupání [mm]
"""
struct ThreadSpec
    name::String
    typ::Symbol
    d::Float64
    stoupani::Float64
end

# ---------------------------------------------------------
# Databáze standardních stoupání metrických závitů (ISO)
# ---------------------------------------------------------

const METRIC_DEFAULT_PITCH = Dict(
    1.0  => 0.25,
    1.2  => 0.25,
    1.4  => 0.3,
    1.6  => 0.35,
    1.8  => 0.35,
    2.0  => 0.4,
    2.5  => 0.45,
    3.0  => 0.5,
    4.0  => 0.7,
    5.0  => 0.8,
    6.0  => 1.0,
    8.0  => 1.25,
    10.0 => 1.5,
    12.0 => 1.75,
    14.0 => 2.0,
    16.0 => 2.0,
    18.0 => 2.5,
    20.0 => 2.5,
    22.0 => 2.5,
    24.0 => 3.0,
    27.0 => 3.0,
    30.0 => 3.5,
    33.0 => 3.5,
    36.0 => 4.0,
)

# ---------------------------------------------------------
# Databáze trubkových závitů (zatím jednoduchá)
# ---------------------------------------------------------

const TRUBKOVE = Dict(
    "TR20x4.0" => ThreadSpec("TR20x4.0", :pipe, 20.0, 4.0),
    "TR16x3.0" => ThreadSpec("TR16x3.0", :pipe, 16.0, 3.0),
)

# ---------------------------------------------------------
# Parser označení závitu
# ---------------------------------------------------------

"""
    parse_designation(s::String)

Rozpozná typ závitu, doplní případně normové stoupání
a vrátí: (klíč, typ, d, stoupani).
"""
function parse_designation(s::String)
    s = replace(strip(s), "," => ".")
    S = uppercase(s)

    # METRICKÉ ZÁVITY
    if startswith(S, "M")
        m = match(r"^M(\d+(?:\.\d+)?)(?:x(\d+(?:\.\d+)?))?$", S)
        m === nothing && error("Neplatné označení metrického závitu: $s")

        d = parse(Float64, m.captures[1])
        p = m.captures[2]

        if isnothing(p)
            pitch = get(METRIC_DEFAULT_PITCH, d,
                error("Pro průměr M$(d) není definováno standardní stoupání"))
        else
            pitch = parse(Float64, p)
        end

        key = "M$(d)x$(pitch)"
        return key, :metric, d, pitch
    end

    # TRUBKOVÉ ZÁVITY
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
# Funktor zavity – volání jako zavity()("M8")
# ---------------------------------------------------------

"""
    zavity()

Objekt, který lze volat jako funkci: `zavity()("M8")`.
Vrací `ThreadSpec`.
"""
struct zavity end

function (z::zavity)(designation::String)
    key, typ, d, pitch = parse_designation(designation)

    if typ === :metric
        return ThreadSpec(key, :metric, d, pitch)
    elseif typ === :pipe
        return get(TRUBKOVE, key, ThreadSpec(key, :pipe, d, pitch))
    end
end

end # module
