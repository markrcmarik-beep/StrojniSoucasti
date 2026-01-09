# ver: 2026-01-08

"""
    select_material(req::MaterialRequest)

Vybere vhodný materiál podle specifikovaných požadavků.
Vrátí materiál s nejnižší pevností, který splňuje všechny požadavky.
"""
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
