## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-04-22
## Funkce: B = bux2b(A, alfa, x)
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/body/bux2b.jl
#
## Vzor:
## vystupni_promenne = bdu2b(vstupni_promenne)
## Vstupní proměnné:
# A - souřadnice bodu A (tuple nebo pole s dvěma prvky)
# alfa - úhel mezi přímkou AB a vodorovnou osou (osa x) [rad]
# x - vzdálenost mezi body A a B ve směru vodorovné osy (osa x) [mm]
## Výstupní proměnné:
# B - souřadnice bodu B (tuple s dvěma prvky)
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
# A = (10.0, 20.0) # souřadnice bodu A
# alfa = 30.0 # úhel mezi přímkou AB a vodorovnou osou (osa x) [rad]
# x = 5.0 # vzdálenost mezi body A a B ve směru vodorovné osy (osa x) [mm]
# B = bux2b(A, alfa, x)
###############################################################
## Použité proměnné vnitřní:
#

function bux2b(A, alfa, x)

    isa(A, Tuple) || error("A musí být tuple s dvěma prvky.")
    length(A) == 2 || error("A musí mít přesně dva prvky.")
    isa(alfa, Number) || error("alfa musí být číslo.")
    isa(x, Number) || error("x musí být číslo.")
    if alfa < 0 || alfa > 2*pi
        alfa = mod(alfa, 2*pi) # převod úhlu na interval [0, 2*pi]
    end
    if alfa == 90*pi/180 || alfa == 270*pi/180
        return nothing # nelze určit souřadnice bodu B, protože je přímo nad nebo pod bodem A
    end
    Bx = A[1] + x # souřadnice x bodu B
    By = A[2] + x * tan(alfa) # souřadnice y bodu B
    B = (Bx, By) # souřadnice bodu B jako tuple

    return B
end