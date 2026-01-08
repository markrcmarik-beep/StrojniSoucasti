
module MaterialSelect

using ..MaterialTypes
using ..MaterialDatabase
using ..MaterialRequestDef
using ..MaterialReduction

export select_material

function select_material(req::MaterialRequest)

    candidates = Material[]

    for m in values(MATERIAL_DB)
        Re_eff(m, req.thickness) ≥ req.Re_req || continue
        m.T_KV ≤ req.Tmin || continue
        (!req.welded || m.weldable) || continue
        m.thickness_max ≥ req.thickness || continue
        push!(candidates, m)
    end

    isempty(candidates) &&
        error("Nenalezen materiál vyhovující požadavkům")

    sort!(candidates, by = m -> Re_eff(m, req.thickness))
    return first(candidates)
end

end
