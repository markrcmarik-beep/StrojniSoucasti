## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet kvadratickych momentu plochy obecneho tvaru
# (polygonu) pomoci bodu na obrysu.
# ver: 2026-04-19
## Funkce: kvadratickyMomentBodu()
## Autor: Martin
#
## Cesta uvnitr balicku:
# StrojniSoucasti/src/profily/kvadratickyMomentBodu.jl
###############################################################

"""
    kvadratickyMomentBodu(body::AbstractVector | AbstractMatrix)
    kvadratickyMomentBodu(body::NamedTuple{(:obrys, :otvory)})

Vrati kvadraticke momenty plochy vzhledem k tezisti:
`(Ix = ..., Iy = ...)`.

Podporovane vstupy:
- jednoduchy polygon zadany body (vektor bodu `(x, y)` nebo matice `N x 2`),
- slozeny profil `(obrys = ..., otvory = ...)`, kde `otvory` muze byt
  jeden polygon otvoru nebo kolekce polygonu otvoru.
"""
function kvadratickyMomentBodu(body::Union{AbstractVector,AbstractMatrix})
    sums = _kvadraticky_moment_ring_sums(body, +1)
    return _kvadraticky_moment_finalize(sums)
end

function kvadratickyMomentBodu(body::NamedTuple{(:obrys, :otvory)})
    sums = _kvadraticky_moment_ring_sums(body.obrys, +1)
    for otvor in _kvadraticky_moment_normalizuj_otvory(body.otvory)
        hole_sums = _kvadraticky_moment_ring_sums(otvor, -1)
        sums = (
            sum_cross = sums.sum_cross + hole_sums.sum_cross,
            sum_cx = sums.sum_cx + hole_sums.sum_cx,
            sum_cy = sums.sum_cy + hole_sums.sum_cy,
            sum_ix0 = sums.sum_ix0 + hole_sums.sum_ix0,
            sum_iy0 = sums.sum_iy0 + hole_sums.sum_iy0,
        )
    end
    return _kvadraticky_moment_finalize(sums)
end

function _kvadraticky_moment_ring_sums(body::Union{AbstractVector,AbstractMatrix}, role_sign::Int)
    raw = _kvadraticky_moment_raw_polygon_sums(body)
    sign_raw = sign(raw.sum_cross)
    iszero(sign_raw) && throw(ArgumentError("Degenerovany polygon: plocha vychazi nulova."))
    factor = role_sign * sign_raw
    return (
        sum_cross = factor * raw.sum_cross,
        sum_cx = factor * raw.sum_cx,
        sum_cy = factor * raw.sum_cy,
        sum_ix0 = factor * raw.sum_ix0,
        sum_iy0 = factor * raw.sum_iy0,
    )
end

function _kvadraticky_moment_raw_polygon_sums(body::Union{AbstractVector,AbstractMatrix})
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

    return (
        sum_cross = sum_cross,
        sum_cx = sum_cx,
        sum_cy = sum_cy,
        sum_ix0 = sum_ix0,
        sum_iy0 = sum_iy0,
    )
end

function _kvadraticky_moment_finalize(sums::NamedTuple)
    iszero(sums.sum_cross) && throw(ArgumentError("Degenerovany prurez: plocha vychazi nulova."))
    s_signed = sums.sum_cross / 2
    s_signed > zero(s_signed) || throw(ArgumentError(
        "Neplatny prurez: plocha obrysu musi byt vetsi nez soucet ploch otvoru."
    ))

    cx = sums.sum_cx / (3 * sums.sum_cross)
    cy = sums.sum_cy / (3 * sums.sum_cross)
    ix0 = sums.sum_ix0 / 12
    iy0 = sums.sum_iy0 / 12

    Ix = ix0 - s_signed * cy^2
    Iy = iy0 - s_signed * cx^2
    return (Ix = abs(Ix), Iy = abs(Iy))
end

function _kvadraticky_moment_normalizuj_otvory(otvory::AbstractMatrix)
    return (otvory,)
end

function _kvadraticky_moment_normalizuj_otvory(otvory::Union{AbstractVector,Tuple})
    if isempty(otvory)
        return ()
    end
    first_item = first(otvory)
    if _kvadraticky_moment_je_bod(first_item)
        return (otvory,)
    end
    for otvor in otvory
        if !(otvor isa AbstractVector || otvor isa AbstractMatrix || otvor isa Tuple)
            throw(ArgumentError("Kazdy otvor musi byt polygon (vektor bodu nebo matice Nx2)."))
        end
    end
    return otvory
end

function _kvadraticky_moment_normalizuj_otvory(otvory)
    throw(ArgumentError("`otvory` musi byt polygon nebo kolekce polygonu."))
end

_kvadraticky_moment_je_bod(p::NTuple{2,Any}) = true
_kvadraticky_moment_je_bod(p::Tuple) = length(p) == 2
_kvadraticky_moment_je_bod(p::AbstractVector) = length(p) == 2
_kvadraticky_moment_je_bod(::Any) = false
