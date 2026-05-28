## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Sdilene pomocne funkce pro nacitani I/IPE profilu z TOML tabulek.
# ver: 2026-04-17
## Cesta uvnitr balicku:
# balicek/src/profily/profil_I_common.jl
#
## Pouzite uzivatelske funkce:
# (bez zavislosti na profiltypes.jl)
###############################################################

function _profil_i_key_candidates(serie::String, size_raw::String)::Vector{String}
    key_candidates = String[string(serie, size_raw)]
    size_val = parse(Float64, size_raw)
    normalized_key = string(serie, _profil_i_num_key(size_val))
    normalized_key != key_candidates[1] && push!(key_candidates, normalized_key)
    return key_candidates
end

function _profil_i_find_row(db, key_candidates::Vector{String})
    for key_candidate in key_candidates
        if haskey(db, key_candidate)
            return db[key_candidate], key_candidate
        end
    end
    return nothing, ""
end

function _profil_i_num_key(x::Float64)::String
    if x == floor(x)
        return string(Int(x))
    else
        return string(x)
    end
end
