## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Z vstupního bodu A vede přímku pod úhlem u1. Z bodu B vede 
# přímku pod úhlem u2. Funkce vypočítá souřadnice bodu C, 
# který je průsečíkem těchto dvou přímek.
# Úhel měří ve směru "+" (proti směru hodin) od osy x [rad].
#
# ver: 2026-04-27
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

function buub2b(
    A::NTuple{2,<:Real},
    u1::Real,
    u2::Real,
    B::NTuple{2,<:Real}
)
    # směrové vektory
    d1 = (cos(u1), sin(u1))
    d2 = (cos(u2), sin(u2))

    # determinant
    det = d1[1]*d2[2] - d1[2]*d2[1]

    if abs(det) < 1e-12
        throw(ArgumentError("Přímky jsou rovnoběžné nebo téměř rovnoběžné"))
    end

    # rozdíl bodů
    dx = B[1] - A[1]
    dy = B[2] - A[2]

    # parametr
    t = (dx * d2[2] - dy * d2[1]) / det

    return (A[1] + t*d1[1], A[2] + t*d1[2])
end
