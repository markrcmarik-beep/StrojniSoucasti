## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce řeší sražené, zaoblené hrany strojních součástí. Vrací 
# plochu vnitřní nebo vnější dle tvaru stažení, zaoblení. Pro 
# zaoblení vrací délku stěny do špičky (k hraně vznikající bez 
# zaoblení). Pro sražení rovnostranné možné nahrazující zaoblení.
# ver: 2026-01-29
## Funkce: hrana()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/hrana.jl
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
# => Dict(:info=>"sražení", :rozmer=>"2x2", :x1=>2, :x2=>2, :S=>2.0, 
#   :o=>2.8284271247461903)
# A2 = hrana("2x45deg", π/2, "out")
#
# B = hrana("R5", π/2, "out")
# => Dict(:info=>"R", :rozmer=>"R5", :R=>5, :S=>7.853981633974483, 
#   :o=>7.853981633974483, :a=>5)
#
###############################################################
## Použité proměnné vnitřní:
#
#using Unitful, Unitful.DefaultSymbols

function hrana(inputStr::String, uhel::Real=pi/2, smer::String="out")

    # -----------------------------------------------------------
    # 1) Normalizace vstupu
    # -----------------------------------------------------------
    s = uppercase(strip(inputStr)) # velká písmena
    s = replace(s, r"\s+" => "")   # odstranění všech mezer
    # -----------------------------------------------------------
    # 2) Inicializace výstupu
    # -----------------------------------------------------------
    dims = Dict{Symbol,Any}()
    # -----------------------------------------------------------
    # 3) Pomocné funkce
    # -----------------------------------------------------------
    mmval(x) = parse(Int, x) * u"mm"
    # -----------------------------------------------------------
    # 4) Tabulka parserů (regex → handler)
    # -----------------------------------------------------------
    parsers = [
        # -------------------------------------------------------
        # PLO / OBD : a x b (+ R)
        # -------------------------------------------------------
        (r"^R(\d+(?:\.\d+)?)$",
    function (m)
        if uhel <= 0 || uhel >= pi
            error("Úhel hrany musí být v rozmezí (0, π) radianů.")
        end
        Rstr = m.captures[1]
        R = occursin('.', Rstr) ? parse(Float64, Rstr) : parse(Int, Rstr) # Pokud obsahuje desetinnou tečku, vrať Float64, jinak Int
        if uhel == pi/2
            S = R^2 - R^2 * (pi/4)  # Plocha
            S_str = "R^2 - R^2 * (π/4)"  # Plocha jako řetězec
            o = (pi/2) * R  # Délka oblouku čtvrtkruhu
            o_str = "(π/2) * R" # Délka oblouku jako řetězec
            a = R          # Délka stěny k hraně
            a_str = "R"    # Délka stěny jako řetězec
        else
            error("Zaoblení je podporováno pouze pro úhel 90° (π/2 rad)")
        end
        dims[:info] = "R"
        dims[:rozmer] = ("R$R")
        dims[:R] = R
        dims[:uhel] = uhel
        dims[:smer] = smer
        dims[:S] = S
        dims[:S_str] = S_str
        dims[:o] = o
        dims[:o_str] = o_str
        dims[:a] = a
        dims[:a_str] = a_str
    end
    ),
    (r"^(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)(DEG|°)?$",
    function (m)
        if uhel <= 0 || uhel >= pi
            error("Úhel hrany musí být v rozmezí (0, π) radianů.")
        end
        X1 = m.captures[1]
        X2 = m.captures[2]
        x1 = occursin('.', X1) ? parse(Float64, X1) : parse(Int, X1) # Pokud obsahuje desetinnou tečku, vrať Float64, jinak Int
        angle_str = m.captures[3] === nothing ? "" : m.captures[3]
        if angle_str == "DEG" || angle_str == "°"
            angledeg = occursin('.', X2) ? parse(Float64, X2) : parse(Int, X2) # Pokud obsahuje desetinnou tečku, vrať Float64, jinak Int
            angle = deg2rad(angledeg)
            if uhel == pi/2
                x2 = tan(angle) * x1
            else
                co = cos(uhel / 2)^2
                x2 = (tan(angle) * x1) / (2 * co)  # obecný trojúhelník
            end
        elseif angle_str == ""
            x2 = occursin('.', X2) ? parse(Float64, X2) : parse(Int, X2) # Pokud obsahuje desetinnou tečku, vrať Float64, jinak Int
            if uhel == pi/2
                angle = tan(x2 / x1)
            else
                angle = atan((2 * cos(uhel / 2)^2 * x2) / x1)  # obecný trojúhelník
            end
        else
            error("Neplatný formát úhlu v rozměru hrany.")
        end
        S = x1 * x2 / 2  # Plocha
        S_str = "x1 * x2 / 2"  # Plocha jako řetězec
        o = sqrt(x1^2 + x2^2 - 2 * x1 * x2 * cos(uhel))  # Délka oblouku čtvrtkruhu
        o_str = "sqrt(x1^2 + x2^2 - 2 * x1 * x2 * cos(uhel))" # Délka oblouku jako řetězec
        dims[:info] = "sražení"
        dims[:rozmer] = string(x1, "x", x2)
        dims[:x1] = x1
        dims[:x2] = x2
        dims[:uhel] = angle
        dims[:smer] = smer
        dims[:S] = S
        dims[:S_str] = S_str
        dims[:o] = o
        dims[:o_str] = o_str
    end
    )
    ]
    # -----------------------------------------------------------
    # 5) Vyhodnocení parserů
    # -----------------------------------------------------------
    for (regex, handler) in parsers
        m = match(regex, s)
        if m !== nothing
            handler(m)
            return dims
        end
    end
    # -----------------------------------------------------------
    # 6) Neznámý tvar
    # -----------------------------------------------------------
    error("Neznámé nebo nepodporované označení profilu: \"$inputStr\"")
end
