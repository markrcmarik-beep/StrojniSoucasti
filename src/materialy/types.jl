# ver: 2026-01-12

struct Material
    name::String
    standard::String
    Re::Float64         # nominální mez kluzu [MPa]
    Rm_min::Float64     # mez pevnosti [MPa]
    Rm_max::Float64     # mez pevnosti max. [MPa]
    A::Float64          # tažnost [%]
    KV::Float64         # rázová práce [J]
    T_KV::Float64       # teplota zkoušky [°C]
    weldable::Bool      # svařitelnost
    thickness_max::Float64
    E::Float64          # Modul pružnosti (Youngův modul) [MPa]
    G::Float64          #
    ny::Float64         # Poissonovo číslo
    rho::Float64        # hustota [kg/m^3]
end
