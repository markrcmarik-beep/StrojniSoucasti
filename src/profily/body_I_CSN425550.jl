## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí body definující obrys profilu I podle normy ČSN 42 5550.
#
# ver: 2026-05-16
## Funkce: body_I_CSN425550()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/body_I_CSN425550.jl
#
## Vzor:
## body = body_I_CSN425550(prof , uchyceni, args...)
## Vstupní proměnné:
# 1) prof - struktura s rozměry profilu (b, h, t1, t2, R, R1, sp) 
#           získaná z funkce profil_I_CSN425550()
# 2) prof - text označení profilu např.: "I80"
# uchyceni - volitelný řetězec určující umístění profilu v 
#   souřadnicovém systému. (nepovinné) Povolené hodnoty jsou: 
#       "ld" (levý dolní roh) 
#       "stred" (střed)
#       "lu" (levý horní roh)
#       "rd" (pravý dolní roh) (výchozí hodnota)
#       "ru" (pravý horní roh)
# args... - další volitelné argumenty (zatím nevyužité)
## Výstupní proměnné:
# body - pole (vektor) obsahující souřadnice bodů definujících 
#   obrys profilu.
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
function body_I_CSN425550(prof::String, uchyceni::String="ld", args...)
    prof1 = StrojniSoucasti.profil_I_CSN425550(prof)
    body = body_I_CSN425550(prof1, uchyceni)
    return body
end

function body_I_CSN425550(prof::I_CSN425550, uchyceni::String="ld", args...)

    b = prof.b # šířka profilu
    h = prof.h # výška profilu
    t1 = prof.t1 # tloušťka pásnice
    t2 = prof.t2 # tloušťka příruby
    R = prof.R # poloměr zaoblení
    R1 = prof.R1 # poloměr zaoblení
    sp = prof.sp # úhel stoupání pásnice
    if uchyceni == "ld"
        x = 0
        y = 0
    elseif uchyceni == "stred"
        x = -b/2
        y = -h/2
    elseif uchyceni == "lu"
        x = 0
        y = -h
    elseif uchyceni == "rd"
        x = -b
        y = 0
    elseif uchyceni == "ru"
        x = -b
        y = -h
    else
        throw(ArgumentError("Neplatné uchycení: $uchyceni. Povolené hodnoty 
            jsou: \"ld\", \"stred\", \"lu\", \"rd\", \"ru\"."))
    end

    # (x, y) levý spodní roh
    uhel = atan(sp/100) # převod sklonu z procent na úhel v radiánech
    A0 = (x + b, y) # bod v pravém spodním rohu
    A1 = (x + b*3/4, y + t2) # bod v pravo spodní pásnice na výšce t2
    A2 = (x + b/2 + t1/2, y + h/2) # bod pravém střední pásnice uprostřed výšky
    A3 = (x + b*3/4, y + h - t2) # bod v pravo horní pásnice na výšce t2
    B0 = (x + b, y + h) # bod v pravém horním rohu
    C0 = (x, y + h) # bod levý horní roh
    C1 = (x + b/4, y + h - t2) # bod v levém horní pásnice na výšce t2
    C2 = (x + b/2 - t1/2, y + h/2) # bod v levém střední pásnice uprostřed výšky
    D0 = (x, y) # bod v levém spodním rohu
    D1 = (x + b/4, y + t2) # bod v levém spodním rohu spodní pásnice
    obrys = [D0, A0,
        StrojniSoucasti.burub2body(A0, pi/2, R1, pi-uhel, A1, 0.01)..., # body po oblouku mezi D1 a D0
        A1, # body v pravém horním rohu zaoblení spodní pásnice
        StrojniSoucasti.burub2body(A1, pi-uhel, R, pi/2, A2, 0.01)..., 
        A2, # body v pravém spodním zaoblení střední pásnice
        StrojniSoucasti.burub2body(A2, pi/2, R, uhel, A3, 0.01)...,
        A3, # body v pravém spodním zaoblení horní pásnice
        StrojniSoucasti.burub2body(A3, uhel, R1, pi/2, B0, 0.01)...,
        B0, C0,
        StrojniSoucasti.burub2body(C0, -pi/2, R1, -uhel, C1, 0.01)...,
        C1,
        StrojniSoucasti.burub2body(C1, -uhel, R, -pi/2, C2, 0.01)...,
        C2,
        StrojniSoucasti.burub2body(C2, -pi/2, R, uhel, D1, 0.01)...,
        D1,
        StrojniSoucasti.burub2body(D1, pi+uhel, R1, -pi/2, D0, 0.01)...,
        D0]
    body = (obrys = obrys, otvory = ())
    return body
end
