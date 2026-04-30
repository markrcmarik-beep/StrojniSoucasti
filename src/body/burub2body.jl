## Funkce Julia v1.12
###############################################################
## Popis funkce:
# bod, úhel, poloměr, úhel, bod -> body
# Z bodu A vede úsečku AP pod úhlem u1, z bodu BP vede úsečku pod 
# úhlem u2. Obě úsečky se spojí v bodě P. Vloží kružnici o 
# poloměru R tečnou na obě polopřímky. Vytvoří tělo bodů, které 
# tvoří obrys poloměru R mezi těmito dvěma polopřímkami. 
# Definované body A, B nejsou součástí výstupu.
# Úhel měří ve směru "+" (proti směru hodin) od osy x [rad].
# Pracuje v rovině (x, y).
#
# ver: 2026-04-30
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
    # průsečík nosných přímek
    P = buub2b(A, u1, u2, B)

    # Vstupní úhly mohou být zadány v obou orientacích (u nebo u+π).
    # Vybereme takovou kombinaci, kde tečné body leží na úsečkách A-P a B-P.
    found = false
    T1 = (0.0, 0.0)
    T2 = (0.0, 0.0)
    smer = "+"
    for du1 in (0.0, π)
        alfa = u1 + du1
        for du2 in (0.0, π)
            beta = u2 + du2
            local T1c, T2c
            try
                T1c, T2c = ubru2bb(alfa, P, R, beta)
            catch err
                if err isa ArgumentError
                    continue
                end
                rethrow()
            end

            if !_point_on_segment(T1c, A, P) || !_point_on_segment(T2c, B, P)
                continue
            end

            u = mod(beta - alfa, 2π)
            if u < 1e-8 || abs(u - 2π) < 1e-8
                continue
            end

            smer = u > π ? "+" : "-"
            T1 = T1c
            T2 = T2c
            found = true
            break
        end
        found && break
    end

    found || throw(ArgumentError(
        "Pro zadané A, u1, R, u2, B nelze vytvořit tečné zaoblení mezi úsečkami A-P a B-P."
    ))

    # oblouk
    body = brsb2body(T1, R, smer, T2, presnost)

    return body
end

function _point_on_segment(
    P::Tuple{<:Real,<:Real},
    A::Tuple{<:Real,<:Real},
    B::Tuple{<:Real,<:Real};
    tol::Real=1e-8
)
    AB = (B[1] - A[1], B[2] - A[2])
    AP = (P[1] - A[1], P[2] - A[2])
    cross = AB[1]*AP[2] - AB[2]*AP[1]
    dot = AB[1]*AP[1] + AB[2]*AP[2]
    len2 = AB[1]^2 + AB[2]^2
    return abs(cross) <= tol && dot >= -tol && dot <= len2 + tol
end
