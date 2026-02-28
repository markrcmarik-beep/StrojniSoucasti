## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet namáhání ve smyku pro strojní součásti. Generování 
# textového výpisu výpočtu.
# ver: 2026-02-28
## Funkce: namahanistrihtext()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahanistrihtext.jl
#
## Vzor:
## vystupni_promenne = namahanistrihtext(vstupni_promenne)
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

function namahanistrihtext(VV::Dict{Symbol,Any})
    lines = String[] # pole pro textový výstup
    push!(lines,"Výpočet $(VV[:info])") # název výpočtu z VV[:info]
    push!(lines,"--------------------------------------------------------------")
    push!(lines, "materiál: $(VV[:mat] === nothing ? "" : string(VV[:mat]))")
    append!(lines, profil_text_lines(VV)) # přidáme informace o profilu do textového výstupu
    push!(lines,"zatížení: $(VV[:zatizeni])") # přidáme informace o zatížení do textového výstupu
    push!(lines,"--------------------------------------------------------------")
    push!(lines,"zadání:") # přidáme informace o zadání výpočtu
    push!(lines,@sprintf("F = %g   %s",VV[:F],VV[:F_info]))
    if VV[:k] !== nothing
        push!(lines, @sprintf("k = %g   %s", VV[:k], VV[:k_info]))
    end
    if VV[:S_text] != ""
        push!(lines,@sprintf("S = %s = %g   %s",VV[:S_text],VV[:S], 
            VV[:S_info]))
    else
        push!(lines,@sprintf("S = %g   %s",VV[:S],VV[:S_info]))
    end
    if VV[:Re] !== nothing
        push!(lines,@sprintf("Re = %g   %s",VV[:Re],VV[:Re_info]))
    end
    if VV[:G] !== nothing
        push!(lines,@sprintf("G = %g   %s",VV[:G],VV[:G_info]))
    end
    push!(lines,@sprintf("tauDs = %g   %s",VV[:tauDs],VV[:tauDs_info]))
    push!(lines,"--------------------------------------------------------------")
    push!(lines,"výpočet:")
    push!(lines,@sprintf("tau = %s = %g   %s",VV[:tau_str],VV[:tau],VV[:tau_info]))
    if VV[:gamma] !== nothing
        push!(lines,@sprintf("gamma = %s = %g   %s",VV[:gamma_str],VV[:gamma],VV[:gamma_info]))
    end
    k = VV[:bezpecnost]
    push!(lines, @sprintf("k = %s = %g   %s\n%s:  %s", VV[:bezpecnost_str], ustrip(k), 
        VV[:bezpecnost_info], VV[:verdict_info], VV[:verdict]))

    return join(lines,"\n")
end
