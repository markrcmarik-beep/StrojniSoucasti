## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce řeší textové označení tvaru dle ČSN a vrací
# strukturu s rozměry.
# ver: 2026-04-09
## Funkce: profilyCSN()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyCSN.jl
#
## Vzor:
## vystupni_promenne = profilyCSN(vstupni_promenne)
## Vstupní proměnné:
# inputStr - Textové označení tvaru dle ČSN.
#  Podporované tvary:
#   "PLO" - obdélníkový profil
#       "PLO {a}x{b}" - "PLO 20x10" - obdélníkový profil
#       "PLO {a}x{b}R{r}" - "PLO 20x10R3" - obdélníkový profil s rádiusem
#   "OBD" - obdélníkový profil
#       "OBD {a}x{b}" - "OBD 20x10" - obdélníkový profil
#       "OBD {a}x{b}R{r}" - "OBD 20x10R3" - obdélníkový profil s rádiusem
#   "KR" - kruhový profil
#       "KR {D}" - "KR 20" - kruhový profil
#   "TRKR" - trubkový kruhový profil
#       "TRKR {D}x{t}" - "TRKR 20x2" - trubkový kruhový profil
#   "4HR" - čtyřhranný profil
#       "4HR {a}" - "4HR 20" - čtyřhranný profil
#       "4HR {a}R{r}" - "4HR 20R3" - čtyřhranný profil s rádiusem
#       "4HR {a}x{b}" - "4HR 20x10" - čtyřhranný profil obdélníkový
#       "4HR {a}x{b}R{r}" - "4HR 20x10R3" - čtyřhranný profil obdélníkový s rá
#   "6HR" - šestihranný profil
#       "6HR {s}" - "6HR 20" - šestihranný profil
#   "I" - I profil dle tabulky
#       "IPE {n}" - "IPE 100"
#       "IPN {n}" - "IPN 100"
#       "HEA {n}" - "HEA 100"
#       "HEB {n}" - "HEB 100"
#       "HEM {n}" - "HEM 100"
#   "TR4HR" - trubkový čtyřhranný profil
#       "TR4HR {a}x{b}x{t}" - "TR4HR 20x20x2" - trubkový čtyřhranný profil
#       "TR4HR {a}x{b}x{t}R{r}" - "TR4HR 20x20x2R3" - trubkový čtyřhranný profil s rádiusem
#   args... - (nepoužito)
## Výstupní proměnné:
#
## Použité balíčky
# Unitful
## Použité uživatelské funkce:
# profilTR4HR, profilI
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#

using Unitful

function profilyCSN(inputStr::AbstractString)
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
            r"^(PLO|OBD)(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)(?:R(\d+(?:\.\d+)?))?$",
            function (m)
                a = parse(Float64, m.captures[2])
                b = parse(Float64, m.captures[3])
                r = m.captures[4] === nothing ? nothing : parse(Float64, m.captures[4])
                if r !== nothing
                    if r > min(a, b) / 2
                        return false
                    end
                    dims[:R] = r * u"mm"
                else
                    dims[:R] = 0u"mm"
                end
                dims[:info] = m.captures[1]
                dims[:a] = a * u"mm"
                dims[:b] = b * u"mm"
                return true
            end
        ),
        # -------------------------------------------------------
        # KR : D
        # -------------------------------------------------------
        (
            r"^KR(\d+(?:\.\d+)?)$",
            function (m)
                D = parse(Float64, m.captures[1])
                dims[:info] = "KR"
                dims[:D] = D * u"mm"
                #dims[:D] = mmval(m.captures[1]) * u"mm"
                return true
            end
        ),
        # -------------------------------------------------------
        # TRKR : D x t
        # -------------------------------------------------------
        (
            r"^TRKR(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)$",
            function (m)
                D = parse(Float64, m.captures[1])
                t = parse(Float64, m.captures[2])
                if D <= 2t
                    return false
                end
                dims[:info] = "TRKR"
                dims[:D] = D * u"mm"
                dims[:t] = t * u"mm"
                dims[:d] = (D - 2t) * u"mm"
                return true
            end
        ),
        # -------------------------------------------------------
        # 4HR : a (+ R)
        # -------------------------------------------------------
        (
            r"^4HR(\d+(?:\.\d+)?)(R(\d+(?:\.\d+)?))?$",
            function (m)
                a = parse(Float64, m.captures[1])
                r = m.captures[3] === nothing ? nothing : parse(Float64, m.captures[3])
                if r !== nothing
                    if r > a / 2
                        return false
                    end
                    dims[:R] = r * u"mm"
                else
                    dims[:R] = 0u"mm"
                end
                dims[:info] = "4HR"
                dims[:a] = a * u"mm"
                dims[:b] = a * u"mm"
                return true
            end
        ),
        # -------------------------------------------------------
        # 6HR : s
        # -------------------------------------------------------
        (
            r"^6HR(\d+(?:\.\d+)?)$",
            function (m)
                s1 = parse(Float64, m.captures[1])
                dims[:info] = "6HR"
                dims[:s] = s1 * u"mm"
                dims[:a] = s1 * u"mm"
                dims[:R] = 0u"mm"
                return true
            end
        ),
        # -------------------------------------------------------
        # I : I/IPE/IPN/HEA/HEB/HEM
        # -------------------------------------------------------
        (
            r"^(I|IPE|IPN|HEA|HEB|HEM)(\d+(?:\.\d+)?)$",
            function (m)
                A = profilI(s)
                A === nothing && return false

                dims[:info] = "I"
                dims[:serie] = A.serie
                dims[:b] = A.b * u"mm"
                dims[:h] = A.h * u"mm"
                dims[:t1] = A.t1 * u"mm"
                dims[:t2] = A.t2 * u"mm"
                dims[:R] = A.R * u"mm"
                dims[:R1] = A.R1 * u"mm"
                dims[:standard] = A.standard
                dims[:material] = A.material
                return true
            end
        ),
        # -------------------------------------------------------
        # TR4HR : a x b x t (+ R)
        # -------------------------------------------------------
        (
            r"^TR4HR(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)(R(\d+(?:\.\d+)?))?$",
            function (m)
                a = parse(Float64, m.captures[1])
                b = parse(Float64, m.captures[2])
                t = parse(Float64, m.captures[3])
                r = m.captures[5] === nothing ? nothing : parse(Float64, m.captures[5])
                if r !== nothing
                    if r > min(a, b) / 2
                        return false
                    end
                end
                # Zkusit databázi standardních profilů
                A = profilTR4HR(s)
                if A !== nothing
                    dims[:info] = "TR4HR"
                    dims[:a] = A.a * u"mm"
                    dims[:b] = A.b * u"mm"
                    dims[:t] = A.t * u"mm"
                    dims[:R] = A.R * u"mm"
                else
                    if a <= 2t || b <= 2t
                        return false
                    end
                    
                    dims[:info] = "TR4HR"
                    dims[:a] = a * u"mm"
                    dims[:b] = b * u"mm"
                    dims[:t] = t * u"mm"
                    if r !== nothing
                        dims[:R] = r * u"mm"
                    else
                        dims[:R] = 0u"mm"
                    end
                end
                return true
            end
        ),
        (
            r"^TR4HR(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)(R(\d+(?:\.\d+)?))?$",
            function (m)
                a = parse(Float64, m.captures[1])
                b = a
                t = parse(Float64, m.captures[2])
                r = m.captures[4] === nothing ? nothing : parse(Float64, m.captures[4])
                if r !== nothing
                    if r > min(a, b) / 2
                        return false
                    end
                end
                # Zkusit databázi standardních profilů
                A = profilTR4HR(s)
                if A !== nothing
                    dims[:info] = "TR4HR"
                    dims[:a] = A.a * u"mm"
                    dims[:b] = A.b * u"mm"
                    dims[:t] = A.t * u"mm"
                    dims[:R] = A.R * u"mm"
                else
                    if a <= 2t || b <= 2t
                        return false
                    end
                    dims[:info] = "TR4HR"
                    dims[:a] = a * u"mm"
                    dims[:b] = b * u"mm"
                    dims[:t] = t * u"mm"
                    if r !== nothing
                        dims[:R] = r * u"mm"
                    else
                        dims[:R] = 0u"mm"
                    end
                end
                return true
            end
        )
    ]
    # -----------------------------------------------------------
    # 5) Vyhodnocení parserů
    # -----------------------------------------------------------
    for (regex, handler) in parsers
        m = match(regex, s)
        if m !== nothing
            ok = handler(m)
            return ok ? dims : nothing
        end
    end
    # -----------------------------------------------------------
    # 6) Neznámý tvar
    # -----------------------------------------------------------
    return nothing
end
