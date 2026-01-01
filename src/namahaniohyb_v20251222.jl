## Funkce Julia
###############################################################
## Popis funkce:
# Výpočet namáhání strojní součásti v ohybu.
# ver: 2025-12-22
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
# txt - textový výpis (volitelně)
## Použité balíčky
# Unitful, Printf: @sprintf
## Použité uživatelské funkce:
# materialy(), dovoleneNapeti(), tvarprofilu(), profil_text_lines()
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
using Printf: @sprintf

function namahaniohyb(;
    Mo = nothing,
    Wo = nothing,
    sigmaDo = nothing,
    Re = nothing,
    mat = nothing,
    zatizeni::AbstractString = "statický",
    profil = nothing,
    natoceni = nothing,
    return_text::Bool = true)

    # ---------------------------------------------------------
    # pomocné
    # ---------------------------------------------------------
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

    if Wo !== nothing
        Wo = attach_unit(Wo, u"mm^3")
    end

    if sigmaDo !== nothing
        sigmaDo = attach_unit(sigmaDo, u"MPa")
    end

    if Re !== nothing
        Re = attach_unit(Re, u"MPa")
    end

    # ---------------------------------------------------------
    # materiál
    # ---------------------------------------------------------
    if mat !== nothing
        if !isdefined(Main, :materialy)
            error("Funkce materialy(mat) není definována.")
        end
        raw = materialy(mat)
        matinfo = isa(raw, Tuple) ? raw[1] : raw

        haskey(matinfo, :Re) && (Re = matinfo[:Re])
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
        error("Parametr natoceni musí být číslo. [rad]")
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

    k_str = "sigmaDo / sigma"
    k = sigmaDo / sigma

    verdict = if k ≥ 1.5
        "Součást je bezpečná"
    elseif k ≥ 1.0
        "Součást je na hranici bezpečnosti"
    else
        "Součást není bezpečná!"
    end

    # ---------------------------------------------------------
    # výstup
    # ---------------------------------------------------------
    VV = Dict{Symbol,Any}()

    VV[:info] = "namáhání v ohybu"
    VV[:zatizeni] = zatizeni

    VV[:Mo] = Mo # ohybový moment
    VV[:Mo_info] = "Ohybový moment"

    VV[:Wo] = Wo # průřezový modul v ohybu
    VV[:Wo_info] = "Průřezový modul v ohybu"
    VV[:Wo_text] = get(profil_info, :Wo_str, "")

    VV[:sigmaDo] = sigmaDo # dovolené napětí v ohybu
    VV[:sigmaDo_info] = "Dovolené napětí v ohybu"

    VV[:sigma] = sigma # napětí v ohybu
    VV[:sigma_str] = sigma_str
    VV[:sigma_info] = "Napětí v ohybu"

    VV[:bezpecnost] = k # součinitel bezpečnosti
    VV[:bezpecnost_str] = k_str
    VV[:bezpecnost_info] = "Součinitel bezpečnosti"

    VV[:verdict] = verdict # závěr posouzení
    VV[:verdict_info] = "Závěr posouzení"

    VV[:Re] = Re # mez kluzu
    VV[:Re_info] = "Mez kluzu"
    VV[:mat] = mat # materiál
    VV[:profil] = profil === nothing ? "" : profil
    VV[:profil_info] = profil_info
    VV[:natoceni] = natoceni # natočení profilu
    VV[:natoceni_info] = "Natočení profilu"

    if return_text
        return VV, namahaniohybtext(VV)
    else
        return VV
    end
end

function namahaniohybtext(VV::Dict{Symbol,Any})
    lines = String[]

    push!(lines, "Výpočet $(VV[:info])")
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "materiál: $(VV[:mat] === nothing ? "" : VV[:mat])")
    append!(lines, profil_text_lines(VV)) # přidá text profilu
    push!(lines, "zatížení: $(VV[:zatizeni])")
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "zadání:")
    push!(lines, @sprintf("Mo = %g   %s", VV[:Mo], VV[:Mo_info]))
    if VV[:natoceni] !== nothing
        push!(lines, @sprintf("natočení = %g   %s", VV[:natoceni], VV[:natoceni_info]))
    end
    push!(lines, @sprintf("Wo = %g   %s", VV[:Wo], VV[:Wo_info]))
    if VV[:Re] !== nothing
        push!(lines, @sprintf("Re = %g   %s", VV[:Re], VV[:Re_info]))
    end
    push!(lines, @sprintf("sigmaDo = %g   %s", VV[:sigmaDo], VV[:sigmaDo_info]))
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "výpočet:")
    push!(lines, @sprintf("sigma = %s = %g   %s",
        VV[:sigma_str], VV[:sigma], VV[:sigma_info]))
    push!(lines, @sprintf("k = %s = %g   %s\n%s: %s", VV[:bezpecnost_str],
        ustrip(VV[:bezpecnost]), VV[:bezpecnost_info], VV[:verdict_info], VV[:verdict]))
    push!(lines, "----------------------------------------------------------------")

    return join(lines, "\n")
end