## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrati I_CSN425550 struct s vlastnostmi I profilu z databaze CSN 42 5550.
# ver: 2026-04-18
## Funkce: profil_I_CSN425550()
## Autor: Martin
#
## Cesta uvnitr balicku:
# StrojniSoucasti/src/profily/profil_I_CSN425550.jl
#
## Vzor:
## vystupni_promenne = profil_I_CSN425550(vstupni_promenne)
## Vstupni promenne:
# - name::AbstractString: Oznaceni profilu (napr. "I100", "I 100")
## Vystupni promenne:
# - I_CSN425550 struct s vlastnostmi profilu nebo nothing, pokud profil neexistuje.
#   .name - název profilu
#   .serie - série profilu (např. "I")
#   .standard - norma (např. "ČSN 42 5550")
#   .standard_info - textový popis normy
#   .h - výška profilu [mm]
#   .h_unit - jednotka pro výšku
#   .h_info - popis výšky
#   .b - šířka pásnice [mm]
#   .b_unit - jednotka pro šířku pásnice
#   .b_info - popis šířky pásnice
#   .t1 - tloušťka stojiny [mm]
#   .t1_unit - jednotka pro tloušťku stojiny
#   .t1_info - popis tloušťky stojiny
#   .t2 - střední tloušťka pásnice [mm]
#   .t2_unit - jednotka pro střední tloušťku pásnice
#   .t2_info - popis střední tloušťky pásnice
#   .R - poloměr zaoblení výškové spojnice [mm]
#   .R_unit - jednotka pro poloměr zaoblení výškové spoj
#   .R_info - popis poloměru zaoblení výškové spojnice
#   .R1 - poloměr zaoblení vnitřní šířky pásnice [mm]
#   .R1_unit - jednotka pro poloměr zaoblení vnitřní šířky pásnice
#   .R1_info - popis poloměru zaoblení vnitřní šířky pásnice
#   .sp - sklon příruby [%]
#   .sp_unit - jednotka pro sklon příruby
#   .sp_info - popis sklonu příruby
#   .m - hmotnost [kg/m]
#   .m_unit - jednotka pro hmotnost
#   .m_info - popis hmotnosti
#   .material - pole textových hodnot materiálů, pro které je profil dostupný
#   .material_info - popis materiálů
#   .S - plocha průřezu [mm^2]
#   .S_unit - jednotka pro plochu průřezu
#   .S_info - popis plochy průřezu
#   .Ix - moment setrvačnosti podle osy x [mm^4]
#   .Ix_unit - jednotka pro moment setrvačnosti podle osy x
#   .Ix_info - popis momentu setrvačnosti podle osy x
#   .Wx - průřezový modul podle osy x [mm^3]
#   .Wx_unit - jednotka pro průřezový modul podle osy x
#   .Wx_info - popis průřezového modulu podle osy x
#   .ix - poloměr setrvačnosti podle osy x [mm]
#   .ix_unit - jednotka pro poloměr setrvačnosti podle osy x
#   .ix_info - popis poloměru setrvačnosti podle osy
#   .Iy - moment setrvačnosti podle osy y [mm^4]
#   .Iy_unit - jednotka pro moment setrvačnosti podle osy y
#   .Iy_info - popis momentu setrvačnosti podle osy y
#   .Wy - průřezový modul podle osy y [mm^3]
#   .Wy_unit - jednotka pro průřezový modul podle osy y
#   .Wy_info - popis průřezového modulu podle osy y
#   .iy - poloměr setrvačnosti podle osy y [mm]
#   .iy_unit - jednotka pro poloměr setrvačnosti podle osy y
#   .iy_info - popis poloměru setrvačnosti podle osy y
#   .Sx - statický moment podle osy x [mm^3]
#   .Sx_unit - jednotka pro statický moment podle osy x
#   .Sx_info - popis statického momentu podle osy x
#   .sx - staticka hodnota sx [mm]
#   .sx_unit - jednotka pro sx
#   .sx_info - popis sx
## Pouzite balicky:
# TOML
## Pouzite uzivatelske funkce:
# profil_I_common.jl
## Priklad:
# prof = profil_I_CSN425550("I 100")
# println(prof.h)  # 100.0
# println(prof.b)  # 50.0
###############################################################

using TOML

isdefined(@__MODULE__, :_profil_i_key_candidates) || include("profil_I_common.jl")

struct I_CSN425550
    name::String # např. "I 100"
    serie::String # např. "I"
    standard::String # např. "ČSN 42 5550"
    standard_info::String # popis standardu - textová informace
    h::Float64 # vyska profilu [mm]
    h_unit::String
    h_info::String
    b::Float64 # sirka pasnice [mm]
    b_unit::String
    b_info::String
    t1::Float64 # tloustka stojiny [mm]
    t1_unit::String
    t1_info::String
    t2::Float64 # stredni tloustka pasnice [mm]
    t2_unit::String
    t2_info::String
    R::Float64 # polomer zaobleni vyskove spojnice [mm]
    R_unit::String
    R_info::String
    R1::Float64 # polomer zaobleni vnitrni sirky pasnice [mm]
    R1_unit::String
    R1_info::String
    sp::Float64 # sklon příruby [%]
    sp_unit::String
    sp_info::String
    m::Float64 # hmotnost [kg/m]
    m_unit::String
    m_info::String
    material::Vector{String}
    material_info::String
    S::Float64 # plocha prurezu [mm^2]
    S_unit::String
    S_info::String
    Ix::Float64 # moment setrvacnosti podle osy x [mm^4]
    Ix_unit::String
    Ix_info::String
    Wx::Float64 # prurezovy modul podle osy x [mm^3]
    Wx_unit::String
    Wx_info::String
    ix::Float64 # polomer setrvacnosti podle osy x [mm]
    ix_unit::String
    ix_info::String
    Iy::Float64 # moment setrvacnosti podle osy y [mm^4]
    Iy_unit::String
    Iy_info::String
    Wy::Float64 # prurezovy modul podle osy y [mm^3]
    Wy_unit::String
    Wy_info::String
    iy::Float64 # polomer setrvacnosti podle osy y [mm]
    iy_unit::String
    iy_info::String
    Sx::Float64 # staticky moment podle osy x [mm^3]
    Sx_unit::String
    Sx_info::String
    sx::Float64 # staticka hodnota sx [mm]
    sx_unit::String
    sx_info::String
end

const I_DB_CSN425550 = TOML.parsefile(joinpath(@__DIR__, "profil_I_CSN425550.toml"))

function profil_I_CSN425550(name::AbstractString)::Union{I_CSN425550, Nothing}
    s = uppercase(strip(name))
    s = replace(s, r"\s+" => "")

    m = match(r"^I(\d+(?:\.\d+)?)$", s)
    m === nothing && return nothing

    size_raw = String(m.captures[1])
    key_candidates = _profil_i_key_candidates("I", size_raw)

    row, key = _profil_i_find_row(I_DB_CSN425550, key_candidates)
    row === nothing && return nothing

    size_part = key[2:end]
    sx_val = Float64(get(row, "sx", 0.0))
    sx_mm = sx_val > 0.0 ? sx_val : 0.0
    Sx_from_table = get(row, "Sx", nothing)
    Sx_val = Sx_from_table === nothing ? (sx_mm > 0.0 ? Float64(get(row, "Ix", 0.0)) / sx_mm : 0.0) : Float64(Sx_from_table)

    return I_CSN425550(
        string("I", " ", size_part), # name
        "I", # serie
        "\u010CSN 42 5550", # standard
        "norma - textova hodnota", # info o normě
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
        Sx_val, # Sx - staticky moment podle osy x [mm^3]
        "mm^3",
        "staticky moment prurezu podle osy x [mm^3]",
        sx_mm, # sx - staticka hodnota sx [mm]
        "mm",
        "staticka hodnota sx [mm]"
    )
end

# Zpetna kompatibilita puvodniho API.
function profilI(name::AbstractString)
    prof = profil_IPE_CSN425553(name)
    prof === nothing || return prof
    return profil_I_CSN425550(name)
end
