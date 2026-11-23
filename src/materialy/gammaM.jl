# ver: 2026-11-21
## Funkce gammaM()
## Autor: Martin
## Funkce Julia v1.13
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/materialy/gammaM.jl
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
#
###############################################################
## Použité proměnné vnitřní:
#
using TOML

const GAMMA_M_BASE = begin
    raw = TOML.parsefile(joinpath(@__DIR__, "gammaM.toml"))
    base = Dict{Tuple{String,String},Float64}()
    z_values = String[]
    n_values = String[]

    for (Z, row_any) in raw
        row_any isa AbstractDict ||
            error("Neplatná sekce '$Z' v gammaM.toml.")
        push!(z_values, String(Z))
        for (N, v_any) in row_any
            push!(n_values, String(N))
            base[(String(Z), String(N))] = Float64(v_any)
        end
    end

    unique_n = unique(n_values)
    for Z in unique(z_values), N in unique_n
        haskey(base, (Z, N)) ||
            error("V gammaM.toml chybí hodnota pro Z='$Z', N='$N'.")
    end
    base
end

const ZS = sort!(unique([z for (z, _) in keys(GAMMA_M_BASE)]))
const NS_SIMPLE =
    sort!(unique([n for (_, n) in keys(GAMMA_M_BASE)]))

const GAMMA_M_TABLE = begin
    table = Dict{Tuple{String,String},Float64}()
    for ((Z, N), value) in GAMMA_M_BASE
        table[(Z, N)] = value
    end

    combo_factor = 1.15
    for Z1 in ZS, Z2 in ZS
        z_key = string(Z1, "-", Z2)
        for N in NS_SIMPLE
            table[(z_key, N)] =
                max(GAMMA_M_BASE[(Z1, N)], GAMMA_M_BASE[(Z2, N)])
        end
        for i in eachindex(NS_SIMPLE)
            for j in (i + 1):lastindex(NS_SIMPLE)
                a = NS_SIMPLE[i]
                b = NS_SIMPLE[j]
                n_key = string(a, "-", b)
                candidates = (
                    GAMMA_M_BASE[(Z1, a)],
                    GAMMA_M_BASE[(Z2, b)],
                    GAMMA_M_BASE[(Z1, b)],
                    GAMMA_M_BASE[(Z2, a)],
                )
                value = round(maximum(candidates) * combo_factor; digits=2)
                table[(z_key, n_key)] = value
                table[(z_key, string(b, "-", a))] = value
            end
        end
    end
    table
end

const POVOLENE_N =
    sort!(unique([n for (_, n) in keys(GAMMA_M_TABLE)]))
const POVOLENE_Z =
    sort!(unique([z for (z, _) in keys(GAMMA_M_TABLE)]))

"""
$(read(joinpath(@__DIR__, "..", "..", "docs", "src", "materialy", "gammaM.md"), String))
"""
function gammaM(Z::AbstractString, N::AbstractString)
    if !(Z in POVOLENE_Z) && N in POVOLENE_Z && Z in POVOLENE_N
        Z, N = N, Z
    end

    key = (Z, N)
    if haskey(GAMMA_M_TABLE, key)
        return GAMMA_M_TABLE[key]
    end
    if !occursin("-", Z) && occursin("-", N)
        combined_key = (string(Z, "-", Z), N)
        if haskey(GAMMA_M_TABLE, combined_key)
            return GAMMA_M_TABLE[combined_key]
        end
    end

    error("Neznámá kombinace zatížení: Z=$Z, N=$N")
end
