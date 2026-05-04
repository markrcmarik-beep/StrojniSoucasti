## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí body definující obrys profilu hřídele s srážkou pro pero
# Volitelně lze zadat umístění profilu v souřadnicovém systému.
#
# ver: 2026-05-04
## Funkce: body_I_CSN425550()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/body_I_CSN425550.jl
#
## Vzor:
## body = body_I_CSN425550(prof , uchyceni, args...)
## Vstupní proměnné:
# prof - struktura s rozměry profilu (D, d, t, b, R1) 
#   získaná z funkce drazka4pero()
# uchyceni - volitelný řetězec určující umístění profilu v 
#   souřadnicovém systému. (nepovinné) Povolené hodnoty jsou: 
#       "teziste" (těžiště) 
#       "stred" (střed) (výchozí hodnota)
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

function body_drazka4pero(prof, uchyceni::String="stred", args...)

    D = prof.D
    if haskey(prof, d)
        d = prof.d
    end
    if haskey(prof, n)
         n = prof.n
    else
        n = 1
    end
    t = prof.t
    b = prof.b
    R1 = prof.R1
    if uchyceni == "teziste"
        x0 = 0
        y0 = 0
    elseif uchyceni == "stred"
        x0 = 0
        y0 = 0
    else
        throw(ArgumentError("Neplatné uchycení: $uchyceni. Povolené hodnoty 
            jsou: \"teziste\", \"stred\"."))
    end
    # (x-x0)^2 + (y-y0)^2 == (D/2)^2 # rovnice kružnice pro obvod profilu
    # y - y0 == sqrt((D/2)^2 - (x-x0)^2) # horní polovina kružnice
    S = (x0, y0) # střed profilu
    A = (x0, y0-D/2) # bod spodního kvadrantu na obvodě
    B = (x0+D/2, y0) # bod pravého kvadrantu na obvodě
    C = (x0, y0+D/2) # bod horního kvadrantu na obvodě
    D = (x0-D/2, y0) # bod levého kvadrantu na obvodě
    if n==1
        xr1 = x0 + b/2 # souřadnice x pro body srážky
        yr1 = y0 - sqrt((D/2)^2 - (b/2)^2) # souřadnice y pro body srážky
        Cr1 = (xr1, yr1) # pravý horní bod
        Cr2 = (xr1, yr1 - t) # pravý dolní bod
        xl1 = x0 - b/2 # souřadnice x pro body srážky
        yl1 = y0 - sqrt((D/2)^2 - (b/2)^2) # souřadnice y pro body srážky
        Cl1 = (xl1, yl1) # levý horní bod
        Cl2 = (xl1, yl1 - t) # levý dolní bod
        b_plus1 = StrojniSoucasti.brsb2body(
            A, D/2, "+", B, 0.01)
        b_plus2 = StrojniSoucasti.brsb2body(
            B, D/2, "+", Cr1, 0.01)
        b_plus3 = StrojniSoucasti.burub2body(
            Cr1, 3*pi/2, R1, pi, Cl2, 0.01)
        b_plus4 = StrojniSoucasti.burub2body(
            Cr2, pi, R1, pi/2, Cl1, 0.01)
        b_plus5 = StrojniSoucasti.brsb2body(
            Cl1, D/2, "+", D, 0.01)
        b_plus6 = StrojniSoucasti.brsb2body(
            D, D/2, "+", A, 0.01)

        obrys = [b_plus1..., b_plus2..., 
            b_plus3..., b_plus4..., 
            b_plus5..., b_plus6...]
        body = (obrys = obrys, otvory = ())
    else
        body = (obrys = (), otvory = ())
    end
    return body
end
