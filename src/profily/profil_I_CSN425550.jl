## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrati I_CSN425550 struct s vlastnostmi I profilu z databaze CSN425550.
# ver: 2026-06-20
## Funkce: profil_I_CSN425550()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profil_I_CSN425550.jl
#
## Vzor:
## vystupni_promenne = profil_I_CSN425550(vstupni_promenne)
## Vstupní proměnné:
# - name::AbstractString: Oznaceni profilu (napr. "I100", "I 100")
## Výstupní proměnné:
# - I_CSN425550 struct s vlastnostmi profilu nebo nothing, pokud profil neexistuje.
#   Pokud profil existuje, struct obsahuje následující pole: (do nedefinované hodnoty uloženo nothing)
#   .name::String: název profilu
#   .serie::String: série profilu (např. "I")
#   .standard::String: norma (např. "ČSN 42 5550")
#   .standard_info::String: textový popis normy
#   .zkratka::String: zkratka pro rychlejší hledání v tabulce
#   .zkratka_info::String: popis zkratky - textová informace
#   .h::Float64: výška profilu [mm]
#   .h_unit::String: jednotka pro výšku
#   .h_info::String: popis výšky
#   .b::Float64: šířka pásnice [mm]
#   .b_unit::String: jednotka pro šířku pásnice
#   .b_info::String: popis šířky pásnice
#   .t1::Float64: tloušťka stojiny [mm]
#   .t1_unit::String: jednotka pro tloušťku stojiny
#   .t1_info::String: popis tloušťky stojiny
#   .t2::Float64: střední tloušťka pásnice [mm]
#   .t2_unit::String: jednotka pro střední tloušťku pásnice
#   .t2_info::String: popis střední tloušťky pásnice
#   .R::Float64: poloměr zaoblení výškové spojnice [mm]
#   .R_unit::String: jednotka pro poloměr zaoblení výškové spoj
#   .R_info::String: popis poloměru zaoblení výškové spojnice
#   .R1::Float64: poloměr zaoblení vnitřní šířky pásnice [mm]
#   .R1_unit::String: jednotka pro poloměr zaoblení vnitřní šířky pásnice
#   .R1_info::String: popis poloměru zaoblení vnitřní šířky pásnice
#   .sp::Float64: sklon příruby [%]
#   .sp_unit::String: jednotka pro sklon příruby
#   .sp_info::String: popis sklonu příruby
#   .m::Float64: hmotnost [kg/m]
#   .m_unit::String: jednotka pro hmotnost
#   .m_info::String: popis hmotnosti
#   .material::Vector{String}: pole textových hodnot materiálů, pro které je profil dostupný
#   .material_info::String: popis materiálů
#   .S::Float64: plocha průřezu [mm^2]
#   .S_unit::String: jednotka pro plochu průřezu
#   .S_info::String: popis plochy průřezu
#   .Ix::Float64: moment setrvačnosti podle osy x [mm^4]
#   .Ix_unit::String: jednotka pro moment setrvačnosti podle osy x
#   .Ix_info::String: popis momentu setrvačnosti podle osy x
#   .Wx::Float64: průřezový modul podle osy x [mm^3]
#   .Wx_unit::String: jednotka pro průřezový modul podle osy x
#   .Wx_info::String: popis průřezového modulu podle osy x
#   .ix::Float64: poloměr setrvačnosti podle osy x [mm]
#   .ix_unit::String: jednotka pro poloměr setrvačnosti podle osy x
#   .ix_info::String: popis poloměru setrvačnosti podle osy x
#   .Iy::Float64: moment setrvačnosti podle osy y [mm^4]
#   .Iy_unit::String: jednotka pro moment setrvačnosti podle osy y
#   .Iy_info::String: popis momentu setrvačnosti podle osy y
#   .Ixy::Float64: kvadratický moment setrvačnosti Ixy [mm^4]
#   .Ixy_unit::String: jednotka pro kvadratický moment setrvačnosti Ixy
#   .Ixy_info::String: popis kvadratického momentu setrvačnosti Ixy
#   .Imin::Float64: minimální moment setrvačnosti [mm^4]
#   .Imin_unit::String: jednotka pro minimální moment setrvačnosti
#   .Imin_info::String: popis minimálního momentu setrvačnosti
#   .Imax::Float64: maximální moment setrvačnosti [mm^4]
#   .Imax_unit::String: jednotka pro maximální moment setrvačnosti
#   .Imax_info::String: popis maximálního momentu setrvačnosti
#   .Wy::Float64: průřezový modul podle osy y [mm^3]
#   .Wy_unit::String: jednotka pro průřezový modul podle osy y
#   .Wy_info::String: popis průřezového modulu podle osy y
#   .iy::Float64: poloměr setrvačnosti podle osy y [mm]
#   .iy_unit::String: jednotka pro poloměr setrvačnosti podle osy y
#   .iy_info::String: popis poloměru setrvačnosti podle osy y
#   .Sx::Float64: statický moment podle osy x [mm^3]
#   .Sx_unit::String: jednotka pro statický moment podle osy x
#   .Sx_info::String: popis statického momentu podle osy x
#   .sx::Float64: staticka hodnota sx [mm]
#   .sx_unit::String: jednotka pro sx
#   .sx_info::String: popis sx
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
#
## Příklad:
# prof = profil_I_CSN425550("I 100")
# println(prof.h)  # 100.0
# println(prof.b)  # 50.0
###############################################################

using TOML

isdefined(@__MODULE__, :_profil_i_key_candidates) # funkce pro generování kandidátských klíčů pro hledání v tabulce profilů

struct I_CSN425550
    name::String # např. "I 100"
    serie::String # např. "I"
    standard::String # např. "ČSN 42 5550"
    standard_info::String # popis standardu - textová informace
    zkratka::String # zkratka pro rychlejší hledání v tabulce
    zkratka_info::String # popis zkratky - textová informace
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
    Ixy::Float64 # kvadratický moment [mm^4]
    Ixy_unit::String
    Ixy_info::String
    Imin::Float64 # minimální moment setrvačnosti [mm^4]
    Imin_unit::String
    Imin_info::String
    Imax::Float64 # maximální moment setrvačnosti [mm^4]
    Imax_unit::String
    Imax_info::String
    Wy::Float64 # prurezovy modul podle osy y [mm^3]
    Wy_unit::String
    Wy_info::String
    Jp::Union{Float64, Nothing} # Polární moment setrvačnosti [mm^4]
    Jp_unit::String
    Jp_info::String
    Jt::Union{Float64, Nothing} # Torsní moment setrvačnosti [mm^4]
    Jt_unit::String
    Jt_info::String
    J::Union{Float64, Nothing} # Torsní moment setrvačnosti [mm^4]
    J_unit::String
    J_info::String
    Wk::Union{Float64, Nothing} # Kroutící průřezový modul [mm^3]
    Wk_unit::String
    Wk_info::String
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
    Ix = haskey(row, "Ix") ? Float64(get(row, "Ix", 0.0)) : nothing
    Iy = haskey(row, "Iy") ? Float64(get(row, "Iy", 0.0)) : nothing
    return I_CSN425550(
        string("I", " ", size_part), # name
        "I", # serie
        "\u010CSN425550", # standard
        "norma - textova hodnota", # info o normě
        "ČSN", # zkratka pro rychlejší hledání v tabulce
        "zkratka pro rychlejší hledání v tabulce", # info o zkratce
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
        "Dostupné materiály pro tento profil",
        haskey(row, "S") ? Float64(get(row, "S", 0.0)) : nothing, # S - plocha prurezu [mm^2]
        "mm^2",
        "plocha prurezu [mm^2]",
        Ix, # Ix - moment setrvacnosti podle osy x [mm^4]
        "mm^4",
        "moment setrvacnosti podle osy x [mm^4]",
        Float64(get(row, "Wx", 0.0)), # Wx - prurezovy modul podle osy x [mm^3]
        "mm^3",
        "prurezovy modul podle osy x [mm^3]",
        Float64(get(row, "ix", 0.0)), # ix - polomer setrvacnosti podle osy x [mm]
        "mm",
        "polomer setrvacnosti podle osy x [mm]",
        Iy, # Iy - moment setrvacnosti podle osy y [mm^4]
        "mm^4",
        "moment setrvacnosti podle osy y [mm^4]",
        0.0, # Ixy - kvadratický moment [mm^4] - zatím není v tabulce, bude doplněno později
        "mm^4",
        "kvadratický moment [mm^4]",
        (Ix!==nothing && Iy!==nothing) ? Float64((Ix + Iy)/2-sqrt((Ix - Iy)^2/4 + 0^2)) : nothing, # Imin - minimální moment setrvačnosti [mm^4] - zatím není v tabulce, bude doplněno později
        "mm^4",
        "minimální moment setrvačnosti [mm^4]",
        (Ix!==nothing && Iy!==nothing) ? Float64((Ix + Iy)/2+sqrt((Ix - Iy)^2/4 + 0^2)) : nothing, # Imax - maximální moment setrvačnosti [mm^4] - zatím není v tabulce, bude doplněno později
        "mm^4",
        "maximální moment setrvačnosti [mm^4]",
        Float64(get(row, "Wy", 0.0)), # Wy - prurezovy modul podle osy y [mm^3]
        "mm^3",
        "prurezovy modul podle osy y [mm^3]",
        haskey(row, "Jp") ? Float64(get(row, "Jp", 0.0)) : nothing, # Jp - polární moment setrvačnosti [mm^4] - zatím není v tabulce, bude doplněno později
        "mm^4",
        "polární moment setrvačnosti [mm^4]",
        haskey(row, "Jt") ? Float64(get(row, "Jt", 0.0)) : nothing, # Jt - Torsní moment setrvačnosti [mm^4] - zatím není v tabulce, bude doplněno později
        "mm^4",
        "Torsní moment setrvačnosti [mm^4]",
        haskey(row, "J") ? Float64(get(row, "J", 0.0)) : nothing, # J - Torsní moment setrvačnosti [mm^4] - zatím není v tabulce, bude doplněno později
        "mm^4",
        "Torsní moment setrvačnosti [mm^4]",
        haskey(row, "Wk") ? Float64(get(row, "Wk", 0.0)) : nothing, # Wk - Kroutící průřezový modul [mm^3] - zatím není v tabulce, bude doplněno později
        "mm^3",
        "Kroutící průřezový modul [mm^3]",
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
