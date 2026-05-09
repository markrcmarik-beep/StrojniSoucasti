## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí body definující obrys profilu hřídele s drážkou pro pero.
# Volitelně lze zadat umístění profilu v souřadnicovém systému.
#
# ver: 2026-05-08
## Funkce: body_drazka4pero()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/body_drazka4pero.jl
#
## Vzor:
## body = body_drazka4pero(prof , uchyceni, args...)
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
    obrys = ()
    otvory = ()
    if !(uchyceni in ["teziste", "stred"])
        throw(ArgumentError("Neplatné uchycení: $uchyceni. Povolené hodnoty 
            jsou: \"teziste\", \"stred\"."))
    end
    D = prof.D
    if haskey(prof, :d)
        d = prof.d
    end
    if haskey(prof, :natoceni)
        natoceni = prof.natoceni
    else
        natoceni = pi/2
    end
    if haskey(prof, :n)
         n = prof.n
    else
        n = 1
    end
    t = prof.t
    b = prof.b
    R1 = prof.R1
    x0 = 0
    y0 = 0
    S = (x0, y0) # střed profilu
    A = (x0, y0-D/2) # bod spodního kvadrantu na obvodě
    B = (x0+D/2, y0) # bod pravého kvadrantu na obvodě
    C = (x0, y0+D/2) # bod horního kvadrantu na obvodě
    E = (x0-D/2, y0) # bod levého kvadrantu na obvodě
    xr1 = x0 + b/2 # souřadnice x pro body srážky
    yr1 = y0 + sqrt((D/2)^2 - (b/2)^2) # souřadnice y pro body srážky  
    xl1 = x0 - b/2 # souřadnice x pro body srážky
    yl1 = y0 + sqrt((D/2)^2 - (b/2)^2) # souřadnice y pro body srážky
    Cr1 = (xr1, yr1) # pravý horní bod
    Cr2 = (xr1, yr1 - t) # pravý dolní bod
    Cl1 = (xl1, yl1) # levý horní bod
    Cl2 = (xl1, yl1 - t) # levý dolní bod
    Clr = [Cr1, Cr2, Cl1, Cl2] # body pro pravou srážku
    if n==1
        obrys = [
            StrojniSoucasti.brsb2body(A, D/2, "+", B, 0.01)..., # body pro oblouk pravý spodní kvadrant s poloměrem D/2
            StrojniSoucasti.brsb2body(B, D/2, "+", Cr1, 0.01)..., # body pro oblouk pravý horní kvadrant s poloměrem D/2
            Cr2, # přímka pravé srážky
            Cl2, # přímka spodní srážky
            StrojniSoucasti.brsb2body(Cl1, D/2, "+", E, 0.01)..., 
            StrojniSoucasti.brsb2body(E, D/2, "+", A, 0.01)...
            ]
    elseif n==2
        Alr = StrojniSoucasti.rotuj_body(Clr, pi, S=S) # body pro pravou srážku pootočené o 180°
        obrys = [
            StrojniSoucasti.brsb2body(Alr[3], D/2, "+", B, 0.01)..., 
            StrojniSoucasti.brsb2body(B, D/2, "+", Cr1, 0.01)..., 
            Cr2, # přímka pravé srážky
            Cl2, # přímka spodní srážky
            StrojniSoucasti.brsb2body(Cl1, D/2, "+", E, 0.01)..., 
            StrojniSoucasti.brsb2body(E, D/2, "+", Alr[1], 0.01)...,
            Alr[2], # přímka levé srážky
            Alr[4] # přímka levé srážky
        ]
    elseif n==3
        EAlr = StrojniSoucasti.rotuj_body([Cr1, Cr2, Cl1, Cl2], 2*pi/3, 
            S=S) # body pro pravou srážku pootočené o 120°
        ABlr = StrojniSoucasti.rotuj_body([Cr1, Cr2, Cl1, Cl2], 4*pi/3, 
            S=S) # body pro pravou srážku pootočené o 240°
        obrys = [
            StrojniSoucasti.brsb2body(ABlr[3], D/2, "+", B, 0.01)..., 
            StrojniSoucasti.brsb2body(B, D/2, "+", Cr1, 0.01)..., 
            Cr2, # přímka pravé srážky
            Cl2, # přímka spodní srážky
            StrojniSoucasti.brsb2body(Cl1, D/2, "+", E, 0.01)..., 
            StrojniSoucasti.brsb2body(E, D/2, "+", EAlr[1], 0.01)...,
            EAlr[2], # přímka levé srážky
            EAlr[4], # přímka levé srážky
            StrojniSoucasti.brsb2body(EAlr[3], D/2, "+", A, 0.01)...,
            StrojniSoucasti.brsb2body(A, D/2, "+", ABlr[1], 0.01)...,
            ABlr[2],
            ABlr[4]
        ]
    else
        obrys = ()
    end
    if natoceni != pi/2
        obrys = StrojniSoucasti.rotuj_body(obrys, natoceni-pi/2, S=S)
    end
    if uchyceni == "teziste"
        if n==1
            x_teziste = x0
            y_teziste = y0
            obrys = StrojniSoucasti.posun_body(obrys, (x_teziste, y_teziste))
        end
        # pro uchycení v těžišti je třeba posouvat body
    end
    body = (obrys = obrys, otvory = otvory)
    return body
end
