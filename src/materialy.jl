
module Materialy

include("materialy/types.jl")
include("materialy/database.jl")

using .MaterialTypes
using .MaterialDatabase

export materialy

"""
    materialy(name::AbstractString) -> Material2

Vrátí materiál podle označení (např. "S235JR+N").
"""
function materialy(name::AbstractString)
    haskey(MATERIAL_DB, name) ||
        error("Materiál $name není v databázi")

    return MATERIAL_DB[name]
end

end