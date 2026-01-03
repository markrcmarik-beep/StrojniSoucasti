## Funkce Julia
###############################################################
## Popis funkce:
# Funkce řeší sražené, zaoblené hrany strojních součástí. Vrací 
# plochu vnitřní nebo vnější dle tvaru stažení, zaoblení. Pro 
# zaoblení vrací délku stěny do špičky (k hraně vznikající bez 
# zaoblení). Pro sražení rovnostranné možné nahrazující zaoblení.
# ver: 2025-11-24
## Funkce: hrana()
#
## Vzor:
##  = hrana(
## Vstupní proměnné:
# rozmer - Textová hodnota rozměru. Např: "2x2", "3x45deg", "R5"
# uhel - Vstupní hodnota úhlu hrany. [rad] 
#   Např: pi/2, pi/3, pi/4, 90deg, 60deg, pi/2rad, ...
# smer - Směr měření plochy.
#   "in" Vnitřním plocha (uvnitř srážení, zaoblení)
#   "out" Vnější plocha 
## Výstupní proměnné:
# hodn - Hodnota plochy alternativních rozměrů 
#   :S - Hledaná plocha [mm2]
#   :o - Délka zaoblení (obvod části kruhu) [mm]
#   .a - Délka stěny k hraně před sražením, zaoblením pokud je 
#       zadáno zaoblení [mm]
#   .R - Alternativa zaoblení pokud je zadáno rovnoměrné srážení [mm]
## Použité balíčky
# Unitful, Unitful.DefaultSymbols
## Použité uživatelské funkce:
#
## Příklad:
# A1 = hrana("2x2", π/2, "out")
#
# A2 = hrana("2x45deg", π/2, "out")
#
# B = hrana("R5", π/2, "out")
#
###############################################################
## Použité proměnné vnitřní:
#
using Unitful, Unitful.DefaultSymbols

function hrana(rozmer::String, uhel::Real=π/2, smer::String="out")
    const π = pi # Pro zkrácení zápisu π místo pi v kódu
    # Inicializace výstupní struktury
    hodn = Dict{String, Any}()
    # Rozdělení rozměru na části
    if occursin("x", rozmer)
        casti = split(rozmer, "x") # Např. "2x45deg" => ["2", "45deg"]
        if length(casti) != 2
            error("Neplatný formát rozměru: $rozmer")
        end
        hodnota1 = parse(Float64, casti[1]) # První hodnota
        cast2 = casti[2] # Může být hodnota nebo úhel
    else
        error("Neplatný formát rozměru: $rozmer") # Očekává se formát "hodnota1xhodnota2"
    end
    if endswith(cast2, "deg")
        uhel_hrany = parse(Float64, replace(cast2, "deg" => "")) * (π / 180) # Převod na radiany
    elseif startswith(cast2, "R")
        hodnota2 = parse(Float64, replace(cast2, "R" => "")) # Poloměr zaoblení
        uhel_hrany = π / 2  # Pro zaoblení je úhel 90 stupňů
    else
        hodnota2 = parse(Float64, cast2) # Poloměr zaoblení
        uhel_hrany = cast2 # Předpokládáme, že je to úhel v radiantech
    end
    # Výpočet plochy a alternativních hodnot
    if smer == "in"
        if endswith(cast2, "deg")
            S = hodnota1^2 * tan(uhel / 2) # Vnitřní plocha
            hodn["S"] = S
        else
            a = hodnota1 / sin(uhel / 2) # Délka stěny k hraně
            hodn["a"] = a
        end
    elseif smer == "out"
        if endswith(cast2, "deg")
            S = hodnota1^2 * tan(uhel / 2) # Vnější plocha
            hodn["S"] = S
        else
            R = hodnota1 / (1 - cos(uhel / 2)) # Alternativa zaoblení
            hodn["R"] = R
        end
    else
        error("Neplatný směr: $smer. Použijte 'in' nebo 'out'.")
    end

    return hodn
end
