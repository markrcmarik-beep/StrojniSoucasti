## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Rotuje body o zadaný úhel.
# ver: 2026-05-09
## Funkce: rotuj_body()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/body/rotuj_body.jl
#
## Vzor:
## rotovane_body = rotuj_body(body, natoceni)
## Vstupní proměnné:
# body - vektor obsahující souřadnice bodů, které mají být rotovány.
# natoceni - úhel o který mají být body rotovány. [rad]
# S - střed rotace (nepovinné) (výchozí hodnota je (0, 0))
## Výstupní proměnné:
# rotovane_body - vektor obsahující souřadnice rotovaných bodů.
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#

function rotuj_body(body::Vector{<:Tuple{<:Real, <:Real}}, natoceni::Real; S::Tuple{<:Real, <:Real}=(0, 0))
    rotovane_body = Vector{Tuple{Float64, Float64}}(undef, length(body))
    sx, sy = S
    for i in eachindex(body)
        x, y = body[i]
        x_rel = x - sx
        y_rel = y - sy
        x_rot = x_rel * cos(natoceni) - y_rel * sin(natoceni) + sx
        y_rot = x_rel * sin(natoceni) + y_rel * cos(natoceni) + sy
        rotovane_body[i] = (x_rot, y_rot)
    end
    return rotovane_body
    
end
