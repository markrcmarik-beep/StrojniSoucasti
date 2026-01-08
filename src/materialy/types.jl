# ver: 2026-01-08
module MaterialTypes

export Material

struct Material
    name::String
    standard::String
    Re::Float64 # MPa
    Rm_min::Float64 # MPa
    Rm_max::Float64 # MPa
    A::Float64
    KV::Float64
    T_KV::Float64
    weldable::Bool
    thickness_max::Float64
end

end
