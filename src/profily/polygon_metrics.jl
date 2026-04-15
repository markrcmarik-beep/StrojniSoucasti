## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-04-15
## Funkce: polygon_metrics()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/polygon_metrics.jl
#
## Vzor:
## vystupni_promenne = polygon_metrics(vstupni_promenne)
## Vstupní proměnné:
#
## Výstupní proměnné:
#
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#

function polygon_metrics(body::Union{AbstractVector,AbstractMatrix})
    n = _polygon_point_count(body)
    
    # Inicializace součtů
    sum_cross = zero(eltype(eltype(body))) # Pro výpočet obsahu (dvojnásobku)
    sum_cx = zero(eltype(eltype(body))) # Pro výpočet těžiště (x-ová složka)
    sum_cy = zero(eltype(eltype(body))) # Pro výpočet těžiště (y-ová složka)
    sum_ix0 = zero(eltype(eltype(body))) # Pro výpočet Ix kolem původní osy
    sum_iy0 = zero(eltype(eltype(body))) # Pro výpočet Iy kolem původní osy
    
    # Hlavní smyčka - dělení na trojúhelníky
    for i in 1:n
        j = i == n ? 1 : i + 1 # Index dalšího vrcholu (cyklicky)
        xi, yi = _polygon_point(body, i) # Souřadnice i-tého vrcholu
        xj, yj = _polygon_point(body, j) # Souřadnice j-tého vrcholu
        
        cross = xi * yj - xj * yi  # Základní determinant trojúhelníku
        
        sum_cross += cross # Pro výpočet obsahu (dvojnásobku)
        sum_cx += (xi + xj) * cross # Pro výpočet těžiště (x-ová složka)
        sum_cy += (yi + yj) * cross # Pro výpočet těžiště (y-ová složka)
        sum_ix0 += (yi^2 + yi*yj + yj^2) * cross    # Ix kolem původní osy
        sum_iy0 += (xi^2 + xi*xj + xj^2) * cross    # Iy kolem původní osy
    end
    
    iszero(sum_cross) && throw(ArgumentError("Degenerovaný polygon"))
    
    # Základní vlastnosti
    S_signed = sum_cross / 2 # Obsah (může být záporný podle orientace)
    S = abs(S_signed) # Absolutní hodnota obsahu
    cx = sum_cx / (3 * sum_cross) # Těžiště (x-ová složka)
    cy = sum_cy / (3 * sum_cross) # Těžiště (y-ová složka)
    
    # Moment setrvačnosti kolem původních os
    ix0 = sum_ix0 / 12 # Ix0 kolem osy x (původní)
    iy0 = sum_iy0 / 12 # Iy0 kolem osy y (původní)
    
    # Převod do centra těžiště (Steinerova věta)
    ix = ix0 - S_signed * cy^2 # Ix kolem osy x pro osu procházející těžištěm
    iy = iy0 - S_signed * cx^2 # Iy kolem osy y pro osu procházející těžištěm
    Jp = abs(ix + iy) # Polární moment setrvačnosti (pro osu procházející těžištěm)
    
    return (S, cx, cy, ix, iy, Jp)
end
