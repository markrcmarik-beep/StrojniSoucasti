## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet prurezoveho modulu v krutu obecneho tvaru
# (jednoducheho polygonu) pomoci bodu na obrysu.
# ver: 2026-04-24
## Funkce: polygon2prurezovymodulkrut()
## Autor: Martin
#
## Cesta uvnitr balicku:
# StrojniSoucasti/src/profily/polygon2prurezovymodulkrut.jl
###############################################################

"""
    polygon2prurezovymodulkrut(body::AbstractVector | AbstractMatrix)

Vrati prurezovy modul v krutu z obrysovych bodu:
`Wk = Jp / rmax`, kde `Jp` je polarni moment vzhledem k tezisti a
`rmax` je nejvetsi vzdalenost obrysoveho bodu od teziste.

Poznamka:
- pro obecne ne-kruhove tvary jde o geometrickou aproximaci,
- vyuziva sdilene helpery ze souboru `plochaBodu.jl`.
"""
function polygon2prurezovymodulkrut(body::Union{AbstractVector,AbstractMatrix})
    m = polygon_metrics(body)
    rmax = _max_radius_from_centroid(body, m.cx, m.cy)
    iszero(rmax) && throw(ArgumentError("Nelze urcit prurezovy modul v krutu: rmax je nulove."))
    return m.Jp / rmax
end

