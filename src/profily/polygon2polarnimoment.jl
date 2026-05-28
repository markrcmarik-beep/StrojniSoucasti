## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet polárního momentu plochy obecného tvaru
# (jednoduchého polygonu) pomoci bodu na obrysu.
# ver: 2026-05-19
## Funkce: polygon2polarnimoment()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/polygon2polarnimoment.jl
#
## Vzor:
## Jp = polygon2polarnimoment(body)
## Vstupní proměnné:
# body - vektor obsahující souřadnice bodů, které tvoří obrys 
#   polygonu. [vektor obsahující n-tice (x, y)]
## Výstupní proměnné:
# Jp - polární moment plochy obecného tvaru (jednoduchého polygonu) pomoci bodu na obrysu. [mm^4]
## Použité balíčky:
#
## Použité uživatelské funkce:
# polygon2kvadratickymoment()
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#

function polygon2polarnimoment(body::Union{AbstractVector,AbstractMatrix})
    m = polygon2kvadratickymoment(body)
    return m.Ix + m.Iy
end

function polygon2polarnimoment(body::NamedTuple{(:obrys, :otvory)})
    m = polygon2kvadratickymoment(body)
    return m.Ix + m.Iy
end

