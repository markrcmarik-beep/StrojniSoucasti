## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce řeší textové označení tvaru dle ČSN a vrací
# strukturu s rozměry.
# ver: 2026-01-31
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
#   "PLO _a_x_b_" - "PLO 20x10" - obdélníkový profil
#   "PLO _a_x_b_R_r_" - "PLO 20x10R3" - obdélníkový profil s rádiusem
#   "OBD" - obdélníkový profil
#   "OBD _a_x_b_" - "OBD 20x10" - obdélníkový profil
#   "OBD _a_x_b_R_r_" - "OBD 20x10R3" - obdélníkový profil s rádiusem
#   "KR" - kruhový profil
#   "KR _D_" - "KR 20" - kruhový profil
#   "TRKR" - trubkový kruhový profil
#   "TRKR _D_x_t_" - "TRKR 20x2" - trubkový kruhový profil
#   "4HR" - čtyřhranný profil
#   "4HR _a_" - "4HR 20" - čtyřhranný profil
#   "4HR _a_R_r_" - "4HR 20R3" - čtyřhranný profil s rádiusem
#   "4HR _a_x_b_" - "4HR 20x10" - čtyřhranný profil obdélníkový
#   "4HR _a_x_b_R_r_" - "4HR 20x10R3" - čtyřhranný profil obdélníkový s rá
#   "6HR" - šestihranný profil
#   "6HR _s_" - "6HR 20" - šestihranný profil
#   "TR4HR" - trubkový čtyřhranný profil
#   "TR4HR _a_x_b_x_t_" - "TR4HR 20x20x2" - trubkový čtyřhranný profil
#   "TR4HR _a_x_b_x_t_R_r_" - "TR4HR 20x20x2R3" - trubkový čtyřhranný profil s rádiusem
#   args... - (nepoužito)
## Výstupní proměnné:
#
## Použité balíčky
# Unitful
## Použité uživatelské funkce:
# profilTR4HR
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
        #r = m.captures[4] === nothing ? 0 : parse(Float64, m.captures[4])
        r = m.captures[4] === nothing ? nothing : parse(Float64, m.captures[4])
        if r !== nothing
            @assert r ≤ min(a, b) / 2 "Rádius R = $r mm je příliš velký"
            dims[:R] = r * u"mm"
        end
        dims[:info] = m.captures[1]
        dims[:a]    = a * u"mm"
        dims[:b]    = b * u"mm"
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
            r"^4HR(\d+(?:\.\d+)?)(R(\d+(?:\.\d+)?))?$",
            function (m)
                a = parse(Float64, m.captures[1])
                #r = m.captures[3] === nothing ? 0 : parse(Float64, m.captures[3])
                #@assert r ≤ a/2 "Rádius R=$r mm je příliš velký"
                r = m.captures[3] === nothing ? nothing : parse(Float64, m.captures[3])
                if r !== nothing
                    @assert r ≤ a / 2 "Rádius R = $r mm je příliš velký"
                    dims[:R] = r * u"mm"
                end
                dims[:info] = "4HR"
                dims[:a] = a * u"mm"
                dims[:b] = a * u"mm"
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
                #r = m.captures[5] === nothing ? 0 : parse(Float64, m.captures[5])
                r = m.captures[5] === nothing ? nothing : parse(Float64, m.captures[5])
                if r !== nothing
                    @assert r ≤ min(a, b) / 2 "Rádius R = $r mm je příliš velký"
                end
                # Zkusit databázi standardních profilů
                A = profilTR4HR(s)
                if A !== nothing
                    dims[:info] = "TR4HR"
                    dims[:a] = A.a * u"mm"
                    dims[:b] = A.b * u"mm"
                    dims[:t] = A.t * u"mm"
                    if r !== nothing
                        dims[:R] = A.R * u"mm"
                    end
                else
                    @assert a > 2t && b > 2t "Tloušťka stěny je příliš velká"
                    
                    dims[:info] = "TR4HR"
                    dims[:a] = a * u"mm"
                    dims[:b] = b * u"mm"
                    dims[:t] = t * u"mm"
                    if r !== nothing
                        @assert r ≤ min(a,b)/2 "Rádius R=$r mm je příliš velký"
                        dims[:R] = r * u"mm"
                    end
                end
            end
        ),
        (
            r"^TR4HR(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)(R(\d+(?:\.\d+)?))?$",
            function (m)
                a = parse(Float64, m.captures[1])
                b = a
                t = parse(Float64, m.captures[2])
                #r = m.captures[4] === nothing ? 0 : parse(Float64, m.captures[4])
                r = m.captures[4] === nothing ? nothing : parse(Float64, m.captures[4])
                if r !== nothing
                    @assert r ≤ min(a, b) / 2 "Rádius R = $r mm je příliš velký"
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
                    @assert a > 2t && b > 2t "Tloušťka stěny je příliš velká"
                    @assert r ≤ min(a,b)/2 "Rádius R=$r mm je příliš velký"
                    dims[:info] = "TR4HR"
                    dims[:a] = a * u"mm"
                    dims[:b] = b * u"mm"
                    dims[:t] = t * u"mm"
                    if r !== nothing
                        dims[:R] = r * u"mm"
                    end
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
