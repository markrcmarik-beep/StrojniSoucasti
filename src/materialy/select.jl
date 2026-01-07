
module MaterialSelect

using ..MaterialTypes
using ..MaterialDatabase
using ..MaterialRequestDef

export select_material

"""
    select_material(req::MaterialRequest) -> Material

Vybere nejvhodnější materiál podle požadavků.
"""
function select_material(req::MaterialRequest)

    candidates = Material[]

    for m in values(MATERIAL_DB)

        m.Re ≥ req.Re_req        || continue
        m.T_KV ≤ req.Tmin        || continue
        (!req.welded || m.weldable) || continue
        m.thickness_max ≥ req.thickness || continue

        push!(candidates, m)
    end

    isempty(candidates) &&
        error("Nenalezen žádný materiál splňující požadavky")

    # Optimalizační kritérium:
    # nejnižší možná mez kluzu
    sort!(candidates, by = m -> m.Re)

    return first(candidates)
end

end
