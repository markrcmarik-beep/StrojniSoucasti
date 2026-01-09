# ver: 2026-01-08

struct Material
    name::String
    standard::String
    Re::Float64          # nominální mez kluzu [MPa]
    Rm_min::Float64
    Rm_max::Float64
    A::Float64           # tažnost [%]
    KV::Float64          # rázová práce [J]
    T_KV::Float64        # teplota zkoušky [°C]
    weldable::Bool
    thickness_max::Float64
end
