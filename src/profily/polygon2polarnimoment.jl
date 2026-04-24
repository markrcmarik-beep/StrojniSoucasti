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

Vrati polarni kvadraticky moment plochy `Jp = Ix + Iy` vzhledem k tezisti
polygonu zadaneho obrysovymi body.

Poznamka:
- vyuziva sdileny vypocet geometrie ze souboru `plochaBodu.jl`.
"""
function polygon2polarnimoment(body::Union{AbstractVector,AbstractMatrix})
    return polygon_metrics(body).Jp
end

