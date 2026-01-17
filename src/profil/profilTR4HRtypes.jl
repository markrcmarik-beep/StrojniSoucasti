# ver: 2026-01-17

# Struktura pro ukládání více hodnot - používá se v profilTR4HR.jl
struct ProfileData
    name::String                    # označení profilu
    standard::String                # norma
    a::Float64                      # rozměr [mm]
    b::Float64                      # rozměr [mm]
    t::Vector{Float64}              # tloušťky [mm] - více hodnot
    R::Vector{Float64}              # poloměry [mm] - více hodnot
    material::Vector{String}        # materiály - více textových hodnot
end
