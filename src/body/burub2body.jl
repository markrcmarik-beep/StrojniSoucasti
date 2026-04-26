## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Z bodu A vede přímku pod úhlem u1, z bodu B vede přímku pod 
# úhlem u2. Vloží kružnici o poloměru R. Vytvoří tělo bodů, 
# které tvoří obrys poloměru R mezi těmito dvěma přímkami. 
# Definované body A, B nejsou součástí výstupu.
# Úhel měří ve směru "+" (proti směru hodin) od osy x [rad].
#
# ver: 2026-04-26
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

function burub2body(A, u1, R, u2, B)

    u = uu2u(u1, u2)
    if u < pi
        smer = "-"
    elseif u > pi
        smer = "+"
    else
        error("Neplatná hodnota u: $u. Musí být v rozsahu (0, 2*pi) a nesmí být rovna 0, pi.")
    end
    C = buub2b(A, u1, u2, B) # průsečík přímek
    B, C = ubru2bb(u1, C, R, u2) # body dotyku kružnice s přímkami

    body = [0 0; 1 0; 1 1; 0 1] # Příklad čtverce, nahraďte skutečnými body

    return body
end
