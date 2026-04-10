# ver: 2026-04-10

# Struktura pro konkrétní profil s vybranou tloušťkou
struct Profil_TR4HR
    name::String                    # označení profilu
    standard::String                # norma
    a::Float64                      # rozměr [mm]
    b::Float64                      # rozměr [mm]
    t::Float64                      # tloušťka [mm]
    R::Float64                      # poloměr [mm]
    material::Vector{String}        # materiály - všechny textové hodnoty
end

# Struktura pro I profil s rozměry dle standardní tabulky
struct Profil_I
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
    material::Vector{String}        # materiály - všechny textové hodnoty
    material_info::String          # další informace o materiálu (např. "materiály - všechny textové hodnoty")
end
