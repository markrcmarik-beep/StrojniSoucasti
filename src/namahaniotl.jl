## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Kontrola namáhání na otlačení (plošný tlak).
# ver: 2026-01-22
## Funkce: namahaniotl()
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahaniotl.jl
#
## Vzor:
## VV, txt = namahaniotl(F=5000N, S_otl=120mm^2, mat="11373")
## VV = namahaniotl(F=5000N, profil="PLECH 10x30", mat="11373", return_text=false)
## Vstupní proměnné:
# F - zatěžující síla (Unitful.Quantity nebo Number v N)
# S_otl - kontaktní plocha (Unitful.Quantity nebo Number v mm²)
# sigmaDotl - dovolené napětí na otlačení (Unitful.Quantity nebo Number v MPa)
# Re - meze kluzu materiálu (Unitful.Quantity nebo Number v MPa)
# mat - materiál (řetězec nebo číslo dle materialy())
# zatizeni - typ zatížení ("statický" nebo "dynamický", výchozí "statický")
# profil - tvar profilu nebo kontaktu (řetězec dle profily()), alternativně k S_otl
# return_text - zda vrátit i textový výstup (Bool, výchozí true)
## Výstupní proměnné:
# VV - slovník (Dict) s výsledky výpočtu
#   :info - popis výpočtu (řetězec)
#   :zatizeni - typ zatížení (řetězec)
#   :F - zatěžující síla (Unitful.Quantity)
#   :F_info - popis veličiny F (řetězec)
#   :S_otl - kontaktní plocha (Unitful.Quantity)
#   :S_otl_str - textový popis plochy S_otl (řetězec)
#   :S_otl_info - popis veličiny S_otl (řetězec)
#   :sigmaDotl - dovolené napětí na otlačení (Unitful.Quantity)
#   :sigmaDotl_info - popis veličiny sigmaDotl (řetězec)
#   :sigma - skutečné napětí na otlačení (Unitful.Quantity)
#   :sigma_info - popis veličiny sigma (řetězec)
#   :bezpecnost - součinitel bezpečnosti (Number)
#   :bezpecnost_info - popis veličiny bezpecnost (řetězec)
#   :verdict - výsledek posouzení (řetězec)
#   :verdict_info - popis veličiny verdict (řetězec)
#   :mat - materiál (řetězec nebo číslo)
#   :mat_info - popis veličiny mat (řetězec)
#   :profil - tvar / kontakt (řetězec)
#   :profil_info - popis veličiny profil (řetězec)
# txt - textový výstup (řetězec), pokud return_text=true
## Použité balíčky:
# Unitful, Printf
## Použité uživatelské funkce:
# materialy(), dovoleneNapeti(), profily()
###############################################################
## Použité proměnné vnitřní:
#
using Unitful, Unitful.DefaultSymbols
using Printf: @sprintf

function namahaniotl(;
    F=nothing,
    S_otl=nothing,
    sigmaDotl=nothing,
    Re=nothing,
    mat=nothing,
    zatizeni::AbstractString="statický",
    profil=nothing,
    return_text::Bool=true)
    # ----------------------------------------------------------
    # pomocné
    hasq(x) = x !== nothing && isa(x, Unitful.AbstractQuantity)
    isnum(x) = x !== nothing && isa(x, Number)
    attach(x,u) = hasq(x) ? x : x*u
    # ----------------------------------------------------------
    # kontrola duplicity vstupů
    if S_otl !== nothing && profil !== nothing
        error("Zadej pouze jednu z hodnot: S_otl nebo profil.")
    end

    if sigmaDotl !== nothing && mat !== nothing
        error("Zadej pouze jednu z hodnot: sigmaDotl nebo mat.")
    end
    # ----------------------------------------------------------
    # jednotky
    F !== nothing || error("Chybí zatěžující síla F.")
    F = isnum(F) ? attach(F, u"N") : F
    hasq(F) || error("F musí být číslo nebo Unitful.Quantity.")

    if S_otl !== nothing
        S_otl = isnum(S_otl) ? attach(S_otl, u"mm^2") : S_otl
        hasq(S_otl) || error("S_otl musí být číslo nebo Unitful.Quantity.")
    end
    if sigmaDotl !== nothing
        sigmaDotl = isnum(sigmaDotl) ? attach(sigmaDotl, u"MPa") : sigmaDotl
        hasq(sigmaDotl) || error("sigmaDotl musí být číslo nebo Unitful.Quantity.")
    end

    if Re !== nothing
        Re = isnum(Re) ? attach(Re, u"MPa") : Re
        hasq(Re) || error("Re musí být číslo nebo Unitful.Quantity.")
    end
    # ----------------------------------------------------------
    # materiál
    if mat !== nothing
        if !isdefined(Main, :materialy)
            error("Funkce materialy(mat) není definována.")
        end
        matinfo = materialy(mat)
        Re = (matinfo.Re)u"MPa" # mez kluzu
    end
    # dovolené napětí na otlačení
    if Re !== nothing
        sigmaDotl = dovoleneNapeti(Re, "otlaceni", zatizeni)
    end
    sigmaDotl !== nothing || error("Chybí dovolené napětí na otlačení.")
    # ----------------------------------------------------------
    # plocha z profilu
    S_text = ""
    if profil !== nothing
        p = profily(profil, "S")
        haskey(p, :S) || error("profily(...) nevrátilo S.")
        S_otl = p[:S]
        S_text = get(p, :S_str, "")
    end

    S_otl !== nothing || error("Chybí kontaktní plocha S_otl.")
    # ----------------------------------------------------------
    # výpočty
    sigma = uconvert(u"MPa", F / S_otl)
    k = uconvert(u"MPa", sigmaDotl) / sigma
    verdict = k >= 1.5 ? "Spoj je bezpečný" :
              k >= 1.0 ? "Spoj je na hranici bezpečnosti" :
                         "Spoj není bezpečný!"
    # ----------------------------------------------------------
    # výstup
    VV = Dict{Symbol,Any}()
    VV[:info] = "namáhání na otlačení"
    VV[:zatizeni] = zatizeni
    VV[:F] = F
    VV[:F_info] = "Zatěžující síla"
    VV[:S_otl] = S_otl
    VV[:S_otl_str] = S_text
    VV[:S_otl_info] = "Kontaktní plocha"
    VV[:sigmaDotl] = sigmaDotl
    VV[:sigmaDotl_info] = "Dovolené napětí na otlačení"
    VV[:sigma] = sigma
    VV[:sigma_info] = "Skutečné napětí na otlačení"
    VV[:bezpecnost] = k
    VV[:bezpecnost_info] = "Součinitel bezpečnosti"
    VV[:verdict] = verdict
    VV[:verdict_info] = "Výsledek posouzení"
    VV[:mat] = mat
    VV[:mat_info] = "Materiál"
    VV[:profil] = profil === nothing ? "" : profil
    VV[:profil_info] = "Tvar / kontakt"

    return return_text ? (VV, namahaniotltext(VV)) : VV
end

# --------------------------------------------------------------
# textový výstup
function namahaniotltext(VV::Dict{Symbol,Any})
    lines = String[]
    push!(lines, "Výpočet $(VV[:info])")
    push!(lines, "------------------------------------------------------------")
    push!(lines, "materiál: $(VV[:mat])")
    push!(lines, "profil / kontakt: $(VV[:profil])")
    push!(lines, "zatížení: $(VV[:zatizeni])")
    push!(lines, "------------------------------------------------------------")
    push!(lines, "zadání:")
    push!(lines, @sprintf("F = %g N   %s",
        ustrip(u"N", uconvert(u"N", VV[:F])), VV[:F_info]))
    if VV[:S_otl_str] != ""
        push!(lines, @sprintf("S = %s = %g mm^2   %s", VV[:S_otl_str],
            ustrip(u"mm^2", uconvert(u"mm^2", VV[:S_otl])), VV[:S_otl_info]))
    else
        push!(lines, @sprintf("S = %g mm^2   %s",
            ustrip(u"mm^2", uconvert(u"mm^2", VV[:S_otl])),
            VV[:S_otl_info]))
    end
    push!(lines, @sprintf("sigma_dov = %g MPa   %s",
        ustrip(u"MPa", uconvert(u"MPa", VV[:sigmaDotl])), VV[:sigmaDotl_info]))
    push!(lines, "------------------------------------------------------------")
    push!(lines, "výpočet:")
    push!(lines, @sprintf("sigma = %g MPa   %s", ustrip(u"MPa", VV[:sigma]), 
        VV[:sigma_info]))
    push!(lines, @sprintf("k = %g   %s\n%s: %s", ustrip(VV[:bezpecnost]), 
        VV[:bezpecnost_info], VV[:verdict_info], VV[:verdict]))

    return join(lines, "\n")
end