## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce řeší sražené, zaoblené hrany strojních součástí. Vrací 
# plochu vnitřní nebo vnější dle tvaru stažení, zaoblení. Pro 
# zaoblení vrací délku stěny do špičky (k hraně vznikající bez 
# zaoblení). Pro sražení rovnostranné možné nahrazující zaoblení.
# ver: 2025-11-24
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
#
# A2 = hrana("2x45deg", π/2, "out")
#
# B = hrana("R5", π/2, "out")
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
        R = parse(Float64, m.captures[1])
        if uhel <= 0 || uhel >= pi
            error("Úhel hrany musí být v rozmezí (0, π) radianů.")
        end
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
        dims[:rozmer] = string("R", R)
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
    (r"^KR(\d+(?:\.\d+)?)$",
    function (m)
        a = parse(Float64, m.captures[2])
        b = parse(Float64, m.captures[3])
        r = m.captures[4] === nothing ? 0.0 : parse(Float64, m.captures[4])

        @assert r ≤ min(a, b) / 2 "Rádius R = $r mm je příliš velký"

        dims[:info] = m.captures[1]
        dims[:a]    = a
        dims[:b]    = b
        dims[:R]    = r
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
