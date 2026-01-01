## Funkce Julia
###############################################################
## Popis funkce:
# Výpočet kombinovaného namáhání (tah/tlak + střih/krut)
# pomocí HMH nebo Tresca kritéria.
# ver: 2025-12-15
## Funkce: namahanikombinovane()
#
## Vzor:
## vystupni_promenne = namahanikombinovane(vstupni_promenne)
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

using Unitful, Unitful.DefaultSymbols
using Printf: @sprintf

###############################################################
## Funkce Julia
###############################################################
## Popis funkce:
# Výpočet kombinovaného namáhání (tah/tlak + střih/krut)
# pomocí HMH nebo Tresca kritéria.
#
# Funkce využívá výhradně výstupy z již existujících funkcí
# namáhání (namahanitah, namahanitlak, namahanistrih, namahanikrut).
#
## ver: 2025-12-15
## Funkce: namahanikombinovane()
#
## Vstup:
# vysledky  - Vector{Dict} výstupů z dílčích funkcí namáhání
# kriterium - :HMH nebo :Tresca (výchozí :HMH)
# sigmaD    - dovolené napětí (MPa), volitelné pokud je v datech Re
# zatizeni  - typ zatížení ("statický", "dynamický", "rázový")
# return_text - vrátí i textový výpis (true/false)
#
## Výstup:
# VV - Dict s výsledky kombinovaného namáhání
# txt - textový výpis (volitelně)
###############################################################

function namahanikombinovane(; 
    vysledky::Vector{Dict{Symbol,Any}},
    kriterium::Symbol = :HMH,
    sigmaD = nothing,
    zatizeni::AbstractString = "statický",
    return_text::Bool = true)

    # ---------------------------------------------------------
    # sběr napětí
    # ---------------------------------------------------------
    sigma_list = Unitful.Quantity[]
    tau_list   = Unitful.Quantity[]
    Re = nothing
println(vysledky)
println("--- 01 ---")
println("1. - ",vysledky[1][:info])
println("2. - ",vysledky[2][:info])
println("zatížení z první matice: ", vysledky[1][:zatizeni])
println("zatížení z druhé matice: ", vysledky[2][:zatizeni])

vsldk1 = vysledky[1][:info]
vsldk2 = vysledky[2][:info]
if ((vsldk1 == "namáhání v tahu" && 
    vsldk2 == "namáhání ve střihu") ||
    (vsldk1 == "namáhání ve střihu" && 
    vsldk2 == "namáhání v tahu"))
    namahanizkr = "tah-střih"
    namahani_info = "namáhání v tahu - střihu"
elseif ((vsldk1 == "namahani v tlaku" && 
    vsldk2 == "namáhání ve střihu") ||
    (vsldk1 == "namahani ve střihu" && 
    vsldk2 == "namáhání v tlaku"))
    namahanizkr = "tlak-střih"
    namahani_info = "namáháni v tlaku - střihu"
elseif ((vsldk1 == "namáháni v tahu" && 
    vsldk2 == "namáhání v krutu")) ||
    (vsldk1 == "namáháni v krutu" && 
    vsldk2 == "namáhání v tahu")
    namahanizkr = "tlak-krut"
    namahani_info = "namáhání v tlaku - krutu"
end

    for VV in vysledky
        if haskey(VV, :sigma) && VV[:sigma] !== nothing
            push!(sigma_list, uconvert(u"MPa", VV[:sigma]))
        end
        if haskey(VV, :tau) && VV[:tau] !== nothing
            push!(tau_list, uconvert(u"MPa", VV[:tau]))
        end
        if haskey(VV, :Re) && VV[:Re] !== nothing
            Re = VV[:Re]
        end
    end

    sigma = isempty(sigma_list) ? 0u"MPa" : sum(sigma_list)
    tau   = isempty(tau_list)   ? 0u"MPa" : sum(tau_list)

    # ---------------------------------------------------------
    # dovolené napětí
    # ---------------------------------------------------------
    if sigmaD === nothing
        if Re === nothing
            error("Chybí sigmaD i Re – nelze stanovit bezpečnost.")
        end
        if !isdefined(Main, :dovoleneNapeti)
            error("Funkce dovoleneNapeti není definována.")
        end
        sigmaD = dovoleneNapeti(Re, namahanizkr, zatizeni)
    end

    sigmaD = uconvert(u"MPa", sigmaD)

    # ---------------------------------------------------------
    # ekvivalentní napětí
    # ---------------------------------------------------------
    sigma_val = ustrip(sigma)
    tau_val   = ustrip(tau)

    sigma_eq = kriterium === :HMH ?
        sqrt(sigma_val^2 + 3*tau_val^2) :
        sqrt(sigma_val^2 + 4*tau_val^2)

    sigma_eq = sigma_eq * u"MPa"

    # ---------------------------------------------------------
    # bezpečnost
    # ---------------------------------------------------------
    k = sigmaD / sigma_eq

    verdict = if k >= 1.5
        "Součást je bezpečná"
    elseif k >= 1.0
        "Součást je na hranici bezpečnosti"
    else
        "Součást není bezpečná!"
    end

    # ---------------------------------------------------------
    # výstupní dict
    # ---------------------------------------------------------
    VV = Dict{Symbol,Any}()

    VV[:info] = namahani_info
    VV[:kriterium] = kriterium
    VV[:zatizeni] = zatizeni

    VV[:sigma] = sigma
    VV[:sigma_info] = "Výsledné normálové napětí"

    VV[:tau] = tau
    VV[:tau_info] = "Výsledné smykové napětí"

    VV[:sigma_eq] = sigma_eq
    VV[:sigma_eq_info] = "Ekvivalentní napětí"

    VV[:sigmaD] = sigmaD
    VV[:sigmaD_info] = "Dovolené napětí"

    VV[:bezpecnost] = k
    VV[:bezpecnost_info] = "Součinitel bezpečnosti"

    VV[:verdict] = verdict
    VV[:verdict_info] = "Závěr posouzení"

    if return_text
        return VV, namahanikombinovanetext(VV)
    else
        return VV
    end
end

function namahanikombinovanetext(VV::Dict{Symbol,Any})
    lines = String[]

    push!(lines, "Výpočet $(VV[:info])")
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "kritérium: $(VV[:kriterium])")
    push!(lines, "zatížení:  $(VV[:zatizeni])")
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "napětí:")

    push!(lines, @sprintf("sigma = %g   %s",
        VV[:sigma], VV[:sigma_info]))

    push!(lines, @sprintf("tau   = %g   %s",
        VV[:tau], VV[:tau_info]))

    push!(lines, "----------------------------------------------------------------")
    push!(lines, "kombinace:")

    push!(lines, @sprintf("sigma_eq = %g   %s",
        VV[:sigma_eq], VV[:sigma_eq_info]))

    push!(lines, @sprintf("sigmaD   = %g   %s",
        VV[:sigmaD], VV[:sigmaD_info]))

    push!(lines, "----------------------------------------------------------------")
    push!(lines, @sprintf("k = %g   %s\n%s: %s",
        ustrip(VV[:bezpecnost]),
        VV[:bezpecnost_info],
        VV[:verdict_info],
        VV[:verdict]))

    return join(lines, "\n")
end