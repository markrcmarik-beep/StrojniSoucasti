
module Material2Types

export Material2

struct Material2
    name::String
    standard::String
    Re::Float64
    Rm_min::Float64
    Rm_max::Float64
    A::Float64
    KV::Float64
    T_KV::Float64
    weldable::Bool
    thickness_max::Float64
end

end
