## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypočítá souřadnice okrajových bodů B a C z vrcholu bodu A, úhlů (alfa, beta) od 
# osy x ve směru "+" (proti směru hodin) a poloměru zaoblemí (2D).
# ver: 2026-04-25
## Funkce: B, C = buur2bb(A, alfa, beta, r)
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/body/buur2bb.jl
#
## Vzor:
## vystupni_promenne = bdu2b(vstupni_promenne)
## Vstupní proměnné:
# A - souřadnice bodu A (tuple nebo pole s dvěma prvky)
# alfa - úhel mezi přímkou AB a vodorovnou osou (osa x) [rad]
# beta - úhel mezi přímkou AC a vodorovnou osou (osa x) [rad]
# r - poloměr kružnice, na které leží body B a C [mm]
## Výstupní proměnné:
# B - souřadnice bodu B (tuple s dvěma prvky)
# C - souřadnice bodu C (tuple s dvěma prvky)
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
# A = (10.0, 20.0) # souřadnice bodu A
# alfa = 30*pi/180 # úhel mezi přímkou AB a vodorovnou osou (osa x) [rad]
# beta = 45*pi/180 # úhel mezi přímkou AB a vodorovnou osou (osa x) [rad]
# r = 5.0 # poloměr kružnice, na které leží body B a C [mm]
# B, C = buur2bb(A, alfa, beta, r)
# println("Souřadnice bodu B: ", B)
###############################################################
## Použité proměnné vnitřní:
#

function buur2bb(A, alfa, beta, r)

    isa(A, Tuple) || error("A musí být tuple s dvěma prvky.")
    length(A) == 2 || error("A musí mít přesně dva prvky.")
    isa(alfa, Number) || error("alfa musí být číslo.")
    isa(beta, Number) || error("beta musí být číslo.")
    isa(r, Number) || error("r musí být číslo.")
    if alfa < 0 || alfa > 2*pi
        alfa = mod(alfa, 2*pi) # převod úhlu na interval [0, 2*pi]
    end
    if beta < 0 || beta > 2*pi
        beta = mod(beta, 2*pi) # převod úhlu na interval [0, 2*pi]
    end
    u = uu2u(alfa, beta)
    a = abs(r / tan(u/2))
    # Výpočet souřadnic bodu B
    B_x = A[1] + a * cos(alfa)
    B_y = A[2] + a * sin(alfa)
    B = (B_x, B_y)

    # Výpočet souřadnic bodu C
    C_x = A[1] + a * cos(beta)
    C_y = A[2] + a * sin(beta)
    C = (C_x, C_y)
        

    return B, C
end
