# ver: 2026-01-08
module Materialy

using .MaterialTypes
using .MaterialDatabase
using .MaterialRequestDef
using .MaterialReduction
using .MaterialSelect

export
    materialy,
    MaterialRequest,
    select_material,
    reduced_properties,
    Re_eff,
    Rm_eff,
    A_eff

materialy(name::AbstractString) =
    haskey(MATERIAL_DB, name) ?
        MATERIAL_DB[name] :
        error("Materiál $name není v databázi")

end
