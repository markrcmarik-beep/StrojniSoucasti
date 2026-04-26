## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Z vstupního bodu A vede přímku pod úhlem u1. Poté vede přímku 
# pod úhlem u2 do bodu B. Funkce vypočítá souřadnice bodu C, 
# který je průsečíkem těchto dvou přímek.
# Úhel měří ve směru "+" (proti směru hodin) od osy x [rad].
#
# ver: 2026-04-26
## Funkce: buub2b()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/body/buub2b.jl
#
## Vzor:
## vystupni_promenne = buub2b(vstupni_promenne)
## Vstupní proměnné:
# A - souřadnice bodu A (tuple s dvěma prvky)
# u1 - úhel mezi přímkou AB a vodorovnou osou (osa x) [rad]
# u2 - úhel mezi přímkou AC a vodorovnou osou (osa x) [rad]
# B - souřadnice bodu B (tuple s dvěma prvky)
## Výstupní proměnné:
# C - souřadnice bodu C (tuple s dvěma prvky)
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#

function buub2b(A::NTuple{2,<:Real}, u1::Real, u2::Real, 
    B::NTuple{2,<:Real})

    # směrové vektory
    d1 = (cos(u1), sin(u1)) # jednotkový vektor ve směru u1
    d2 = (cos(u2), sin(u2)) # jednotkový vektor ve směru u2

    # determinant (2D "cross product")
    det = d1[1]*d2[2] - d1[2]*d2[1] #

    abs(det) < 1e-12 && error("Přímky jsou rovnoběžné")

    # řešení parametru t
    dx = B[1] - A[1] # rozdíl x souřadnic mezi B a A
    dy = B[2] - A[2] # rozdíl y souřadnic mezi B a A

    t = (dx * d2[2] - dy * d2[1]) / det # parametr pro přímku 1

    Cx = A[1] + t * d1[1] # x souřadnice průsečíku
    Cy = A[2] + t * d1[2] # y souřadnice průsečíku

    return (Cx, Cy)
end
