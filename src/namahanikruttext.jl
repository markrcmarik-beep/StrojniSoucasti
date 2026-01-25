## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet namáhání v krutu pro strojní součásti. Generování 
# textového výpisu výpočtu.
# ver: 2026-01-25
## Funkce: namahanikruttext()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahanikruttext.jl
#
## Vzor:
## vystupni_promenne = namahanikruttext(vstupni_promenne)
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

function namahanikruttext(VV::Dict{Symbol,Any})
    lines = String[]
    push!(lines, "Výpočet $(VV[:info])")
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "materiál: $(VV[:mat] === nothing ? "" : string(VV[:mat]))")
    append!(lines, profil_text_lines(VV)) # přidat info o profilu
    push!(lines, "zatížení: $(VV[:zatizeni])")
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "zadání:")
    push!(lines, @sprintf("Mk = %g   %s", VV[:Mk], VV[:Mk_info]))
    if VV[:k] !== nothing
        push!(lines, @sprintf("k = %g   %s", VV[:k], VV[:k_info]))
    end
    if VV[:Wk] !== nothing
        push!(lines, @sprintf("Wk = %s = %g   %s", VV[:Wk_text], VV[:Wk], VV[:Wk_info]))
    end
    if VV[:Ip] !== nothing
        push!(lines, @sprintf("Ip = %s = %g   %s", VV[:Ip_text], VV[:Ip], VV[:Ip_info]))
    end
    if VV[:tauDk] !== nothing
        push!(lines, @sprintf("tauDk = %g   %s", VV[:tauDk], VV[:tauDk_info]))
    end
    if VV[:G] !== nothing
        push!(lines, @sprintf("G = %g   %s", VV[:G], VV[:G_info]))
    end
    push!(lines,"-----------------------------------------------------------------")
    push!(lines, "výpočet:")
    push!(lines, @sprintf("tau = %s = %g   %s", VV[:tau_str], VV[:tau], VV[:tau_info]))
    if VV[:phi] !== nothing # úhel zkroucení
        push!(lines, @sprintf("phi = %s = %g   %s", VV[:phi_str],VV[:phi], VV[:phi_info]))
        push!(lines, @sprintf("phi = %g   %s", uconvert(u"deg", VV[:phi]), VV[:phi_info]))
    end
    if VV[:theta] !== nothing # poměrné zkroucení
        push!(lines, @sprintf("theta = %s = %g   %s", VV[:theta_str], VV[:theta], 
            VV[:theta_info]))
        push!(lines, @sprintf("theta = %g   %s", uconvert(u"deg/m", VV[:theta]), 
            VV[:theta_info]))
    end
    push!(lines, @sprintf("k = %s = %g   %s\n%s:  %s", VV[:bezpecnost_str], 
        VV[:bezpecnost], VV[:bezpecnost_info], VV[:verdict_info], VV[:verdict]))

    return join(lines, "\n")
end
