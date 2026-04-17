## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-04-17
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
    n = _polygon_point_count(body) # zkontroluje pocet bodu a vrati n

    x1, y1 = _polygon_point(body, 1) # zkontroluje format prvniho bodu a vrati x1, y1
    x2, y2 = _polygon_point(body, 2) # zkontroluje format druheho bodu a vrati x2, y2
    cross12 = x1 * y2 - x2 * y1 # pro kontrolu smeru bodu a pro dalsi vypocty

    sum_cross = zero(cross12) # pro vypocet plochy a smeru bodu
    sum_cx = zero((x1 + x2) * cross12) # pro vypocet souradnic teziste (cx, cy)
    sum_cy = zero((y1 + y2) * cross12) # pro vypocet souradnic teziste (cx, cy)
    sum_ix0 = zero((y1^2 + y1 * y2 + y2^2) * cross12) # pro vypocet momentu setrvacnosti kolem osy prochazejici tezistem (ix)
    sum_iy0 = zero((x1^2 + x1 * x2 + x2^2) * cross12) # pro vypocet momentu setrvacnosti kolem osy prochazejici tezistem (iy)

    for i in 1:n
        j = i == n ? 1 : i + 1 # index pro sousedni bod (posledni bod se spoji s prvnim)
        xi, yi = _polygon_point(body, i) # zkontroluje format bodu i a vrati xi, yi
        xj, yj = _polygon_point(body, j) # zkontroluje format bodu j a vrati xj, yj
        cross = xi * yj - xj * yi # pro vypocet plochy a smeru bodu a pro dalsi vypocty

        sum_cross += cross # pro vypocet plochy a smeru bodu
        sum_cx += (xi + xj) * cross # pro vypocet souradnic teziste (cx, cy)
        sum_cy += (yi + yj) * cross # pro vypocet souradnic teziste (cx, cy)
        sum_ix0 += (yi^2 + yi * yj + yj^2) * cross # pro vypocet momentu setrvacnosti kolem osy prochazejici tezistem (ix)
        sum_iy0 += (xi^2 + xi * xj + xj^2) * cross # pro vypocet momentu setrvacnosti kolem osy prochazejici tezistem (iy)
    end

    iszero(sum_cross) && throw(ArgumentError("Degenerovany polygon: plocha vychazi nulova."))

    s_signed = sum_cross / 2 # pro smer bodu (kladny pro proti smeru hodin, zaporny pro smer hodin)
    S = abs(s_signed) # pro absolutni hodnotu plochy, bez ohledu na smer bodu
    cx = sum_cx / (3 * sum_cross) # pro vypocet souradnic teziste (cx, cy)
    cy = sum_cy / (3 * sum_cross) # pro vypocet souradnic teziste (cx, cy)

    ix0 = sum_ix0 / 12 # pro vypocet momentu setrvacnosti kolem osy prochazejici tezistem (ix)
    iy0 = sum_iy0 / 12 # pro vypocet momentu setrvacnosti kolem osy prochazejici tezistem (iy)

    ix = ix0 - s_signed * cy^2 # pro vypocet momentu setrvacnosti kolem osy prochazejici tezistem (ix)
    iy = iy0 - s_signed * cx^2 # pro vypocet momentu setrvacnosti kolem osy prochazejici tezistem (iy)
    Jp = abs(ix + iy)

    return (S = S, cx = cx, cy = cy, Jp = Jp)
end

function _max_radius_from_centroid(body::Union{AbstractVector,AbstractMatrix}, cx, cy)
    n = _polygon_point_count(body) # zkontroluje pocet bodu a vrati n
    x1, y1 = _polygon_point(body, 1) # zkontroluje format prvniho bodu a vrati x1, y1
    r2max = zero((x1 - cx)^2 + (y1 - cy)^2) # pro vypocet maximalniho polomeru z teziste k obrysu (pro vypocet momentu setrvacnosti kolem osy prochazejici tezistem)

    for i in 1:n
        xi, yi = _polygon_point(body, i) # zkontroluje format bodu i a vrati xi, yi
        r2 = (xi - cx)^2 + (yi - cy)^2 # pro vypocet polomeru z teziste k bodu i
        if r2 > r2max # pro aktualizaci maximalniho polomeru z teziste k obrysu
            r2max = r2 # pro aktualizaci maximalniho polomeru z teziste k obrysu
        end
    end

    return sqrt(r2max)
end

function _polygon_point_count(body::AbstractVector)
    n = length(body)
    n >= 3 || throw(ArgumentError("Pro vypocet zadejte alespon 3 body."))
    return n
end

function _polygon_point_count(body::AbstractMatrix)
    size(body, 2) == 2 || throw(ArgumentError("Matice bodu musi mit presne 2 sloupce (x, y)."))
    n = size(body, 1)
    n >= 3 || throw(ArgumentError("Pro vypocet zadejte alespon 3 body."))
    return n
end

_polygon_point(body::AbstractVector, i::Int) = _point_xy(body[i])
_polygon_point(body::AbstractMatrix, i::Int) = (body[i, 1], body[i, 2])

function _point_xy(p::NTuple{2,Any})
    return p[1], p[2]
end

function _point_xy(p::Tuple)
    length(p) == 2 || throw(ArgumentError("Kazdy bod musi mit presne 2 souradnice (x, y)."))
    return p[1], p[2]
end

function _point_xy(p::AbstractVector)
    length(p) == 2 || throw(ArgumentError("Kazdy bod musi mit presne 2 souradnice (x, y)."))
    return p[1], p[2]
end

function _point_xy(p)
    throw(ArgumentError("Nepodporovany format bodu: $(typeof(p)). Pouzijte (x, y) nebo [x, y]."))
end
