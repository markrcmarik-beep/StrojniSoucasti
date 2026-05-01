## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí body definující obrys profilu IPE podle normy ČSN 42 5553.
#
# ver: 2026-05-01
## Funkce: body_IPE_CSN425553()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/body_IPE_CSN425553.jl
#
## Vzor:
## body = body_IPE_CSN425553(prof, uchyceni, args...)
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

    b = prof.b # šířka profilu
    h = prof.h # výška profilu
    t1 = prof.t1 # tloušťka pásnice
    t2 = prof.t2 # tloušťka příruby
    R = prof.R # poloměr zaoblení
    if uchyceni == "ld" # levý dolní roh
        x = 0
        y = 0
    elseif uchyceni == "stred" # střed
        x = -b/2
        y = -h/2
    elseif uchyceni == "lu" # levý horní roh
        x = 0
        y = -h
    elseif uchyceni == "rd" # pravý dolní roh
        x = -b
        y = 0
    elseif uchyceni == "ru" # pravý horní roh
        x = -b
        y = -h
    else
        throw(ArgumentError("Neplatné uchycení: $uchyceni. Povolené hodnoty 
            jsou: \"ld\", \"stred\", \"lu\", \"rd\", \"ru\"."))
    end
    # vypočet obrysu
    A = (x, y) # levý spodní roh
    A1 = (A[1], A[2] + t2) # levý horní roh spodní pásnice
    A2 = (x + b/2 - t1/2, A[2] + t2) # střední horní roh vlevo spodní pásnice
    B = (x+b, y) # pravý spodní roh
    B1 = (B[1], B[2] + t2) # pravý horní roh spodní pásnice
    B2 = (x+b/2 + t1/2, B[2] + t2) # střední spodní roh vpravo svislé pásnice
    C = (x+b, y+h) # pravý horní roh
    C1 = (C[1], C[2] - t2) # pravý spodní roh horní pásnice
    C2 = (x+b/2 + t1/2, C[2] - t2) # střední horní roh vpravo svislé pásnice
    D = (x, y+h) # levý horní roh
    D1 = (D[1], D[2] - t2) # levý spodní roh horní pásnice
    D2 = (x+b/2 - t1/2, D[2] - t2) # střední horní roh vlevo svislé pásnice
    obrys = [A, B, B1,
        StrojniSoucasti.burub2body(B1, pi, R, pi/2, C2)..., 
        StrojniSoucasti.burub2body(B2, pi/2, R, 0, C1)...,
        C1, C, D, D1,
        StrojniSoucasti.burub2body(D1, 0, R, -pi/2, A2)...,
        StrojniSoucasti.burub2body(D2, -pi/2, R, pi, A1)...,
        A1,
    ]
    body = (obrys = obrys, otvory = ())
    return body
end
