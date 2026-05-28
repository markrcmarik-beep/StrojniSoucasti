## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet prurezoveho modulu v krutu obecneho tvaru
# (jednoducheho polygonu) pomoci bodu na obrysu.
# ver: 2026-05-19
## Funkce: polygon2prurezovymodulkrut()
## Autor: Martin
#
## Cesta uvnitr balicku:
# StrojniSoucasti/src/profily/polygon2prurezovymodulkrut.jl
#
## Vzor:
## Wk = polygon2prurezovymodulkrut(body)
## Vstupní proměnné:
# body - vektor obsahující souřadnice bodů, které tvoří obrys 
#   polygonu. [vektor obsahující n-tice (x, y)]
## Výstupní proměnné:
# Wk - prurezovy modul v krutu obecneho tvaru (jednoducheho polygonu) 
#   pomoci bodu na obrysu. [mm^3]
## Použité balíčky
#
## Použité uživatelské funkce:
# polygon2polarnimoment()
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#

function polygon2prurezovymodulkrut(body::Union{AbstractVector,AbstractMatrix})
    m = polygon_metrics(body)
    rmax = _max_radius_from_centroid(body, m.cx, m.cy)
    iszero(rmax) && throw(ArgumentError("Nelze urcit prurezovy modul v krutu: rmax je nulove."))
    return polygon2polarnimoment(body) / rmax
end

function polygon2prurezovymodulkrut(body::NamedTuple{(:obrys, :otvory)})
    cx, cy = _prurezovymodulkrut_teziste(body)
    rmax = _max_radius_from_centroid(body.obrys, cx, cy)
    for otvor in _kvadraticky_moment_normalizuj_otvory(body.otvory)
        rmax_otvor = _max_radius_from_centroid(otvor, cx, cy)
        if rmax_otvor > rmax
            rmax = rmax_otvor
        end
    end
    iszero(rmax) && throw(ArgumentError("Nelze urcit prurezovy modul v krutu: rmax je nulove."))
    return polygon2polarnimoment(body) / rmax
end

function _prurezovymodulkrut_teziste(body::NamedTuple{(:obrys, :otvory)})
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

    iszero(sums.sum_cross) && throw(ArgumentError("Degenerovany prurez: plocha vychazi nulova."))
    s_signed = sums.sum_cross / 2
    s_signed > zero(s_signed) || throw(ArgumentError(
        "Neplatny prurez: plocha obrysu musi byt vetsi nez soucet ploch otvoru."
    ))

    cx = sums.sum_cx / (3 * sums.sum_cross)
    cy = sums.sum_cy / (3 * sums.sum_cross)
    return cx, cy
end

