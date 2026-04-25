## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypočítá úhel mezi dvěma úhly u1 a u2, přičemž se bere v úvahu 
# směr otáčení (proti směru hodinových ručiček).
# ver: 2026-04-25
## Funkce: uu2u()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/uu2u.jl
#
## Vzor:
## vystupni_promenne = uu2u(vstupni_promenne)
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

function uu2u(u1, u2)
    
    isa(u1, Number) || error("u1 musí být číslo.")
    isa(u2, Number) || error("u2 musí být číslo.")
    if u1 < 0 || u1 > 2*pi
        u1 = mod(u1, 2*pi) # převod úhlu na interval [0, 2*pi]
    end
    if u2 < 0 || u2 > 2*pi
        u2 = mod(u2, 2*pi) # převod úhlu na interval [0, 2*pi]
    end
    if u1 < u2
        u = (u2 - u1)
    elseif u1 > u2
        u = (2*pi - u1 + u2)
    else
        u = 0
    end
    return u

end
