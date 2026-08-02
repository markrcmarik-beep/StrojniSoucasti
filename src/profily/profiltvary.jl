# ver: 2026-07-16
## Funkce: profiltvary()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profiltvary.jl
#
## Použité balíčky
# Unitful
## Použité uživatelské funkce:
# profilTR4HR, profil_I_CSN425550, profil_IPE_CSN425553
###############################################################
## Použité proměnné vnitřní:
#
using Unitful
# načtení nápovědy z externího souboru
const _profiltvary_NAPOVEDA = read(
    joinpath(@__DIR__, "..", "..", "docs", "src", "profily", "profiltvary.md"),
    String,
) 
"""
$_profiltvary_NAPOVEDA
"""
function profiltvary(inputStr::AbstractString)
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
        # PLO / OBD : PLO{a}x{b} , PLO{a}x{b}R{r} , OBD{a}x{b} , OBD{a}x{b}R{r}
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
        # KR : KR{D}
        # -------------------------------------------------------
        (
            r"^KR(\d+(?:\.\d+)?)$",
            function (m)
                D = parse(Float64, m.captures[1])
                dims[:info] = "KR"
                dims[:D] = D * u"mm"
                #dims[:d] = 0 * u"mm" # d je nulové pro plný kruh
                return true
            end
        ),
        # -------------------------------------------------------
        # KR : KR{D}/{d}
        # -------------------------------------------------------
        (
            r"^KR(\d+(?:\.\d+)?)/(\d+(?:\.\d+)?)$",
            function (m)
                D = parse(Float64, m.captures[1])
                d = parse(Float64, m.captures[2])
                if D <= d
                    return false
                end
                dims[:info] = "KR"
                dims[:D] = D * u"mm"
                dims[:d] = d * u"mm"
                return true
            end
        ),
        # -------------------------------------------------------
        # TRKR : TRKR{D}x{t}
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
        # 4HR : 4HR{a} , 4HR{a}R{r} , 4HR{a}x{a} , 4HR{a}x{a}R{r} , 4HR{a}x{b} , 4HR{a}x{b}R{r}
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
        # 6HR : 6HR{s}
        # -------------------------------------------------------
        (
            r"^6HR(\d+(?:\.\d+)?)$",
            function (m)
                s = parse(Float64, m.captures[1])
                dims[:info] = "6HR"
                dims[:s] = s * u"mm" # Vzdálenost mezi protilehlými stranami šestihranu
                dims[:a] = s / sqrt(3) * u"mm" # Délka strany šestihranu
                dims[:e] = s / sqrt(3)*2 * u"mm" # Vzdálenost mezi protilehlými vrcholy šestihranu
                dims[:R] = 0u"mm"
                return true
            end
        ),
        # -------------------------------------------------------
        # I/IPE : I{n} , IPE{n}
        # -------------------------------------------------------
        (
            r"^(I|IPE)(\d+(?:\.\d+)?)$",
            function (m)
                serie = String(m.captures[1])
                A = serie == "IPE" ? profil_IPE_CSN425553(s) : profil_I_CSN425550(s)
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
        # TR4HR : TR4HR{a}x{t} , TR4HR{a}x{b}x{t} , TR4HR{a}x{b}x{t}R{r}
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
                A = profil_TR4HR_CSN425720(s)
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
                A = profil_TR4HR_CSN425720(s)
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
