## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypočítá úhel mezi dvěma úhly u1 a u2, přičemž se bere v úvahu 
# směr otáčení (proti směru hodinových ručiček).
# ver: 2026-04-26
## Funkce: uu2u()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/uu2u.jl
#
## Vzor:
## u = uu2u(u1, u2)
## Vstupní proměnné:
# u1 - první úhel [rad]
# u2 - druhý úhel [rad]
## Výstupní proměnné:
# u - úhel mezi u1 a u2 v rozsahu [0, 2*pi] [rad]
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#

function uu2u(u1::Real, u2::Real)

    return mod(u2 - u1, 2π)
end