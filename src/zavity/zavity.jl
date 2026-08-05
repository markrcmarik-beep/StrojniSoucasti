# ver: 2026-08-05
## Funkce: zavity()
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/zavity/zavity.jl
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
#
###############################################################
## Použité proměnné vnitřní:
#
using TOML
include("zavitytypes.jl")
#export zavity, DbRecord
const ZAVITY_DB_M = TOML.parsefile(joinpath(@__DIR__, "zavityM.toml"))
const ZAVITY_DB_TR = TOML.parsefile(joinpath(@__DIR__, "zavityTR.toml"))
# načtení nápovědy z externího souboru
const _zavity_NAPOVEDA = read(
    joinpath(@__DIR__, "..", "..", "docs", "src", "zavity", "zavity.md"),
    String,
) 
"""
$_zavity_NAPOVEDA
"""
function _parse_numeric_smart(s::AbstractString)
    f_val = parse(Float64, s)
    if isinteger(f_val)
        return Int(f_val)
    else
        return f_val
    end
end

"""
$_zavity_NAPOVEDA
"""
function zavity(oznaceni::AbstractString)
    oznaceni = replace(oznaceni, "," => ".")
    RX_METRIC = r"^(?:[mM])(\d+(?:\.\d+)?)(?:[xX](\d+(?:\.\d+)?))?$"
    RX_TRAPEZ = r"^(?:TR|Tr|tR|tr)(\d+(?:\.\d+)?)(?:[xX](\d+(?:\.\d+)?))?$"
    # detect type: metric, trapezoidal, pipe (trubkový) or unknown
    db = nothing
    # use the compiled regex values directly
    if match(RX_METRIC, oznaceni) !== nothing
        db = ZAVITY_DB_M
        m_metric = match(RX_METRIC, oznaceni)
        D = m_metric.captures[1] # first capture group is the diameter
        p = m_metric.captures[2] # second capture group is the pitch (stoupání)
        klic = ("M$D")
        key = ("M$D")
    elseif match(RX_TRAPEZ, oznaceni) !== nothing
        db = ZAVITY_DB_TR
        m_trapez = match(RX_TRAPEZ, oznaceni)
        D = m_trapez.captures[1] # first capture group is the diameter
        p = m_trapez.captures[2] # second capture group is the pitch (stoupání)
        if p !== nothing
            klic = replace("TR$D x $p", " " => "")
            key = ("TR$D")
        else
            return nothing # označení musí obsahovat stoupání pro trapezový závit, jinak vracíme nothing
        end
    else
        return nothing
    end
    #db === nothing && error("Neznámý typ závitu pro: $oznaceni")
    db === nothing && return nothing
    #haskey(db, key) || error("Položka '$key' nebyla nalezena.")
    haskey(db, klic) || return nothing
    row = db[klic]
    d = Float64(row["d"])
    p_hodn_raw = get(row, "p", nothing)
    p_hodn = p_hodn_raw isa AbstractArray ? p_hodn_raw : [p_hodn_raw]
    p_norm = get(row, "p_norm", nothing)

    p_val = p === nothing ? nothing : _parse_numeric_smart(p)

    if p === nothing 
        p_val = p_norm
        name = klic
    elseif p_val isa Number && p_val in p_hodn # Zajištění, že p_val je číslo před kontrolou `in`
        name = replace("$key x $p", " " => "")
    else
        # If pitch is specified but is neither normal nor fine, return nothing.
        # This corresponds to the behavior where a thread with the given pitch does not exist in the database.
        return nothing 
    end

    VV = Dict{Symbol, Any}(
        :name => name,
        :name_info => "označení závitu",
        :d => d,
        :d_info => "průměr závitu",
        :p => p_val, # může být Int nebo Float64
        :p_info => "stoupání závitu",
    )
    return VV
    # lookup entry in DB; attach detected type into the extra Dict before returning
    #rec = lookup_toml(db, oznaceni)
    #return rec
end
