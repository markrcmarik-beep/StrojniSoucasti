## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet polarniho momentu plochy obecneho tvaru
# (jednoducheho polygonu) pomoci bodu na obrysu.
# ver: 2026-04-08
## Funkce: polarniMomentBodu()
## Autor: Martin
#
## Cesta uvnitr balicku:
# StrojniSoucasti/src/profily/polarniMomentBodu.jl
###############################################################

"""
    polarniMomentBodu(body::AbstractVector | AbstractMatrix)

Vrati polarni kvadraticky moment plochy `Jp = Ix + Iy` vzhledem k tezisti
polygonu zadaneho obrysovymi body.

Poznamka:
- vyuziva sdileny vypocet geometrie ze souboru `plochaBodu.jl`.
"""
function polarniMomentBodu(body::Union{AbstractVector,AbstractMatrix})
    return _polygon_metrics(body).Jp
end

