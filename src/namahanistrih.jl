## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet namáhání strojní součásti ve střihu.
# ver: 2026-01-22
## Funkce: namahanistrih()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahanistrih.jl
#
## Vzor:
## vystupni_promenne = namahanistrih(vstupni_promenne)
## Vstupní proměnné:
# F - střižná síla (N)
# S - střižná plocha (mm^2)
# tauDs - dovolené smykové napětí (MPa)
# G - modul pružnosti ve smyku (GPa), volitelné
# E - modul pružnosti v tahu (GPa), volitelné
# Re - mez kluzu (MPa), volitelné
# mat - materiál (řetězec), volitelné
# zatizeni - "statický", "pulzní", "dynamický", "rázový"
# profil - název profilu (volitelné)
# return_text - vrátit i textový výpis
## Výstupní proměnné:
# VV - slovník (Dict) s výsledky výpočtu
#   :info - popis namáhání
#   :zatizeni - typ zatížení (řetězec)
#   :F - střižná síla (Unitful.Quantity)
#   :F_info - popis veličiny F
#   :k - uživatelský požadavek bezpečnosti (Number, volitelné)
#   :k_info - popis veličiny k
#   :S - střižná plocha (Unitful.Quantity)
#   :S_text - textový popis plochy S (řetězec
#   :S_info - popis veličiny S
#   :tau - vypočtené napětí ve střihu (Unitful.Quantity)
#   :tau_str - vzorec pro výpočet tau (řetězec
#   :tau_info - popis veličiny tau
#   :tauDs - dovolené smykové napětí (Unitful.Quantity)
#   :tauDs_info - popis veličiny tauDs
#   :bezpecnost - součinitel bezpečnosti (Number)
#   :bezpecnost_str - vzorec pro výpočet bezpecnost (řetězec)
#   :bezpecnost_info - popis veličiny bezpecnost
#   :verdict - závěr posouzení bezpečnosti (řetězec)
#   :verdict_info - popis veličiny verdict (řetězec)
#   :gamma - deformace ve smyku (Number, volitelné)
#   :gamma_str - vzorec pro výpočet gamma (řetězec)
#   :gamma_info - popis veličiny gamma
#   :G - modul pružnosti ve smyku (Unitful.Quantity, volitelné)
#   :G_info - popis veličiny G
#   :Re - mez kluzu (Unitful.Quantity, volitelné)
#   :Re_info - popis veličiny Re
#   :mat - materiál (řetězec)
#   :mat_info - popis veličiny mat
#   :profil - profil (řetězec)
#   :profil_info - popis veličiny profil
# txt - Volitelně i textový výpis výpočtu. Je-li parametr 
#   return_text=true (výchozí). Pokud return_text=false, vrací 
#   se pouze VV.
## Použité balíčky
# Unitful, Printf: @sprintf
## Použité uživatelské funkce:
# materialy3(), dovoleneNapeti(), profily(), profil_text_lines()
## Příklad:
# F = 10000.0 * u"N"
# mat = "11 373"
# zatizeni = "statický"
# profil = "TR4HR 100x100x6"
# VV, txt = namahanistrih(F=F, mat=mat, zatizeni=zatizeni, profil=profil, return_text=true)
# println(VV) => Dict s výsledky
# println(txt) => textový výpis 
###############################################################
## Použité proměnné vnitřní:
#

using Unitful

function namahanistrih(; F=nothing, S=nothing, tauDs=nothing,
    G=nothing, E=nothing, Re=nothing, mat=nothing,
    zatizeni::AbstractString="statický", k=nothing,
    profil=nothing, return_text::Bool=true)
    # ---------------------------------------------------------
    # pomocné
    # ---------------------------------------------------------
    k_uziv=k
    hasq(x) = x !== nothing && isa(x, Unitful.AbstractQuantity)
    isnum(x) = x !== nothing && isa(x, Number)
    attach_unit(x, u) = hasq(x) ? x : x * u
    # ---------------------------------------------------------
    # kontrola duplicity S / profil
    cntS = (S !== nothing ? 1 : 0) + (profil !== nothing ? 1 : 0)
    if cntS > 1
        error("Zadejte pouze jednu hodnotu z: S nebo profil.")
    end
    if (tauDs !== nothing) && (mat !== nothing)
        error("Zadejte buď tauDs, nebo mat/Re - ne obojí.")
    end
    # ---------------------------------------------------------
    # jednotky
    if F !== nothing
        F = attach_unit(F,u"N")
    else
        error("Chybí střižná síla F.")
    end
    if S !== nothing
        S = attach_unit(S,u"mm^2")
    end
    if tauDs !== nothing
        tauDs = attach_unit(tauDs,u"MPa")
    end
    if Re !== nothing
        Re = attach_unit(Re,u"MPa")
    end
    if G !== nothing
        G = attach_unit(G,u"GPa")
    end
    if E !== nothing
        E = attach_unit(E,u"GPa")
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
        if !isdefined(Main, :materialy)
            error("Funkce materialy(mat) není definována.")
        end
        matinfo = materialy(mat)
        Re = (matinfo.Re)u"MPa" # mez kluzu
        G = (matinfo.G)u"GPa" # modul pružnosti
    end
    # ---------------------------------------------------------
    # dovolené smykové napětí
    # ---------------------------------------------------------
    if tauDs === nothing
        if Re === nothing
            error("Chybí tauDs nebo Re/mat.")
        end
        if !isdefined(Main,:dovoleneNapeti)
            error("Funkce dovoleneNapeti není definována.")
        end
        tauDs = dovoleneNapeti(Re, "střih", zatizeni)
    end
    # ---------------------------------------------------------
    # profil → střižná plocha
    S_text = ""
    profil_info = Dict{Symbol,Any}()
    if profil !== nothing
        if !isdefined(Main,:profily)
            error("Funkce profily není definována.")
        end
        tv = profily(profil, "S")
        if !haskey(tv,:S)
            error("Profil neposkytuje střižnou plochu S.")
        end
        S = tv[:S]
        haskey(tv,:S_str) && (S_text = tv[:S_str])
        for k in keys(tv)
            k ∉ (:S,:S_str) && (profil_info[k] = tv[k])
        end
    end
    # ---------------------------------------------------------
    # validace
    F === nothing && error("Chybí střižná síla F.")
    S === nothing && error("Chybí střižná plocha S.")
    F <= 0u"N" && error("F musí být kladná (velikost síly).")
    # ---------------------------------------------------------
    # výpočet
    # ---------------------------------------------------------
    tau_str = "F / S"
    tau = F / S # napětí ve střihu
    tau = uconvert(u"MPa", tau)
    k_str = "tauDs / tau"
    k = tauDs / tau # součinitel bezpečnosti
    gamma = nothing
    if G !== nothing
        gamma_str = "tau / G"
        gamma = tau / G
        gamma = ustrip(gamma) # bez jednotky
    end
    if k_uziv === nothing
        verdict =   k ≥ 1.5 ?   "Spoj je bezpečný" :
                    k ≥ 1.0 ?   "Spoj je na hranici bezpečnosti" :
                                "Spoj není bezpečný!"
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
    VV[:info] = "namáhání ve střihu"
    VV[:zatizeni] = zatizeni
    VV[:F] = F # zatěžující síla
    VV[:F_info] = "Zatěžující síla"
    VV[:k] = k_uziv # uživatelský požadavek bezpečnosti
    VV[:k_info] = "Uživatelský požadavek bezpečnosti"
    VV[:S] = S # plocha průřezu
    VV[:S_text] = S_text
    VV[:S_info] = "Plocha průřezu"
    VV[:tau] = tau # napětí ve střihu
    VV[:tau_str] = tau_str
    VV[:tau_info] = "Napětí ve střihu"
    VV[:tauDs] = tauDs # dovolené napětí ve střihu
    VV[:tauDs_info] = "Dovolené napětí ve střihu"
    VV[:bezpecnost] = k # součinitel bezpečnosti
    VV[:bezpecnost_str] = k_str
    VV[:bezpecnost_info] = "Součinitel bezpečnosti"
    VV[:verdict] = verdict
    VV[:verdict_info] = "Bezpečnost spoje"
    VV[:gamma] = gamma # deformace ve smyku
    VV[:gamma_str] = @isdefined(gamma_str) ? gamma_str : ""
    VV[:gamma_info] = "Deformace ve smyku"
    VV[:G] = G # modul pružnosti ve smyku
    VV[:G_info] = "Modul pružnosti ve smyku"
    VV[:Re] = Re # mez kluzu
    VV[:Re_info] = "Mez kluzu"
    VV[:mat] = mat
    VV[:mat_info] = "Materiál"
    VV[:profil] = profil === nothing ? "" : profil
    VV[:profil_info] = profil_info

    if return_text
        return VV, StrojniSoucasti.namahanistrihtext(VV)
    else
        return VV
    end
end
