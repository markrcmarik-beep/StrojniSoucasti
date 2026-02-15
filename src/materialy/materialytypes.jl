# ver: 2026-02-13

struct MaterialOcel
    name::String        # název
    standard::String    # norma
    Re::Float64         # nominální mez kluzu [MPa]
    Rm_min::Float64     # mez pevnosti [MPa]
    Rm_max::Float64     # mez pevnosti max. [MPa]
    A::Float64          # tažnost [%]
    KV::Float64         # rázová práce [J]
    T_KV::Float64       # teplota zkoušky [°C]
    weldable::Bool      # svařitelnost
    thickness_max::Float64 # maximální tloušťka [mm]
    E::Float64          # Modul pružnosti (Youngův modul) [MPa]
    G::Float64          # Modul smyku [MPa]
    ny::Float64         # Poissonovo číslo
    rho::Float64        # hustota [kg/m^3]
    #extra::Dict{Symbol, Any}
end

struct MaterialKovy
    name::String        # název
    standard::String    # norma
    Re::Float64         # nominální mez kluzu [MPa]
    Rm_min::Float64     # mez pevnosti [MPa]
    Rm_max::Float64     # mez pevnosti max. [MPa]
    A::Float64          # tažnost [%]
    E::Float64          # Modul pružnosti (Youngův modul) [MPa]
    G::Float64          # Modul smyku [MPa]
    ny::Float64         # Poissonovo číslo
    rho::Float64        # hustota [kg/m^3]
    #extra::Dict{Symbol, Any}
end

struct MaterialLitina
    name::String        # název
    standard::String    # norma
    druh::String        # typ litiny
    Rm_tah::Float64     # mez pevnosti v tahu [MPa]
    Rm_tlak::Float64    # mez pevnosti v tlaku [MPa]
    A::Float64          # tažnost [%]
    HB_min::Float64     # minimální tvrdost Brinell [HB]
    HB_max::Float64     # maximální tvrdost Brinell [HB]
    E::Float64          # Modul pružnosti (Youngův modul) [GPa]
    G::Float64          # Modul smyku [GPa]
    ny::Float64         # Poissonovo číslo
    rho::Float64        # hustota [kg/m^3]
end
