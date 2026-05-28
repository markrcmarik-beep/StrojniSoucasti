## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypočítá souřadnice bodu B z bodu A, vzdálenosti a úhlu (alfa) od 
# osy x ve směru "+" (proti směru hodin) (2D).
# ver: 2026-04-22
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
# alfa = 30*pi/180 # úhel mezi přímkou AB a vodorovnou osou (osa x) [rad]
# B = bdu2b(A, d, alfa)
# println("Souřadnice bodu B: ", B)
###############################################################
## Použité proměnné vnitřní:
#

function bdu2b(A, d, alfa)

    isa(A, Tuple) || error("A musí být tuple s dvěma prvky.")
    length(A) == 2 || error("A musí mít přesně dva prvky.")
    isa(d, Number) || error("d musí být číslo.")
    isa(alfa, Number) || error("alfa musí být číslo.")
    Bx = A[1] + d * cos(alfa) # souřadnice x bodu B
    By = A[2] + d * sin(alfa) # souřadnice y bodu B
    B = (Bx, By) # souřadnice bodu B jako tuple

    return B
end
