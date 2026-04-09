# ver: 2026-01-17

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
    h::Float64                      # výška profilu [mm]
    b::Float64                      # šířka pásnice [mm]
    tw::Float64                     # tloušťka stojiny [mm]
    tf::Float64                     # tloušťka pásnice [mm]
    r::Float64                      # poloměr zaoblení [mm]
    material::Vector{String}        # materiály - všechny textové hodnoty
end
