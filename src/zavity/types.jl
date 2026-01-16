
struct DbRecord
    name::String # označení závitu
    d::Float64 # velký průměr
    p::Union{Float64, Nothing} # stoupání
    extra::Dict{Symbol, Any}
end
