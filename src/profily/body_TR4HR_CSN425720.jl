## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí body definující obrys profilu TR4HR podle normy ČSN 42 5720.
#
# ver: 2026-05-01
## Funkce: body_TR4HR_CSN()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/body_TR4HR_CSN.jl
#
## Vzor:
## body = body_TR4HR_CSN(prof, uchyceni, args...)
## Vstupní proměnné:
# prof - struktura s rozměry profilu (b, h, t1, t2, R)
# uchyceni - volitelný řetězec určující umístění profilu v 
#   souřadnicovém systému. (nepovinné) Povolené hodnoty jsou: 
#       "ld" (levý dolní roh)
#       "stred" (střed)
#       "lu" (levý horní roh) (výchozí hodnota)
#       "rd" (pravý dolní roh)
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

function body_TR4HR_CSN(prof, uchyceni::String="ld", args...)

    a = prof.a
    b = prof.b
    t = prof.t
    R = prof.R
    if uchyceni == "ld" # levý dolní roh
        x = 0
        y = 0
    elseif uchyceni == "stred" # střed
        x = -a/2
        y = -b/2
    elseif uchyceni == "lu" # levý horní roh
        x = 0
        y = -b
    elseif uchyceni == "rd" # pravý dolní roh
        x = -a
        y = 0
    elseif uchyceni == "ru" # pravý horní roh
        x = -a
        y = -b
    else
        throw(ArgumentError("Neplatné uchycení: $uchyceni. Povolené hodnoty 
            jsou: \"ld\", \"stred\", \"lu\", \"rd\", \"ru\"."))
    end
    # vypočet obrysu
    # (x, y) levý spodní roh
    A = (x, y) # levý spodní roh
    B = (x+a, y) # pravý spodní roh
    C = (x+a, y+b) # pravý horní roh
    D = (x, y+b) # levý horní roh
    obrys = [
        StrojniSoucasti.burub2body(A, 0, R, pi/2, B)..., 
        StrojniSoucasti.burub2body(B, pi/2, R, pi, C)...,
        StrojniSoucasti.burub2body(C, pi, R, 3*pi/2, D)..., 
        StrojniSoucasti.burub2body(D, 3*pi/2, R, 0, A)...,
        ]
    # vypočet otvoru
    Ro = R - t
    if Ro < 0
        Ro = 0
    end
    A1 = (A[1] + t, A[2] + t) # levý spodní roh otvoru
    B1 = (B[1] - t, B[2] + t) # pravý spodní roh otvoru
    C1 = (C[1] - t, C[2] - t) # pravý horní roh otvoru
    D1 = (D[1] + t, D[2] - t) # levý horní roh otvoru
    otvor = [
        StrojniSoucasti.burub2body(A1, 0, Ro, pi/2, B1)..., 
        StrojniSoucasti.burub2body(B1, pi/2, Ro, pi, C1)...,
        StrojniSoucasti.burub2body(C1, pi, Ro, 3*pi/2, D1)..., 
        StrojniSoucasti.burub2body(D1, 3*pi/2, Ro, 0, A1)...,
    ]
    body = (obrys = obrys, otvory = [otvor])
    return body
end
