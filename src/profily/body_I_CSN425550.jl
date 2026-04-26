## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-04-25
## Funkce: body_I_CSN425550()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/body_I_CSN425550.jl
#
## Vzor:
## vystupni_promenne = body_I_CSN425550(vstupni_promenne)
## Vstupní proměnné:
# prof - struktura s rozměry profilu (b, h, t1, t2, R, R1, sp) 
#   získaná z funkce profil_I_CSN425550()
# uchyceni - volitelný řetězec určující umístění profilu v 
#   souřadnicovém systému. Povolené hodnoty jsou: 
#       "ld" (levý dolní roh), 
#       "stred" (střed), 
#       "lu" (levý horní roh),
#       "rd" (pravý dolní roh),
#       "ru" (pravý horní roh).
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
    A1 = (x + b*3/4, y + t2) # bod v pravo spodní pásnice na výšce t2
    A1r = StrojniSoucasti.bux2b(A1, -uhel, b*1/4) # bod v pravém horním rohu zaoblení spodní pásnice
    A01, A02 = StrojniSoucasti.buur2bb(A1r, -pi/2, pi-uhel, R1) # body v pravém horním zaoblení spodní pásnice
    A3r = StrojniSoucasti.bux2b(A1, pi-uhel, -(b*1/4-t1/2)) # bod v pravém spodním zaoblení střední pásnice
    A03, A04 = StrojniSoucasti.buur2bb(A3r, -uhel, pi/2, R) # body v pravém spodním zaoblení střední pásnice
    B1 = (x + b*3/4, y + h - t2) # bod v pravo horní pásnici na výšce h-t2
    B1r = StrojniSoucasti.bux2b(B1, pi+uhel, -(b*1/4-t1/2)) # bod v pravém horním zaoblení střední pásnice
    B01, B02 = StrojniSoucasti.buur2bb(B1r, 3*pi/2, uhel, R) # body v pravém horním zaoblení střední pásnice
    B3r = StrojniSoucasti.bux2b(B1, uhel, b*1/4) # bod v pravém spodním rohu zaoblení horní pásnice
    B03, B04 = StrojniSoucasti.buur2bb(B3r, pi+uhel, pi/2, R1) # body v pravém spodním zaoblení horní pásnice

    b_plus1 = StrojniSoucasti.oblouk2body(
        A01, A02, R1, "+", 0.01)
    b2_plus1 = StrojniSoucasti.oblouk2body(
        A03, A04, R, "-", 0.01)
    b_plus2 = StrojniSoucasti.oblouk2body(
        B01, B02, R, "-", 0.01)
    b2_plus2 = StrojniSoucasti.oblouk2body(
        B03, B04, R1, "+", 0.01)
    b_plus3 = StrojniSoucasti.oblouk2body(
        (x + b/2 - t1/2 - R, y + h - t2), (x + b/2 - t1/2, y + h - t2 - R), 
        R, "-", 0.01)
    b_plus4 = StrojniSoucasti.oblouk2body(
        (x + b/2 - t1/2, y + t2 + R), (x + b/2 - t1/2 - R, y + t2), 
        R, "-", 0.01)
    
    
    
    
    obrys = [(x, y), (x+b, y),
        b_plus1..., A1, b2_plus1..., b_plus2..., B1, b2_plus2...,
        (x+b, y+h), (x, y+h), (x, y+h-t2), 
        b_plus3..., b_plus4...,
        (x, y+t2)]
    body = (obrys = obrys, otvory = ())
    return body
end
