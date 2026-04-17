## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-04-17
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

    # (x, y) levý spodní roh
    b_plus1 = StrojniSoucasti.obloukBodu(
        (x, y + R), (x + R, y), 
        R, "-", 0.01)
    b_plus2 = StrojniSoucasti.obloukBodu(
        (x + a - R, y), (x + a, y + R), 
        R, "-", 0.01)
    b_plus3 = StrojniSoucasti.obloukBodu(
        (x + a, y + b - R), (x + a - R, y + b), 
        R, "-", 0.01)
    b_plus4 = StrojniSoucasti.obloukBodu(
        (x + R, y + b), (x, y + b - R), 
        R, "-", 0.01)
    body = [
        b_plus1..., b_plus2..., 
        b_plus3..., b_plus4...,
        ]
    b2_plus1 = StrojniSoucasti.obloukBodu(
        (x + t, y + t + R), (x + t + R, y + t), 
        R, "-", 0.01)
    b2_plus2 = StrojniSoucasti.obloukBodu(
        (x + a - t - R, y + t), (x + a - t, y + t + R), 
        R, "-", 0.01)
    b2_plus3 = StrojniSoucasti.obloukBodu(
        (x + a - t, y + b - t - R), (x + a - t - R, y + b - t), 
        R, "-", 0.01)
    b2_plus4 = StrojniSoucasti.obloukBodu(
        (x + t + R, y + b - t), (x + t, y + b - t - R), 
        R, "-", 0.01)
    body2 = [
        b2_plus1..., b2_plus2...,
        b2_plus3..., b2_plus4...,
    ]
    return body
end
