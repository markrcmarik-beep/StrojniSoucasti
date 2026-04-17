## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrati IPE_CSN425553 struct s vlastnostmi IPE profilu z databaze CSN 42 5553.
# ver: 2026-04-17
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
# - IPE_CSN425553 struct s vlastnostmi profilu nebo nothing, pokud profil neexistuje.
## Pouzite balicky:
# TOML
## Pouzite uzivatelske funkce:
# profiltypes.jl, profil_I_common.jl (sdilene interni helpery)
## Priklad:
# prof = profil_IPE_CSN425553("IPE 100")
# println(prof.h)  # 100.0
# println(prof.b)  # 55.0
###############################################################

using TOML

isdefined(@__MODULE__, :Profil_I) || include("profiltypes.jl")
isdefined(@__MODULE__, :_profil_i_key_candidates) || include("profil_I_common.jl")

struct IPE_CSN425553
    name::String
    serie::String
    standard::String
    standard_info::String
    h::Float64
    h_unit::String
    h_info::String
    b::Float64
    b_unit::String
    b_info::String
    t1::Float64
    t1_unit::String
    t1_info::String
    t2::Float64
    t2_unit::String
    t2_info::String
    R::Float64
    R_unit::String
    R_info::String
    R1::Float64
    R1_unit::String
    R1_info::String
    sp::Float64
    sp_unit::String
    sp_info::String
    m::Float64
    m_unit::String
    m_info::String
    material::Vector{String}
    material_info::String
    S::Float64
    S_unit::String
    S_info::String
    Ix::Float64
    Ix_unit::String
    Ix_info::String
    Wx::Float64
    Wx_unit::String
    Wx_info::String
    ix::Float64
    ix_unit::String
    ix_info::String
    Iy::Float64
    Iy_unit::String
    Iy_info::String
    Wy::Float64
    Wy_unit::String
    Wy_info::String
    iy::Float64
    iy_unit::String
    iy_info::String
    Sx::Float64
    Sx_unit::String
    Sx_info::String
end

const IPE_DB_CSN425553 = TOML.parsefile(joinpath(@__DIR__, "profil_IPE_CSN425553.toml"))

function profil_IPE_CSN425553(name::AbstractString)::Union{IPE_CSN425553, Nothing}
    s = uppercase(strip(name))
    s = replace(s, r"\s+" => "")

    m = match(r"^IPE(\d+(?:\.\d+)?)$", s)
    m === nothing && return nothing

    size_raw = String(m.captures[1])
    key_candidates = _profil_i_key_candidates("IPE", size_raw)

    row, key = _profil_i_find_row(IPE_DB_CSN425553, key_candidates)
    row === nothing && return nothing

    size_part = key[4:end]
    return IPE_CSN425553(
        string("IPE", " ", size_part),
        "IPE",
        "\u010CSN 42 5553",
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

function Base.convert(::Type{Profil_I}, prof::IPE_CSN425553)::Profil_I
    values = ntuple(i -> getfield(prof, i), fieldcount(IPE_CSN425553))
    return Profil_I(values...)
end
