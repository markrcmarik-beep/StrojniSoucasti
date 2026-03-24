## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet namáhání tlakem pro strojní součásti. Generování 
# textového výpisu výpočtu.
# ver: 2026-02-28
## Funkce: namahanitlaktext()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahanitlaktext.jl
#
## Vzor:
## vystupni_promenne = namahanitlaktext(vstupni_promenne)
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

function namahanitlaktext(VV::Dict{Symbol,Any})
    lines = String[] # pole pro textový výstup
    push!(lines, "Výpočet $(VV[:info])") # název výpočtu z VV[:info]
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "materiál: $(VV[:mat] === nothing ? "" : string(VV[:mat]))")
    append!(lines, profil_text_lines(VV)) # přidáme informace o profilu do textového výstupu
    push!(lines, "zatížení: $(VV[:zatizeni])") # přidáme informace o zatížení do textového výstupu
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "zadání:") # přidáme informace o zadání výpočtu
    if VV[:F] !== nothing
        push!(lines, @sprintf("F = %g   %s", VV[:F], VV[:F_info]))
    end
    if VV[:k] !== nothing
        push!(lines, @sprintf("k = %g   %s", VV[:k], VV[:k_info]))
    end
    if VV[:kp] !== nothing
        push!(lines, @sprintf("kp = %g   %s", VV[:kp], VV[:kp_info]))
    end
    if VV[:S] !== nothing
        if VV[:S_str] != ""
            push!(lines, @sprintf("S = %s = %g   %s", VV[:S_str], VV[:S], VV[:S_info]))
        else
            push!(lines, @sprintf("S = %g   %s", VV[:S], VV[:S_info]))
        end
    end
    if VV[:sigmaDt] !== nothing
        push!(lines, @sprintf("sigmaDt = %g   %s", VV[:sigmaDt], VV[:sigmaDt_info]))
    end
    if VV[:L0] !== nothing
        push!(lines, @sprintf("L0 = %g   %s", VV[:L0], VV[:L0_info]))
    end
    if VV[:Re] !== nothing
        push!(lines, @sprintf("Re = %g   %s", VV[:Re], VV[:Re_info]))
    end
    if VV[:E] !== nothing
        push!(lines, @sprintf("E = %g   %s", VV[:E], VV[:E_info]))
    end
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "výpočet:")
    push!(lines, @sprintf("sigma = %s = %g   %s", VV[:sigma_str], VV[:sigma], VV[:sigma_info]))
    if VV[:epsilon] !== nothing
        push!(lines, @sprintf("epsilon = %s = %g %%   %s", 
            VV[:epsilon_str], VV[:epsilon]*100, VV[:epsilon_info]))
    end
    if VV[:deltaL] !== nothing
        push!(lines, @sprintf("deltaL = %s = %g   %s", VV[:deltaL_str], VV[:deltaL], 
            VV[:deltaL_info]))
    end
    if VV[:L] !== nothing
        push!(lines, @sprintf("L = %s = %g   %s", VV[:L_str], VV[:L], VV[:L_info]))
    end
    if VV[:Nkr] !== nothing
        push!(lines, @sprintf("Nkr = %s = %g   %s", VV[:Nkr_str], VV[:Nkr], VV[:Nkr_info]))
    end
    k = VV[:bezpecnost]
    push!(lines, @sprintf("k = %s = %g   %s\n%s: %s", VV[:bezpecnost_str], ustrip(k), 
        VV[:bezpecnost_info], VV[:verdict_info], VV[:verdict]))
    
    return join(lines, "\n")
end
