## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Posune body o zadanou vzdálenost ve směru x a y.
# ver: 2026-05-09
## Funkce: posun_body()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/body/posun_body.jl
#
## Vzor:
## rotovane_body = posun_body(body, smer)
## Vstupní proměnné:
# body - vektor obsahující souřadnice bodů, které mají být posouvany.
# smer - vektor (dx, dy) určující posun ve směru x a y.
## Výstupní proměnné:
# posunute_body - vektor obsahující souřadnice posunutých bodů.
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#

function posun_body(body::Vector{<:Tuple{<:Real, <:Real}}, smer::Tuple{<:Real, <:Real})
    posunute_body = Vector{Tuple{Float64, Float64}}(undef, length(body))
    for i in eachindex(body)
        x, y = body[i]
        dx, dy = smer
        posunute_body[i] = (x + dx, y + dy)
    end
    return posunute_body
    
end
