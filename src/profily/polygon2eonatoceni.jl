## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce vypočítává vzdálenost nejvzdálenějšího vlákna od 
# neutrální osy (dle natoceni).
# ver: 2026-07-02
## Funkce: polygon2eonatoceni()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/polygon2eonatoceni.jl
#
## Vzor:
## eo = StrojniSoucasti.polygon2eonatoceni(body, natoceni)
## Vstupní proměnné:
# body – pole bodů profilu (např. body profilu TR4HR dle CSN 42 5720)   
# natoceni – úhel natočení profilu [rad]
## Výstupní proměnné:
# eo – vzdálenost nejvzdálenějšího vlákna od neutrální osy (dle natoceni)
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
function polygon2eonatoceni(::Nothing, natoceni=0)
    return nothing
end

function polygon2eonatoceni(body::Union{AbstractVector,AbstractMatrix}, natoceni=0)
    m = polygon_metrics(body)
    eo = _polygon2eonatoceni_max(body, m.cx, m.cy, natoceni)
    iszero(eo) && throw(ArgumentError("Nelze urcit eo: vzdalenost krajniho vlakna je nulova."))
    return eo
end

function polygon2eonatoceni(body::NamedTuple{(:obrys, :otvory)}, natoceni=0)
    cx, cy = _polygon2eonatoceni_teziste(body)
    eo = _polygon2eonatoceni_max(body.obrys, cx, cy, natoceni)
    for otvor in _kvadraticky_moment_normalizuj_otvory(body.otvory)
        eo_otvor = _polygon2eonatoceni_max(otvor, cx, cy, natoceni)
        if eo_otvor > eo
            eo = eo_otvor
        end
    end
    iszero(eo) && throw(ArgumentError("Nelze urcit eo: vzdalenost krajniho vlakna je nulova."))
    return eo
end

function polygon2eonatoceni(body, natoceni=0)
    throw(ArgumentError("`body` musi byt polygon (vektor bodu nebo matice Nx2) nebo NamedTuple (obrys, otvory)."))
end

function _polygon2eonatoceni_max(body::Union{AbstractVector,AbstractMatrix}, cx, cy, natoceni)
    n = _polygon_point_count(body)
    angle = mod(natoceni, 2*pi)
    sa = sin(angle)
    ca = cos(angle)

    x1, y1 = _polygon_point(body, 1)
    eo = abs((x1 - cx) * sa + (y1 - cy) * ca)
    for i in 2:n
        xi, yi = _polygon_point(body, i)
        vzdalenost = abs((xi - cx) * sa + (yi - cy) * ca)
        if vzdalenost > eo
            eo = vzdalenost
        end
    end
    return eo
end

function _polygon2eonatoceni_teziste(body::NamedTuple{(:obrys, :otvory)})
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
