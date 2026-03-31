## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce hrideltext() slouží k vytvoření textového výstupu s 
# popisem výpočtu namáhání kroucením hřídele.
# ver: 2026-03-28
## Funkce: hrideltext()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/hrideltext.jl
#
## Vzor:
## vystupni_promenne = hrideltext(vstupni_promenne)
## Vstupní proměnné:
# VV::Dict{Symbol,Any} - slovník vstupních a výstupních proměnných
## Výstupní proměnné:
# lines - textový výstup s popisem výpočtu
## Použité balíčky
# Printf: @sprintf
## Použité uživatelské funkce:
# profil_text_lines(),
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
using Printf: @sprintf

function hrideltext(VV::Dict{Symbol,Any})
    lines = String[] # pole pro textový výstup

    push!(lines, "Výpočet: $(VV[:info])") # název výpočtu z VV[:info]
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "materiál: $(VV[:mat] === nothing ? "" : string(VV[:mat]))")
    #append!(lines, profil_text_lines(VV)) # přidat info o profilu
    push!(lines, "zatížení: $(VV[:zatizeni])") # přidat info o zatížení do textového výstupu
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "zadání:") # přidat info o zadání výpočtu
    if VV[:druh] == "hybný"
        push!(lines, @sprintf("Mk = %g   %s", VV[:Mk], VV[:Mk_info]))
    elseif VV[:druh] == "nosný"
        push!(lines, @sprintf("Fr = %g   %s", VV[:Fr], VV[:Fr_info]))
    end
    push!(lines, @sprintf("D = %g   %s", VV[:D], VV[:D_info]))
    if VV[:d] !== nothing
        push!(lines, @sprintf("d = %g   %s", VV[:d], VV[:d_info]))
    end
    if VV[:L0] !== nothing
        push!(lines, @sprintf("L = %g   %s", VV[:L0], VV[:L0_info]))
    end
    if VV[:k] !== nothing
        push!(lines, @sprintf("k = %g   %s", VV[:k], VV[:k_info]))
    end
    if VV[:Wk] !== nothing
        if VV[:Wk_str] == ""
            push!(lines, @sprintf("Wk = %g   %s", VV[:Wk], VV[:Wk_info]))
        else
            push!(lines, @sprintf("Wk = %s = %g   %s", VV[:Wk_str], VV[:Wk], VV[:Wk_info]))
        end
    end
    if VV[:Ip] !== nothing
        if VV[:Ip_str] == ""
            push!(lines, @sprintf("Ip = %g   %s", VV[:Ip], VV[:Ip_info]))
        else
            push!(lines, @sprintf("Ip = %s = %g   %s", VV[:Ip_str], VV[:Ip], VV[:Ip_info]))
        end
    end
    if VV[:tauDk] !== nothing
        push!(lines, @sprintf("tauDk = %g   %s", VV[:tauDk], VV[:tauDk_info]))
    end
    if VV[:G] !== nothing
        push!(lines, @sprintf("G = %g   %s", VV[:G], VV[:G_info]))
    end
    push!(lines,"-----------------------------------------------------------------")
    push!(lines, "výpočet:")
    if VV[:tau_str] == ""
        push!(lines, @sprintf("tau = %g   %s", VV[:tau], VV[:tau_info]))
    else
        push!(lines, @sprintf("tau = %s = %g   %s", VV[:tau_str], VV[:tau], VV[:tau_info]))
    end
    if VV[:phi] !== nothing # úhel zkroucení
        if VV[:phi_str] == ""
            push!(lines, @sprintf("phi = %g   %s", VV[:phi], VV[:phi_info]))
        else
            push!(lines, @sprintf("phi = %s = %g   %s", VV[:phi_str],VV[:phi], VV[:phi_info]))
        end
        push!(lines, @sprintf("phi = %g   %s", uconvert(u"deg", VV[:phi]), VV[:phi_info]))
    end
    if VV[:theta] !== nothing # poměrné zkroucení
        if VV[:theta_str] == ""
            push!(lines, @sprintf("theta = %g   %s", VV[:theta], VV[:theta_info]))
        else
            push!(lines, @sprintf("theta = %s = %g   %s", VV[:theta_str], VV[:theta], 
                VV[:theta_info]))
        end
        push!(lines, @sprintf("theta = %g   %s", uconvert(u"deg/m", VV[:theta]), 
            VV[:theta_info]))
    end
    push!(lines, @sprintf("k = %s = %g   %s\n%s: %s", VV[:bezpecnost_str], 
        VV[:bezpecnost], VV[:bezpecnost_info], VV[:verdict_info], VV[:verdict]))
    return join(lines, "\n")
end
