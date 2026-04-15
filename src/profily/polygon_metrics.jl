
function polygon_metrics(body::Union{AbstractVector,AbstractMatrix})
    n = _polygon_point_count(body)
    
    # Inicializace součtů
    sum_cross = zero(eltype(eltype(body)))
    sum_cx = zero(eltype(eltype(body)))
    sum_cy = zero(eltype(eltype(body)))
    sum_ix0 = zero(eltype(eltype(body)))
    sum_iy0 = zero(eltype(eltype(body)))
    
    # Hlavní smyčka - dělení na trojúhelníky
    for i in 1:n
        j = i == n ? 1 : i + 1
        xi, yi = _polygon_point(body, i)
        xj, yj = _polygon_point(body, j)
        
        cross = xi * yj - xj * yi  # Základní determinant trojúhelníku
        
        sum_cross += cross
        sum_cx += (xi + xj) * cross
        sum_cy += (yi + yj) * cross
        sum_ix0 += (yi^2 + yi*yj + yj^2) * cross    # Ix kolem původní osy
        sum_iy0 += (xi^2 + xi*xj + xj^2) * cross    # Iy kolem původní osy
    end
    
    iszero(sum_cross) && throw(ArgumentError("Degenerovaný polygon"))
    
    # Základní vlastnosti
    S_signed = sum_cross / 2
    S = abs(S_signed)
    cx = sum_cx / (3 * sum_cross)
    cy = sum_cy / (3 * sum_cross)
    
    # Moment setrvačnosti kolem původních os
    ix0 = sum_ix0 / 12
    iy0 = sum_iy0 / 12
    
    # Převod do centra těžiště (Steinerova věta)
    ix = ix0 - S_signed * cy^2
    iy = iy0 - S_signed * cx^2
    Jp = abs(ix + iy)
    
    return (S, cx, cy, ix, iy, Jp)
end
