## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-04-21
## Funkce: B = bdu2b(A, d, alfa)
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/body/bdu2b.jl
#
## Vzor:
## vystupni_promenne = bdu2b(vstupni_promenne)
## Vstupní proměnné:
# A - souřadnice bodu A (tuple nebo pole s dvěma prvky)
# d - vzdálenost mezi body A a B [mm]
# alfa - úhel mezi přímkou AB a vodorovnou osou (osa x) [rad]
## Výstupní proměnné:
# B - souřadnice bodu B (tuple s dvěma prvky)
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
# A = (10.0, 20.0) # souřadnice bodu A
# d = 5.0 # vzdálenost mezi body A a B [mm]
# alfa = 30.0 # úhel mezi přímkou AB a vodorovnou osou (osa x) [rad]
# B = bdu2b(A, d, alfa)
# println("Souřadnice bodu B: ", B)
###############################################################
## Použité proměnné vnitřní:
#

function bdu2b(A, d, alfa)

    Bx = A[1] + d * sin(alfa)
    By = A[2] + d * cos(alfa)
    B = (Bx, By)

    return B
end