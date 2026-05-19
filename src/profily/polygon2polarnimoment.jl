## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet polarniho momentu plochy obecneho tvaru
# (jednoducheho polygonu) pomoci bodu na obrysu.
# ver: 2026-04-24
## Funkce: polygon2polarnimoment()
## Autor: Martin
#
## Cesta uvnitr balicku:
# StrojniSoucasti/src/profily/polygon2polarnimoment.jl
###############################################################

"""
    polygon2polarnimoment(body::AbstractVector | AbstractMatrix)
    polygon2polarnimoment(body::NamedTuple{(:obrys, :otvory)})

Vrati polarni kvadraticky moment plochy `Jp = Ix + Iy` vzhledem k tezisti
polygonu zadaneho obrysovymi body.

Poznamka:
- `Jp` se pocita z bodu polygonu pres kvadraticke momenty `Ix` a `Iy`,
- podporuje i slozeny profil `(obrys = ..., otvory = ...)`.
"""
function polygon2polarnimoment(body::Union{AbstractVector,AbstractMatrix})
    m = polygon2kvadratickymoment(body)
    return m.Ix + m.Iy
end

function polygon2polarnimoment(body::NamedTuple{(:obrys, :otvory)})
    m = polygon2kvadratickymoment(body)
    return m.Ix + m.Iy
end

