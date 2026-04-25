## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-04-25
## Funkce: body_TR4HR_CSN()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/body_TR4HR_CSN.jl
#
## Vzor:
## vystupni_promenne = body_TR4HR_CSN(vstupni_promenne)
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

function body_TR4HR_CSN(prof, uchyceni::String="ld", args...)

    a = prof.a
    b = prof.b
    t = prof.t
    R = prof.R
    if uchyceni == "ld"
        x = 0
        y = 0
    elseif uchyceni == "stred"
        x = -a/2
        y = -b/2
    elseif uchyceni == "lu"
        x = 0
        y = -b
    elseif uchyceni == "rd"
        x = -a
        y = 0
    elseif uchyceni == "ru"
        x = -a
        y = -b
    else
        throw(ArgumentError("Neplatné uchycení: $uchyceni. Povolené hodnoty 
            jsou: \"ld\", \"stred\", \"lu\", \"rd\", \"ru\"."))
    end
    # vypočet obrysu
    # (x, y) levý spodní roh
    b_plus1 = StrojniSoucasti.oblouk2body(
        (x, y + R), (x + R, y), 
        R, "+", 0.01)
    b_plus2 = StrojniSoucasti.oblouk2body(
        (x + a - R, y), (x + a, y + R), 
        R, "+", 0.01)
    b_plus3 = StrojniSoucasti.oblouk2body(
        (x + a, y + b - R), (x + a - R, y + b), 
        R, "+", 0.01)
    b_plus4 = StrojniSoucasti.oblouk2body(
        (x + R, y + b), (x, y + b - R), 
        R, "+", 0.01)
    obrys = [
        b_plus1..., b_plus2..., 
        b_plus3..., b_plus4...,
        ]
    # vypočet otvoru
    Ro = R - t
    if Ro < 0
        Ro = 0
    end
    b2_plus1 = StrojniSoucasti.oblouk2body(
        (x + t, y + t + Ro), (x + t + Ro, y + t), 
        Ro, "+", 0.01)
    b2_plus2 = StrojniSoucasti.oblouk2body(
        (x + a - t - Ro, y + t), (x + a - t, y + t + Ro), 
        Ro, "+", 0.01)
    b2_plus3 = StrojniSoucasti.oblouk2body(
        (x + a - t, y + b - t - Ro), (x + a - t - Ro, y + b - t), 
        Ro, "+", 0.01)
    b2_plus4 = StrojniSoucasti.oblouk2body(
        (x + t + Ro, y + b - t), (x + t, y + b - t - Ro), 
        Ro, "+", 0.01)
    otvor = [
        b2_plus1..., b2_plus2...,
        b2_plus3..., b2_plus4...,
    ]
    body = (obrys = obrys, otvory = [otvor])
    return body
end
