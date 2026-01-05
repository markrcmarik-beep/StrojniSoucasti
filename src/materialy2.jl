
module Materialy2

include("materialy2/types.jl")
include("materialy2/database.jl")

using .Material2Types
using .Material2Database

export materialy2

"""
    materialy2(name::AbstractString) -> Material2

Vrátí materiál podle označení (např. "S235JR+N").
"""
function materialy2(name::AbstractString)
    haskey(MATERIAL_DB, name) ||
        error("Materiál $name není v databázi")

    return MATERIAL_DB[name]
end

end