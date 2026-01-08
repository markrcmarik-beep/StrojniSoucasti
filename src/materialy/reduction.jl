
module MaterialReduction

using ..MaterialTypes
using ..MaterialReductionTables

export thickness_band, reduced_properties, Re_eff, Rm_eff, A_eff

function thickness_band(mat::Material, thickness::Float64)
    haskey(REDUCTION_TABLES, mat.Re) ||
        error("Neexistuje redukční tabulka pro Re=$(mat.Re)")

    for b in REDUCTION_TABLES[mat.Re]
        if thickness > b.t_min && thickness ≤ b.t_max
            return b
        end
    end

    error("Tloušťka $thickness mm mimo normový rozsah")
end

function reduced_properties(mat::Material, thickness::Float64)
    b = thickness_band(mat, thickness)
    return (
        Re = b.Re,
        Rm_min = b.Rm_min,
        Rm_max = b.Rm_max,
        A = b.A
    )
end

Re_eff(mat::Material, t::Float64) = thickness_band(mat, t).Re
Rm_eff(mat::Material, t::Float64) =
    (thickness_band(mat, t).Rm_min, thickness_band(mat, t).Rm_max)
A_eff(mat::Material, t::Float64)  = thickness_band(mat, t).A

end
