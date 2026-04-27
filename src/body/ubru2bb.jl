## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Z vrcholu bodu A vede přímky pod úhly (alfa, beta). Vypočítá 
# souřadnice okrajových bodů B a C pro kružnici o poloměru r, 
# která je osazena do vnitřního zaoblení mezi těmito přímkami. 
# Úhel měří ve směru "+" (proti směru hodin) od osy x [rad].
# ver: 2026-04-26
## Funkce: B, C = ubru2bb(alfa, A, r, beta)
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/body/ubru2bb.jl
#
## Vzor:
## vystupni_promenne = bdu2b(vstupni_promenne)
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

function ubru2bb(alfa::Real, A::Tuple{<:Real,<:Real},
    r::Real, beta::Real)

    r > 0 || throw(ArgumentError("r musí být kladné"))

    # úhel mezi přímkami (orientovaný)
    u = mod(beta - alfa, 2π)

    # vezmeme vnitřní úhel
    if u > π
        u = 2π - u
    end

    # degenerace
    if u < 1e-8
        throw(ArgumentError("Přímky jsou téměř rovnoběžné"))
    end
    if abs(u - π) < 1e-8
        throw(ArgumentError("Přímky jsou téměř v přímce"))
    end

    # vzdálenost tečných bodů
    a = r / tan(u/2)

    # směrové vektory
    d1 = (cos(alfa), sin(alfa))
    d2 = (cos(beta), sin(beta))

    # body dotyku
    B = (A[1] + a*d1[1], A[2] + a*d1[2])
    C = (A[1] + a*d2[1], A[2] + a*d2[2])

    return B, C
end
