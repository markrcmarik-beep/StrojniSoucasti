## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-04-19
## Funkce: body_IPE_CSN425553()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/body_IPE_CSN425553.jl
#
## Vzor:
## vystupni_promenne = body_IPE_CSN425553(vstupni_promenne)
## Vstupní proměnné:
# prof - struktura s rozměry profilu (b, h, t1, t2, R)
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

function body_IPE_CSN425553(prof, uchyceni::String="ld", args...)

    b = prof.b
    h = prof.h
    t1 = prof.t1
    t2 = prof.t2
    R = prof.R
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

    #b = 100
    #h = 200
    #t1 = 5.6
    #t2 = 8.5
    #R = 12
    # (x, y) levý spodní roh
    b_plus1 = StrojniSoucasti.obloukBodu(
        (x + b/2 + t1/2 + R, y + t2), (x + b/2 + t1/2, y + t2 + R), 
        R, "-", 0.01)
    b_plus2 = StrojniSoucasti.obloukBodu(
        (x + b/2 + t1/2, y + h - t2 - R), (x + b/2 + t1/2 + R, y + h - t2), 
        R, "-", 0.01)
    b_plus3 = StrojniSoucasti.obloukBodu(
        (x + b/2 - t1/2 - R, y + h - t2), (x + b/2 - t1/2, y + h - t2 - R), 
        R, "-", 0.01)
    b_plus4 = StrojniSoucasti.obloukBodu(
        (x + b/2 - t1/2, y + t2 + R), (x + b/2 - t1/2 - R, y + t2), 
        R, "-", 0.01)
    obrys = [(x, y), (x+b, y), (x+b, y+t2), 
        b_plus1..., b_plus2..., 
        (x+b, y+h-t2), (x+b, y+h), (x, y+h), (x, y+h-t2), 
        b_plus3..., b_plus4...,
        (x, y+t2)]
    body = (obrys = obrys, otvory = ())
    return body
end
