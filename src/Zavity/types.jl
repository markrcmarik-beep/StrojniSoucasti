
struct DbRecord
    name::String
    d::Float64
    pitch::Union{Float64, Nothing}
    extra::Dict{Symbol, Any}
end
