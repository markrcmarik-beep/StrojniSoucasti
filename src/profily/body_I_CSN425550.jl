## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí body definující obrys profilu I podle normy ČSN 42 5550.
#
# ver: 2026-05-01
## Funkce: body_I_CSN425550()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/body_I_CSN425550.jl
#
## Vzor:
## body = body_I_CSN425550(prof , uchyceni, args...)
## Vstupní proměnné:
# prof - struktura s rozměry profilu (b, h, t1, t2, R, R1, sp) 
#   získaná z funkce profil_I_CSN425550()
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

function body_I_CSN425550(prof, uchyceni::String="ld", args...)

    b = prof.b
    h = prof.h
    t1 = prof.t1
    t2 = prof.t2
    R = prof.R
    R1 = prof.R1
    sp = prof.sp
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
    A3 = (x + b*3/4, y + h - t2) # bod v pravo sphorní pásnice na výšce t2
    body1 = StrojniSoucasti.burub2body(A0, pi/2, R1, pi-uhel, A1) # body po oblouku mezi A1 a A0
    A1r = StrojniSoucasti.bux2b(A1, -uhel, b*1/4) # bod v pravém horním rohu zaoblení spodní pásnice
    A01, A02 = StrojniSoucasti.ubru2bb(-pi/2, A1r, R1, pi-uhel) # body v pravém horním zaoblení spodní pásnice
    A3r = StrojniSoucasti.bux2b(A1, pi-uhel, -(b*1/4-t1/2)) # bod v pravém spodním zaoblení střední pásnice
    A03, A04 = StrojniSoucasti.ubru2bb(-uhel, A3r, R, pi/2) # body v pravém spodním zaoblení střední pásnice
    B0 = (x + b, y + h) # bod v pravém horním rohu
    B1 = (x + b*3/4, y + h - t2) # bod v pravo horní pásnici na výšce h-t2
    B1r = StrojniSoucasti.bux2b(B1, pi+uhel, -(b*1/4-t1/2)) # bod v pravém horním zaoblení střední pásnice
    B01, B02 = StrojniSoucasti.ubru2bb(3*pi/2, B1r, R, uhel) # body v pravém horním zaoblení střední pásnice
    B3r = StrojniSoucasti.bux2b(B1, uhel, b*1/4) # bod v pravém spodním rohu zaoblení horní pásnice
    B03, B04 = StrojniSoucasti.ubru2bb(pi+uhel, B3r, R1, pi/2) # body v pravém spodním zaoblení horní pásnice
    C0 = (x, y + h) # bod levý horní roh
    C1 = (x + b/4, y + h - t2) # bod v levém horním rohu horní pásnice
    body5 = StrojniSoucasti.burub2body(C0, -pi/2, R1, -uhel, C1, 0.01) # body po oblouku mezi C1 a A1
    D0 = (x, y) # bod v levém spodním rohu
    D1 = (x + b/4, y + t2) # bod v levém spodním rohu spodní pásnice

    b_plus1 = StrojniSoucasti.brsb2body(
        A01, R1, "+", A02, 0.01)
    b2_plus1 = StrojniSoucasti.brsb2body(
        A03, R, "-", A04, 0.01)
    b_plus2 = StrojniSoucasti.brsb2body(
        B01, R, "-", B02, 0.01)
    b2_plus2 = StrojniSoucasti.brsb2body(
        B03, R1, "+", B04, 0.01)
    b_plus3 = StrojniSoucasti.brsb2body(
        (x + b/2 - t1/2 - R, y + h - t2), R, "-", 
        (x + b/2 - t1/2, y + h - t2 - R), 0.01)
    b_plus4 = StrojniSoucasti.brsb2body(
        (x + b/2 - t1/2, y + t2 + R), R, "-", 
        (x + b/2 - t1/2 - R, y + t2), 0.01)
    
    body1 = StrojniSoucasti.burub2body(A0, pi/2, R1, pi-uhel, A1, 0.01) # body po oblouku mezi D1 a D0
    
    obrys = [D0, A0,
        StrojniSoucasti.burub2body(A0, pi/2, R1, pi-uhel, A1, 0.01)..., # body po oblouku mezi D1 a D0
        A1, 
        StrojniSoucasti.burub2body(A1, pi-uhel, R, pi/2, A2, 0.01)..., 
        A2,
        StrojniSoucasti.burub2body(A2, pi/2, R, uhel, A3, 0.01)...,
        A3,
        b2_plus2...,
        B0, C0, body5..., C1,
        b_plus3..., b_plus4...,
        (x, y+t2)]
    body = (obrys = obrys, otvory = ())
    return body
end
