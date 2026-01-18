## Funkce Julia
###############################################################
## Popis funkce:
#
# ver: 2025-12-30
## Funkce: nazev_funkce()
#
## Vzor:
## vystupni_promenne = nazev_funkce(vstupni_promenne)
## Vstupní proměnné:
#
## Výstupní proměnné:
#
## Použité balíčky
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#

using Unitful

"""
    tvarCSN(inputStr::AbstractString) -> Dict{Symbol,Any}

Rozpozná označení profilu dle ČSN (s mezerami i bez mezer)
a vrátí slovník s rozměry profilu.

Podporované příklady:
- "OBD20x15R3"
- "TR4HR 20x20x2"
- "KR30"
- "4HR25R2"
"""
function tvarCSN(inputStr::AbstractString)
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
        (
            r"^(PLO|OBD)(\d+)X(\d+)(R(\d+))?$",
            function (m)
                a = parse(Int, m.captures[2])
                b = parse(Int, m.captures[3])
                r = m.captures[5] === nothing ? 0 : parse(Int, m.captures[5])
                @assert r ≤ min(a,b)/2 "Rádius R=$r mm je příliš velký"
                dims[:info] = m.captures[1]
                dims[:a] = a * u"mm"
                dims[:b] = b * u"mm"
                dims[:R] = r * u"mm"
            end
        ),
        # -------------------------------------------------------
        # KR : D
        # -------------------------------------------------------
        (
            r"^KR(\d+)$",
            function (m)
                D = parse(Int, m.captures[1])
                dims[:info] = "KR"
                dims[:D] = D * u"mm"
                #dims[:D] = mmval(m.captures[1]) * u"mm"
            end
        ),
        # -------------------------------------------------------
        # TRKR : D x t
        # -------------------------------------------------------
        (
            r"^TRKR(\d+)X(\d+)$",
            function (m)
                D = parse(Int, m.captures[1])
                t = parse(Int, m.captures[2])
                @assert D > 2t "Neplatná trubka: D ≤ 2t"
                dims[:info] = "TRKR"
                dims[:D] = D * u"mm"
                dims[:t] = t * u"mm"
                dims[:d] = (D - 2t) * u"mm"
            end
        ),
        # -------------------------------------------------------
        # 4HR : a (+ R)
        # -------------------------------------------------------
        (
            r"^4HR(\d+)(R(\d+))?$",
            function (m)
                a = parse(Int, m.captures[1])
                r = m.captures[3] === nothing ? 0 : parse(Int, m.captures[3])
                @assert r ≤ a/2 "Rádius R=$r mm je příliš velký"
                dims[:info] = "4HR"
                dims[:a] = a * u"mm"
                dims[:b] = a * u"mm"
                dims[:R] = r * u"mm"
            end
        ),
        # -------------------------------------------------------
        # 6HR : s
        # -------------------------------------------------------
        (
            r"^6HR(\d+)$",
            function (m)
                s1 = parse(Int, m.captures[1])

                dims[:info] = "6HR"
                dims[:s] = s1 * u"mm"
                dims[:a] = s1 * u"mm"
                dims[:R] = 0 * u"mm"
            end
        ),
        # -------------------------------------------------------
        # TR4HR : a x b x t (+ R)
        # -------------------------------------------------------
        (
            r"^TR4HR(\d+)X(\d+)X(\d+)(R(\d+))?$",
            function (m)
                a = parse(Int, m.captures[1])
                b = parse(Int, m.captures[2])
                t = parse(Int, m.captures[3])
                r = m.captures[5] === nothing ? 0 : parse(Int, m.captures[5])
                # Zkusit databázi standardních profilů
                A = profilTR4HR(s)
                if A !== nothing
                    dims[:info] = "TR4HR"
                    dims[:a] = A.a * u"mm"
                    dims[:b] = A.b * u"mm"
                    dims[:t] = A.t * u"mm"
                    dims[:R] = A.R * u"mm"
                else
                    @assert a > 2t && b > 2t "Tloušťka stěny je příliš velká"
                    @assert r ≤ min(a,b)/2 "Rádius R=$r mm je příliš velký"
                    dims[:info] = "TR4HR"
                    dims[:a] = a * u"mm"
                    dims[:b] = b * u"mm"
                    dims[:t] = t * u"mm"
                    dims[:R] = r * u"mm"
                end
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
