## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrati Profil_I struct s vlastnostmi IPE profilu z databaze CSN 42 5553.
# ver: 2026-04-16
## Funkce: profil_IPE_CSN425553()
## Autor: Martin
#
## Cesta uvnitr balicku:
# balicek/src/profily/profil_IPE_CSN425553.jl
#
## Vzor:
## vystupni_promenne = profil_IPE_CSN425553(vstupni_promenne)
## Vstupni promenne:
# - name::AbstractString: Oznaceni profilu (napr. "IPE100", "IPE 100")
## Vystupni promenne:
# - Profil_I struct s vlastnostmi profilu nebo nothing, pokud profil neexistuje.
## Pouzite balicky:
# TOML
## Pouzite uzivatelske funkce:
# profiltypes.jl, profil_I_CSN425550.jl (sdilene interni helpery)
## Priklad:
# prof = profil_IPE_CSN425553("IPE 100")
# println(prof.h)  # 100.0
# println(prof.b)  # 55.0
###############################################################

using TOML

isdefined(@__MODULE__, :Profil_I) || include("profiltypes.jl")

const IPE_DB_CSN425553 = TOML.parsefile(joinpath(@__DIR__, "profilIPE_CSN425553.toml"))

function profil_IPE_CSN425553(name::AbstractString)::Union{Profil_I, Nothing}
    s = uppercase(strip(name))
    s = replace(s, r"\s+" => "")

    m = match(r"^IPE(\d+(?:\.\d+)?)$", s)
    m === nothing && return nothing

    size_raw = String(m.captures[1])
    key_candidates = _profil_i_key_candidates("IPE", size_raw)

    row, key = _profil_i_find_row(IPE_DB_CSN425553, key_candidates)
    row === nothing && return nothing

    size_part = key[4:end]
    return _profil_i_from_row(row, "IPE", size_part, "\u010CSN 42 5553")
end
