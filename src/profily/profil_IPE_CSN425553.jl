## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrati Profil_I struct s vlastnostmi IPE profilu z databaze CSN 42 5553.
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

struct IPE_CSN425553
    name::String                    # označení profilu
    serie::String                   # série (IPE, IPN, HEA, HEB, HEM)
    standard::String                # norma
    standard_info::String           # další informace o normě (např. "ČSN 42 5550")
    h::Float64                      # výška profilu [mm]
    h_unit::String                  # jednotka výšky
    h_info::String                  # další informace o výšce (např. "výška profilu")
    b::Float64                      # šířka pásnice [mm]
    b_unit::String                  # jednotka šířky
    b_info::String                  # další informace o šířce (např. "šířka pásnice")
    t1::Float64                     # tloušťka stojiny [mm]
    t1_unit::String                 # jednotka tloušťky stojiny
    t1_info::String                 # další informace o tloušťce stojiny (např. "tloušťka stojiny")
    t2::Float64                     # tloušťka pásnice [mm]
    t2_unit::String                 # jednotka tloušťky pásnice
    t2_info::String                 # další informace o tloušťce pásnice (např. "tloušťka pásnice")
    R::Float64                      # poloměr zaoblení [mm]
    R_unit::String                  # jednotka poloměru
    R_info::String                  # další informace o poloměru (např. "poloměr zaoblení výškové spojnice")
    R1::Float64                     # poloměr zaoblení vnitřní [mm]
    R1_unit::String                 # jednotka poloměru vnitřního
    R1_info::String                 # další informace o poloměru vnitřního (např. "poloměr zaoblení vnitřní šířky pásnice")
    sp::Float64                     # sklon příruby [%]
    sp_unit::String                 # jednotka sklonu příruby
    sp_info::String                 # další informace o sklonu příruby (např. "sklon příruby [%]")
    m::Float64                      # hmotnost [kg/m]
    m_unit::String                  # jednotka hmotnosti
    m_info::String                  # další informace o hmotnosti (např. "hmotnost [kg/m]")
    material::Vector{String}        # materiály - všechny textové hodnoty
    material_info::String           # další informace o materiálu (např. "materiály - všechny textové hodnoty")
    S::Float64                      # plocha průřezu [mm^2]
    S_unit::String                  # jednotka plochy průřezu
    S_info::String                  # další informace o ploše průřezu (např. "plocha průřezu [mm^2]")
    Ix::Float64                     # moment setrvačnosti podle osy x [mm^4]
    Ix_unit::String                 # jednotka momentu setrvačnosti Ix
    Ix_info::String                 # další informace o momentu setrvačnosti Ix (např. "moment setrvačnosti podle osy x [mm^4]")
    Wx::Float64                     # průřezový modul podle osy x [mm^3]
    Wx_unit::String                 # jednotka průřezového modulu Wx
    Wx_info::String                 # další informace o průřezovém modulu Wx (např. "průřezový modul podle osy x [mm^3]")
    ix::Float64                     # poloměr setrvačnosti podle osy x [mm]
    ix_unit::String                 # jednotka poloměru setrvačnosti ix
    ix_info::String                 # další informace o poloměru setrvačnosti ix (např. "poloměr setrvačnosti podle osy x [mm]")
    Iy::Float64                     # moment setrvačnosti podle osy y [mm^4]
    Iy_unit::String                 # jednotka momentu setrvačnosti Iy
    Iy_info::String                 # další informace o momentu setrvačnosti Iy (např. "moment setrvačnosti podle osy y [mm^4]")
    Wy::Float64                     # průřezový modul podle osy y [mm^3]
    Wy_unit::String                 # jednotka průřezového modulu Wy
    Wy_info::String                 # další informace o průřezovém modulu Wy (např. "průřezový modul podle osy y [mm^3]")
    iy::Float64                     # poloměr setrvačnosti podle osy y [mm]
    iy_unit::String                 # jednotka poloměru setrvačnosti iy
    iy_info::String                 # další informace o poloměru setrvačnosti iy (např. "poloměr setrvačnosti podle osy y [mm]")
    Sx::Float64                     # statický moment průřezu podle osy x [mm^3]
    Sx_unit::String                 # jednotka statického momentu průřezu Sx
    Sx_info::String                 # další informace o statickém momentu průřezu Sx (např. "statický moment průřezu podle osy x [mm^
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
    return _profil_i_from_row(row, "IPE", size_part, "\u010CSN 42 5553")
end
