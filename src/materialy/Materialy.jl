
module Materialy

using ..MaterialTypes
using ..MaterialDatabase
using ..MaterialRequestDef
using ..MaterialSelect

export materialy, select_material, MaterialRequest

"""
    materialy(name::AbstractString) -> Material
"""
materialy(name::AbstractString) = MATERIAL_DB[name]

end
