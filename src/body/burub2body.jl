## Funkce Julia v1.12
###############################################################
## Popis funkce:
# bod, úhel, poloměr, úhel, bod -> body
# Z bodu A vede přímku pod úhlem u1, z bodu B vede přímku pod 
# úhlem u2. Vloží kružnici o poloměru R. Vytvoří tělo bodů, 
# které tvoří obrys poloměru R mezi těmito dvěma přímkami. 
# Definované body A, B nejsou součástí výstupu.
# Úhel měří ve směru "+" (proti směru hodin) od osy x [rad].
#
# ver: 2026-04-28
## Funkce: burub2body()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/body/burub2body.jl
#
## Vzor:
## body = burub2body(A, u1, R, u2, B)
## Vstupní proměnné:
# A - souřadnice bodu A (tuple s dvěma prvky)
# u1 - úhel mezi přímkou AB a vodorovnou osou (osa x) [rad]
# R - poloměr kružnice, na které leží body B a C (kladné číslo)
# u2 - úhel mezi přímkou AC a vodorovnou osou (osa x) [rad]
# B - souřadnice bodu B (tuple s dvěma prvky)
## Výstupní proměnné:
# body - pole souřadnic bodů, které tvoří tělo (matice s 2 sloupci)
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#

function burub2body(
    A::Tuple{<:Real,<:Real},
    u1::Real,
    R::Real,
    u2::Real,
    B::Tuple{<:Real,<:Real},
    presnost::Real = 0.01
)

    R > 0 || throw(ArgumentError("R musí být kladné"))
    presnost > 0 || throw(ArgumentError("presnost musí být kladná"))
    # průsečík přímek
    P = buub2b(A, u1, u2, B)
    # úhel mezi přímkami
    u = mod(u2 - u1, 2π)
    # degenerace
    if u < 1e-8 || abs(u - 2π) < 1e-8
        throw(ArgumentError("Přímky jsou rovnoběžné"))
    end
    # vezmeme vnitřní úhel
    if u > π
        u = 2π - u
        smer = "+"
    else
        smer = "-"
    end
    # tečné body
    T1, T2 = ubru2bb(u1, P, R, u2)
    # oblouk
    body = brsb2body(T1, R, smer, T2, presnost)

    return body
end
