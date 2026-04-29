## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Z vrcholu bodu A vede polopřímky pod úhly (alfa, beta). Vypočítá 
# souřadnice okrajových bodů B (alfa), C (beta) pro kružnici o poloměru r, 
# která je osazena do vnitřního zaoblení (těsně) mezi těmito polopřímkami. 
# Úhel měří ve směru "+" (proti směru hodin) od osy x [rad].
# ver: 2026-04-28
## Funkce: B, C = ubru2bb(alfa, A, r, beta)
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/body/ubru2bb.jl
#
## Vzor:
## B, C = ubru2bb(alfa, A, r, beta)
## Vstupní proměnné:
# alfa - úhel mezi přímkou AB a vodorovnou osou (osa x) [rad]
# A - souřadnice bodu A (tuple s dvěma prvky)
# r - poloměr kružnice, na které leží body B a C (kladné číslo)
# beta - úhel mezi přímkou AC a vodorovnou osou (osa x) [rad]
## Výstupní proměnné:
# B - souřadnice bodu B (tuple s dvěma prvky)
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

function ubru2bb(alfa::Real, A::NTuple{2,<:Real}, r::Real, beta::Real)

    r > 0 || throw(ArgumentError("r musí být kladné"))
    # orientovaný úhel
    u_raw = mod(beta - alfa, 2π)
    # vnitřní úhel
    u = u_raw > π ? 2π - u_raw : u_raw
    if u < 1e-8
        throw(ArgumentError("Přímky jsou téměř rovnoběžné"))
    end
    if abs(u - π) < 1e-8
        throw(ArgumentError("Přímky jsou téměř v přímce"))
    end
    a = r / tan(u/2)
    d1 = (cos(alfa), sin(alfa))
    d2 = (cos(beta), sin(beta))
    B = (A[1] + a*d1[1], A[2] + a*d1[2])
    C = (A[1] + a*d2[1], A[2] + a*d2[2])

    return B, C
end
