## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet namáhání strojní součásti v ohybu.
# ver: 2026-03-01
## Funkce: namahaniohyb()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahaniohyb.jl
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
# txt - Volitelně i textový výpis výpočtu. Je-li parametr 
#   return_text=true (výchozí). Pokud return_text=false, vrací 
#   se pouze VV.
## Použité balíčky
# Unitful, Printf: @sprintf
## Použité uživatelské funkce:
# materialy(), dovoleneNapeti(), profily(), profil_text_lines()
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

"""
    namahaniohyb(; Mo, Lo=nothing, E=nothing, Ix=nothing, Wo=nothing,
        sigmaDo=nothing, Re=nothing, mat=nothing, zatizeni::AbstractString="statický",
        k=nothing, profil=nothing, natoceni=nothing, return_text::Bool=true)

Výpočet namáhání v ohybu. Vrací slovník s výsledky a volitelně i textový výpis.

Vstupy:
- `Mo`: ohybový moment.
- `Wo`/`Ix`: průřezové charakteristiky (nebo `profil`).
- `sigmaDo`: dovolené napětí v ohybu (nebo `mat`/`Re`).
- `return_text`: pokud `true`, vrací i textový výpis.

Výstup:
- `Dict{Symbol,Any}` s výsledky, případně `(Dict, String)`.

Příklad:
```julia
namahaniohyb(Mo=500u"N*m", profil="TR4HR 100x100x6", mat="S235")
```
"""
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
    profil_info = Dict{Symbol,Any}()
    # ---------------------------------------------------------
    # vstupy – jednotky
    # ---------------------------------------------------------
    if Mo !== nothing
        Mo = attach_unit(Mo, u"N*m")
        if Mo <= 0u"N*m"
            error("Ohybový moment Mo musí být kladný.")
        end
    else
        error("Chybí ohybový moment Mo.")
    end
    if Lo !== nothing
        Lo = attach_unit(Lo, u"mm")
        if Lo <= 0u"mm"
            error("Délka nosníku Lo musí být kladná.")
        end
    end
    if E !== nothing
        E = attach_unit(E, u"MPa")
        if E <= 0u"MPa"
            error("Modul pružnosti E musí být kladný.")
        end
    end
    if Ix !== nothing
        Ix = attach_unit(Ix, u"mm^4")
        if Ix <= 0u"mm^4"
            error("Moment setrvačnosti Ix musí být kladný.")
        end
    end
    if Wo !== nothing
        Wo = attach_unit(Wo, u"mm^3")
        if Wo <= 0u"mm^3"
            error("Průřezový modul v ohybu Wo musí být kladný.")
        end
    end
    if sigmaDo !== nothing
        sigmaDo = attach_unit(sigmaDo, u"MPa")
        if sigmaDo <= 0u"MPa"
            error("Dovolené napětí v ohybu sigmaDo musí být kladné.")
        end
    end
    if Re !== nothing
        Re = attach_unit(Re, u"MPa")
        if Re <= 0u"MPa"
            error("Mez kluzu Re musí být kladná.")
        end
    end
    if k_uziv !== nothing
        if !isnum(k_uziv)
            error("Chybně zadáno k: $k_uziv")
        elseif k_uziv <= 0
            error("k musí být kladné číslo.")
        end
    end
    # ---------------------------------------------------------
    # materiál
    # ---------------------------------------------------------
    if mat !== nothing
        if !isdefined(Main, :materialy)
            error("Funkce materialy(mat) není definována.")
        end
        matinfo = materialy(mat)
        Re = (matinfo.Re)u"MPa" # mez kluzu
        E = (matinfo.E)u"GPa" # modul pružnosti
        matName = matinfo.name # název materiálu z dictu
     else
        matinfo = nothing
        matName = "" # prázdný řetězec, pokud není materiál zadán
    end
    # ---------------------------------------------------------
    # dovolené ohybové napětí
    # ---------------------------------------------------------
    if sigmaDo === nothing
        if Re === nothing && mat === nothing
            error("Chybí sigmaDo, Re, mat - nelze stanovit dovolené napětí.")
        end
        if isdefined(Main, :dovoleneNapeti)
            if matinfo !== nothing
                sigmaDo = dovoleneNapeti("ohyb", zatizeni; mat=matinfo)
            elseif Re !== nothing
                sigmaDo = dovoleneNapeti("ohyb", zatizeni; Re=Re)
            end
        else
            error("Funkce dovoleneNapeti není definována.")
        end
    end
    # ---------------------------------------------------------
    # profil
    # ---------------------------------------------------------
    if profil !== nothing && isdefined(@__MODULE__, :profily)
        tv = profily(profil)  # získání všech informací o profilu
        for k in keys(tv)
            if k ∉ (:S, :S_str) # vynecháme S a S_str, které zpracujeme zvlášť
                profil_info[k] = tv[k] # přidáme další informace z profilu do profil_info
            end
        end
    end

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
    Wo_text = ""
    if Wo === nothing
        if profil === nothing
            error("Chybí Wo nebo profil - nelze stanovit průřezový modul v ohybu.")
        elseif !isdefined(@__MODULE__, :profily)
            error("Funkce profily není definována.")
        else
            tv = profily(profil, "Wo", natoceni)
            if !haskey(tv, :Wo)
                error("Nelze získat Wo z profilu $profil.")
            end
            Wo = tv[:Wo] # získání Wo z profilu
            if haskey(tv, :Wo_str)
                Wo_text = tv[:Wo_str] # získání textového popisu Wo z profilu
            end
        end
    end
    Ix_text = ""
    if Ix === nothing
        if profil !== nothing
            if !isdefined(@__MODULE__, :profily)
                error("Funkce profily není definována.")
            else
                tv = profily(profil, "Ix", natoceni)
                if !haskey(tv, :Ix)
                    error("Nelze získat Ix z profilu $profil.")
                end
                Ix = tv[:Ix] # získání Ix z profilu
                if haskey(tv, :Ix_str)
                    Ix_text = tv[:Ix_str] # získání textového popisu Ix z profilu
                end
            end
        end
    end
    # kontrola, že máme potřebné charakteristiky průřezu
    if Wo === nothing
        error("Chybí průřezový modul v ohybu Wo.")
    end
    # ---------------------------------------------------------
    # výpočet
    # ---------------------------------------------------------
    sigma_str = "Mo / Wo" # napětí v ohybu
    sigma = Mo / Wo # napětí v ohybu
    sigma = uconvert(u"MPa", sigma) # převod na MPa
    delta = nothing
    y = nothing
    alfa = nothing
    if E !== nothing && Ix !== nothing
        delta_str = "Mo / (E * Ix)" # relativní průhyb
        delta = Mo / (E * Ix) # relativní průhyb
        delta = uconvert(u"m^-1", delta) # převod na 1/m
        if Lo !== nothing
            y_str = "Mo * Lo^2 / (3 * E * Ix)" # průhyb na volném konci
            y = Mo * (Lo)^2 / (3 * E * Ix) # průhyb na volném konci
            y = uconvert(u"mm", y) # převod na mm
            alfa_str = "Mo * Lo / (2 * E * Ix)" # úhel natočení průřezu
            alfa = Mo * Lo / (2 * E * Ix) # úhel natočení průřezu
            alfa = uconvert(u"rad", alfa) # převod na radiany
        end
    end
    k_str = "sigmaDo / sigma" # součinitel bezpečnosti
    k = sigmaDo / sigma # součinitel bezpečnosti
    if k_uziv === nothing
        verdict =   if k ≥ 1.5 # obecně doporučovaný minimální součinitel bezpečnosti pro ohyb
                        "Součást je bezpečná"
                    elseif k ≥ 1.0
                        "Součást je na hranici bezpečnosti"
                    else 
                        "Součást není bezpečná!"
                    end
    else
        verdict =   if k >= k_uziv + 0.5 # přidáváme 0.5 jako rezervu nad uživatelský požadavek
                        "Spoj je bezpečný"
                    elseif k >= k_uziv # uživatelský požadavek bezpečnosti je splněn, ale bez rezervy
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
    VV[:Wo_text] = Wo_text # textový popis Wo (např. z profilu)
    VV[:Ix] = Ix # moment setrvačnosti
    VV[:Ix_info] = "Moment setrvačnosti"
    VV[:Ix_text] = Ix_text # textový popis Ix (např. z profilu)
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
    VV[:mat] = matName # materiál
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
