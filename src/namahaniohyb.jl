## Funkce Julia
###############################################################
## Popis funkce:
# Výpočet namáhání strojní součásti v ohybu.
# ver: 2026-01-07
## Funkce: namahaniohyb()
#
## Vzor:
## vystupni_promenne = namahaniohyb(vstupni_promenne)
## Vstupní proměnné:
# Mo   - ohybový moment (N*m)
# Wo   - průřezový modul v ohybu (mm^3)
# sigmaDo - dovolené napětí v ohybu (MPa)
# Re   - mez kluzu (MPa), volitelné
# mat  - materiál (řetězec)
# zatizeni - "statický", "pulzní", "dynamický", "rázový"
# profil - název profilu (volitelné)
# natoceni - natočení profilu (volitelné)
# return_text - vrátit i textový výpis
## Výstupní proměnné:
# VV - Dict s výsledky
#   :info - popis namáhání
#   :Mo - ohybový moment
#   :Wo - průřezový modul v ohybu
#   :Lo - délka nosníku (pokud je zadána)
#   :sigmaDo - dovolené napětí v ohybu
#   :sigma - vypočtené napětí v ohybu
#   :delta - relativní průhyb (pokud je možné vypočítat)
#   :y - průhyb na volném konci (pokud je možné vypočítat)
#   :alfa - úhel natočení průřezu (pokud je možné vypočítat)
#   :bezpecnost - součinitel bezpečnosti
#   :verdict - závěr posouzení bezpečnosti
#   :Re - mez kluzu (pokud je zadána nebo získána z mat)
#   :E - modul pružnosti (pokud je zadána nebo získána z mat)
#   :mat - materiál
#   :profil - profil
#   :natoceni - natočení profilu
# txt - textový výpis (volitelně)
## Použité balíčky
# Unitful, Printf: @sprintf
## Použité uživatelské funkce:
# materialy3(), dovoleneNapeti(), tvarprofilu(), profil_text_lines()
## Příklad:
# Mo = 500.0 * u"N*m"
# mat = "11 373"
# zatizeni = "statický"
# profil = "TR4HR 100x100x6"
# natoceni = 0.0 * u"rad" (nepovinné)
# VV, txt = namahaniohyb(Mo=Mo, Wo=Wo, sigmaDo=sigmaDo, mat=mat, zatizeni=zatizeni, 
# profil=profil, natoceni=natoceni, return_text=true)
# println(VV) => Dict s výsledky
# println(txt) => textový výpis
###############################################################
## Použité proměnné vnitřní:
#

using Unitful

function namahaniohyb(;
    Mo = nothing, Lo = nothing, E = nothing, Ix = nothing,
    Wo = nothing, sigmaDo = nothing, Re = nothing, mat = nothing,
    zatizeni::AbstractString = "statický", k = nothing,
    profil = nothing, natoceni = nothing,
    return_text::Bool = true)
    # ---------------------------------------------------------
    # pomocné
    # ---------------------------------------------------------
    k_uziv=k
    hasq(x) = x !== nothing && isa(x, Unitful.AbstractQuantity)
    isnum(x) = x !== nothing && isa(x, Number)
    attach_unit(x, u) = hasq(x) ? x : x * u
    # ---------------------------------------------------------
    # vstupy – jednotky
    # ---------------------------------------------------------
    if Mo !== nothing
        Mo = attach_unit(Mo, u"N*m")
    else
        error("Chybí ohybový moment Mo.")
    end
    if Lo !== nothing
        Lo = attach_unit(Lo, u"mm")
    end
    if E !== nothing
        E = attach_unit(E, u"MPa")
    end
    if Ix !== nothing
        Ix = attach_unit(Ix, u"mm^4")
    end
    if Wo !== nothing
        Wo = attach_unit(Wo, u"mm^3")
    end
    if sigmaDo !== nothing
        sigmaDo = attach_unit(sigmaDo, u"MPa")
    end
    if Re !== nothing
        Re = attach_unit(Re, u"MPa")
    end
    if k_uziv !== nothing
        if !isnum(k_uziv)
            error("Chybně zadáno k: $k_uziv")
        end
    end
    # ---------------------------------------------------------
    # materiál
    # ---------------------------------------------------------
    if mat !== nothing
        if !isdefined(Main, :materialy3)
            error("Funkce materialy3(mat) není definována.")
        end
        raw = materialy3(mat)
        matinfo = isa(raw, Tuple) ? raw[1] : raw
        haskey(matinfo, :Re) && (Re = matinfo[:Re]) # mez kluzu
        haskey(matinfo, :E) && (E = matinfo[:E]) # modul pružnosti
    end
    # ---------------------------------------------------------
    # dovolené napětí
    # ---------------------------------------------------------
    if sigmaDo === nothing
        if Re === nothing
            error("Chybí sigmaDo i Re - nelze stanovit dovolené napětí.")
        end
        if !isdefined(Main, :dovoleneNapeti)
            error("Funkce dovoleneNapeti není definována.")
        end
        sigmaDo = dovoleneNapeti(Re, "ohyb", zatizeni)
    end
    # ---------------------------------------------------------
    # profil
    # ---------------------------------------------------------
    profil_info = Dict{Symbol,Any}()
    if natoceni === nothing
        natoceni = 0 * u"rad"
    elseif natoceni isa Real
        if natoceni isa Real && !(natoceni isa Unitful.Quantity)
            natoceni = natoceni * u"rad"
        elseif natoceni isa Unitful.Quantity && unit(natoceni) == 
            u"°" && unit(natoceni) !== u"rad" natoceni = rad(natoceni)
        else
            error("Parametr natoceni musí být úhel v radiánech nebo stupních. [rad]")
        end
    elseif !isa(natoceni, Number)
        error("Parametr natoceni musí být čísLo. [rad]")
    end
    if profil !== nothing
        if !isdefined(Main, :tvarprofilu)
            error("Funkce tvarprofilu není definována.")
        end
        tv = tvarprofilu(profil, "Wo", "Ix", natoceni)
        if Wo === nothing && haskey(tv, :Wo)
            Wo = tv[:Wo]
        end
        haskey(tv, :Wo_str) && (profil_info[:Wo_str] = tv[:Wo_str])
        if Ix === nothing && haskey(tv, :Ix)
            Ix = tv[:Ix]
        end
        haskey(tv, :Ix_str) && (profil_info[:Ix_str] = tv[:Ix_str])
        for k in keys(tv)
            if k ∉ (:Wo, :Wo_str)
                profil_info[k] = tv[k]
            end
        end
    end
    if Wo === nothing
        error("Chybí průřezový modul v ohybu Wo.")
    end
    # ---------------------------------------------------------
    # výpočet
    # ---------------------------------------------------------
    sigma_str = "Mo / Wo"
    sigma = Mo / Wo
    sigma = uconvert(u"MPa", sigma)
    delta = nothing
    y = nothing
    alfa = nothing
    if E !== nothing && Ix !== nothing
        delta_str = "Mo / (E * Ix)"
        delta = Mo / (E * Ix)
        delta = uconvert(u"m^-1", delta)
        if Lo !== nothing
            y_str = "Mo * Lo^2 / (3 * E * Ix)"
            y = Mo * (Lo)^2 / (3 * E * Ix)
            y = uconvert(u"mm", y)
            alfa_str = "Mo * Lo / (2 * E * Ix)"
            alfa = Mo * Lo / (2 * E * Ix)
            alfa = uconvert(u"rad", alfa)
        end
    end
    k_str = "sigmaDo / sigma"
    k = sigmaDo / sigma
    if k_uziv === nothing
        verdict =   if k ≥ 1.5
                        "Součást je bezpečná"
                    elseif k ≥ 1.0
                        "Součást je na hranici bezpečnosti"
                    else
                        "Součást není bezpečná!"
                    end
    else
        verdict =   if k >= k_uziv + 0.5
                        "Spoj je bezpečný"
                    elseif k >= k_uziv
                        "Spoj je na hranici bezpečnosti"
                    else
                        "Spoj není bezpečný!"
                    end # konec if
    end
    # ---------------------------------------------------------
    # výstup
    # ---------------------------------------------------------
    VV = Dict{Symbol,Any}()
    VV[:info] = "namáhání v ohybu"
    VV[:zatizeni] = zatizeni # druh zatížení (statický, pulzní, dynamický, rázový)
    VV[:zatizeni_info] = "Druh zatížení"
    VV[:Mo] = Mo # ohybový moment
    VV[:Mo_info] = "Ohybový moment"
    VV[:k] = k_uziv # uživatelský požadavek bezpečnosti
    VV[:k_info] = "Uživatelský požadavek bezpečnosti"
    VV[:Wo] = Wo # průřezový modul v ohybu
    VV[:Wo_info] = "Průřezový modul v ohybu"
    VV[:Wo_text] = get(profil_info, :Wo_str, "")
    VV[:Ix] = Ix # moment setrvačnosti
    VV[:Ix_info] = "Moment setrvačnosti"
    VV[:Ix_text] = get(profil_info, :Ix_str, "")
    VV[:Lo] = Lo # délka nosníku
    VV[:Lo_info] = "Délka nosníku"
    VV[:sigmaDo] = sigmaDo # dovolené napětí v ohybu
    VV[:sigmaDo_info] = "Dovolené napětí v ohybu"
    VV[:sigma] = sigma # napětí v ohybu
    VV[:sigma_str] = sigma_str
    VV[:sigma_info] = "Napětí v ohybu"
    VV[:delta] = delta # relativní průhyb
    VV[:delta_str] = @isdefined(delta_str) ?  delta_str : ""
    VV[:delta_info] = "Relativní průhyb"
    VV[:y] = y # průhyb na volném konci
    VV[:y_str] = @isdefined(y_str) ? y_str : ""
    VV[:y_info] = "Průhyb na volném konci"
    VV[:alfa] = alfa # úhel natočení průřezu
    VV[:alfa_str] = @isdefined(alfa_str) ? alfa_str : ""
    VV[:alfa_info] = "Úhel natočení průřezu"
    VV[:bezpecnost] = k # součinitel bezpečnosti
    VV[:bezpecnost_str] = k_str
    VV[:bezpecnost_info] = "Součinitel bezpečnosti"
    VV[:verdict] = verdict # závěr posouzení bezpečnosti
    VV[:verdict_info] = "Závěr posouzení bezpečnosti"
    VV[:Re] = Re # mez kluzu
    VV[:Re_info] = "Mez kluzu"
    VV[:E] = E # modul pružnosti
    VV[:E_info] = "Modul pružnosti"
    VV[:mat] = mat # materiál
    VV[:mat_info] = mat === nothing ? "" : "Materiál"
    VV[:profil] = profil === nothing ? "" : profil
    VV[:profil_info] = profil_info # info o profilu
    VV[:natoceni] = natoceni # natočení profilu
    VV[:natoceni_info] = "Natočení profilu"
    if return_text
        return VV, StrojniSoucasti.namahaniohybtext(VV)
    else
        return VV
    end
end
