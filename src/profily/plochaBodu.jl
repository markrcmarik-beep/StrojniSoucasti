## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet plochy obecneho tvaru (jednoducheho polygonu)
# pomoci bodu na obrysu. Sdilene helpery v tomto souboru
# pouzivaji i dalsi funkce v samostatnych souborech.
# ver: 2026-04-08
## Funkce: plochaBodu()
## Autor: Martin
#
## Cesta uvnitr balicku:
# StrojniSoucasti/src/profily/plochaBodu.jl
###############################################################

"""
    plochaBodu(body::AbstractVector | AbstractMatrix)

Vrati plochu polygonu zadaneho obrysovymi body.
Podporuje vstup jako vektor bodu `(x, y)` nebo matici `N x 2`.
"""
function plochaBodu(body::Union{AbstractVector,AbstractMatrix})
    return _polygon_metrics(body).S
end

function _polygon_metrics(body::Union{AbstractVector,AbstractMatrix})
    n = _polygon_point_count(body)

    x1, y1 = _polygon_point(body, 1)
    x2, y2 = _polygon_point(body, 2)
    cross12 = x1 * y2 - x2 * y1

    sum_cross = zero(cross12)
    sum_cx = zero((x1 + x2) * cross12)
    sum_cy = zero((y1 + y2) * cross12)
    sum_ix0 = zero((y1^2 + y1 * y2 + y2^2) * cross12)
    sum_iy0 = zero((x1^2 + x1 * x2 + x2^2) * cross12)

    for i in 1:n
        j = i == n ? 1 : i + 1
        xi, yi = _polygon_point(body, i)
        xj, yj = _polygon_point(body, j)
        cross = xi * yj - xj * yi

        sum_cross += cross
        sum_cx += (xi + xj) * cross
        sum_cy += (yi + yj) * cross
        sum_ix0 += (yi^2 + yi * yj + yj^2) * cross
        sum_iy0 += (xi^2 + xi * xj + xj^2) * cross
    end

    iszero(sum_cross) && throw(ArgumentError("Degenerovany polygon: plocha vychazi nulova."))

    s_signed = sum_cross / 2
    S = abs(s_signed)
    cx = sum_cx / (3 * sum_cross)
    cy = sum_cy / (3 * sum_cross)

    ix0 = sum_ix0 / 12
    iy0 = sum_iy0 / 12

    ix = ix0 - s_signed * cy^2
    iy = iy0 - s_signed * cx^2
    Jp = abs(ix + iy)

    return (S = S, cx = cx, cy = cy, Jp = Jp)
end

function _max_radius_from_centroid(body::Union{AbstractVector,AbstractMatrix}, cx, cy)
    n = _polygon_point_count(body)
    x1, y1 = _polygon_point(body, 1)
    r2max = zero((x1 - cx)^2 + (y1 - cy)^2)

    for i in 1:n
        xi, yi = _polygon_point(body, i)
        r2 = (xi - cx)^2 + (yi - cy)^2
        if r2 > r2max
            r2max = r2
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
