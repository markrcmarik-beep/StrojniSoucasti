## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Kontrola namáhání na otlačení (plošný tlak).
# ver: 2026-02-21
## Funkce: namahaniotl()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahani/namahaniotl.jl
#
## Vzor:
## VV, txt = namahaniotl(F=5000N, S=120mm^2, mat="11373")
## VV = namahaniotl(F=5000N, profil="PLECH 10x30", mat="11373", return_text=false)
## Vstupní proměnné:
# F - zatěžující síla (Unitful.Quantity nebo Number v N)
# S - kontaktní plocha (Unitful.Quantity nebo Number v mm²)
# sigmaDotl - dovolené napětí na otlačení (Unitful.Quantity nebo Number v MPa)
# Re - meze kluzu materiálu (Unitful.Quantity nebo Number v MPa)
# mat - materiál (řetězec nebo číslo dle materialy())
# zatizeni - typ zatížení ("statický" nebo "dynamický", výchozí "statický")
# profil - tvar profilu nebo kontaktu (řetězec dle profily()), alternativně k S
# return_text - zda vrátit i textový výstup (Bool, výchozí true)
## Výstupní proměnné:
# VV - slovník (Dict) s výsledky výpočtu
#   :info - popis výpočtu (řetězec)
#   :zatizeni - typ zatížení (řetězec)
#   :F - zatěžující síla (Unitful.Quantity)
#   :F_info - popis veličiny F (řetězec)
#   :S - kontaktní plocha (Unitful.Quantity)
#   :S_str - textový popis plochy S (řetězec)
#   :S_info - popis veličiny S (řetězec)
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
# txt - Volitelně i textový výpis výpočtu. Je-li parametr 
#   return_text=true (výchozí). Pokud return_text=false, vrací 
#   se pouze VV.
## Použité balíčky:
# Unitful, Printf
## Použité uživatelské funkce:
# materialy(), dovoleneNapeti(), profily()
###############################################################
## Použité proměnné vnitřní:
#
using Unitful, Unitful.DefaultSymbols
using Printf: @sprintf

"""
    namahaniotl(; F, S=nothing, sigmaDotl=nothing, Re=nothing, mat=nothing,
        zatizeni::AbstractString="statický", profil=nothing, return_text::Bool=true)

Kontrola namáhání na otlačení (plošný tlak). Vrací slovník s výsledky
a volitelně i textový výpis.

Vstupy:
- `F`: zatěžující síla.
- `S`: kontaktní plocha (nebo `profil`).
- `sigmaDotl`: dovolené napětí (nebo `mat`/`Re`).
- `return_text`: pokud `true`, vrací i textový výpis.

Výstup:
- `Dict{Symbol,Any}` s výsledky, případně `(Dict, String)`.

Příklad:
```julia
namahaniotl(F=5000u"N", profil="PLECH 10x30", mat="S235")
```
"""
function namahaniotl(;
    F=nothing,
    S=nothing,
    sigmaDotl=nothing,
    Re=nothing,
    mat=nothing,
    zatizeni::AbstractString="statický",
    profil=nothing,
    k=nothing,
    return_text::Bool=true)
    # ----------------------------------------------------------
    # pomocné
    hasq(x) = x !== nothing && isa(x, Unitful.AbstractQuantity)
    isnum(x) = x !== nothing && isa(x, Number)
    attach(x,u) = hasq(x) ? x : x*u
    # ----------------------------------------------------------
    # kontrola duplicity vstupů
    if S !== nothing && profil !== nothing
        error("Zadej pouze jednu z hodnot: S nebo profil.")
    end

    if sigmaDotl !== nothing && mat !== nothing
        error("Zadej pouze jednu z hodnot: sigmaDotl nebo mat.")
    end
    # ----------------------------------------------------------
    # jednotky
    F !== nothing || error("Chybí zatěžující síla F.")
    F = isnum(F) ? attach(F, u"N") : F
    hasq(F) || error("F musí být číslo nebo Unitful.Quantity.")

    if S !== nothing
        S = isnum(S) ? attach(S, u"mm^2") : S
        hasq(S) || error("S musí být číslo nebo Unitful.Quantity.")
    end
    if sigmaDotl !== nothing
        sigmaDotl = isnum(sigmaDotl) ? attach(sigmaDotl, u"MPa") : sigmaDotl
        hasq(sigmaDotl) || error("sigmaDotl musí být číslo nebo Unitful.Quantity.")
    end

    if Re !== nothing
        Re = isnum(Re) ? attach(Re, u"MPa") : Re
        hasq(Re) || error("Re musí být číslo nebo Unitful.Quantity.")
    end
    if k !== nothing
        isnum(k) || error("k musí být číslo.")
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
        sigmaDotl = dovoleneNapeti("otlačení", zatizeni; Re=Re)
    end
    sigmaDotl !== nothing || error("Chybí dovolené napětí na otlačení.")
    # ----------------------------------------------------------
    # plocha z profilu
    S_text = ""
    profil_info = Dict{Symbol,Any}()
    if profil !== nothing
        p = profily(profil, "S")
        haskey(p, :S) || error("profily(...) nevrátilo S.")
        S = p[:S]
        S_text = get(p, :S_str, "")
        for kk in keys(p)
            if kk ∉ (:S, :S_str)
                profil_info[kk] = p[kk]
            end
        end
    end

    S !== nothing || error("Chybí kontaktní plocha S.")
    # ----------------------------------------------------------
    # výpočty
    sigma_str = "F / S"
    sigma = uconvert(u"MPa", F / S)
    sigmaDotl = uconvert(u"MPa", sigmaDotl)
    bezpecnost_str = "sigmaDt / sigma"
    bezpecnost = sigmaDotl / sigma
    verdict = bezpecnost >= 1.5 ? "Spoj je bezpečný" :
              bezpecnost >= 1.0 ? "Spoj je na hranici bezpečnosti" :
                                  "Spoj není bezpečný!"
    # ----------------------------------------------------------
    # výstup
    VV = Dict{Symbol,Any}()
    VV[:info] = "namáhání na otlačení"
    VV[:zatizeni] = zatizeni
    VV[:zatizeni_info] = "Druh zatížení"
    VV[:F] = F # zatěžující síla
    VV[:F_info] = "Zatěžující síla"
    VV[:k] = k # součinitel bezpečnosti (uživatelský požadavek)
    VV[:k_info] = "Uživatelský požadavek bezpečnosti"
    VV[:S] = S # kontaktní plocha
    VV[:S_text] = S_text
    VV[:S_str] = S_text
    VV[:S_info] = "Kontaktní plocha"
    VV[:sigmaDotl] = sigmaDotl
    VV[:sigmaDotl_info] = "Dovolené napětí na otlačení"
    VV[:sigma] = sigma # skutečné napětí
    VV[:sigma_str] = sigma_str
    VV[:sigma_info] = "Skutečné napětí na otlačení"
    VV[:Re] = Re # mez kluzu
    VV[:Re_info] = "Mez kluzu"
    VV[:bezpecnost] = bezpecnost
    VV[:bezpecnost_str] = bezpecnost_str
    VV[:bezpecnost_info] = "Součinitel bezpečnosti"
    VV[:verdict] = verdict
    VV[:verdict_info] = "Výsledek posouzení"
    VV[:mat] = mat # materiál
    VV[:mat_info] = "Materiál"
    VV[:profil] = profil === nothing ? "" : profil
    VV[:profil_info] = profil_info

    return return_text ? (VV, StrojniSoucasti.namahaniotltext(VV)) : VV
end
