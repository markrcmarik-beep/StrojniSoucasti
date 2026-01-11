# ver: 2026-01-08

"""
    thickness_band(mat::Material, thickness::Float64)

Vrátí třídu tloušťky materiálu podle jeho tloušťky.
"""
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

"""
    reduced_properties(mat::Material, thickness::Float64)

Vrátí redukované vlastnosti materiálu podle tloušťky.
"""
function reduced_properties(mat::Material, thickness::Float64)
    b = thickness_band(mat, thickness)
    return (
        Re = b.Re,
        Rm_min = b.Rm_min,
        Rm_max = b.Rm_max,
        A = b.A
    )
end

"""
    Re_eff(mat::Material, t::Float64)

Vrátí efektivní mez kluzu pro danou tloušťku.
"""
Re_eff(mat::Material, t::Float64) = thickness_band(mat, t).Re

"""
    Rm_eff(mat::Material, t::Float64)

Vrátí efektivní mez pevnosti (min, max) pro danou tloušťku.
"""
Rm_eff(mat::Material, t::Float64) =
    (thickness_band(mat, t).Rm_min, thickness_band(mat, t).Rm_max)

"""
    A_eff(mat::Material, t::Float64)

Vrátí efektivní tažnost pro danou tloušťku.
"""
A_eff(mat::Material, t::Float64)  = thickness_band(mat, t).A
