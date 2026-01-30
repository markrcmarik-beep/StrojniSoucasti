## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet namáhání tahem pro strojní součásti. Generování 
# textového výpisu výpočtu.
# ver: 2025-12-29
## Funkce: namahanitahtext()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahanitahtext.jl
#
## Vzor:
## vystupni_promenne = namahanitahtext(vstupni_promenne)
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

function namahanitahtext(VV::Dict{Symbol,Any})
    lines = String[]
    push!(lines, "Výpočet $(VV[:info])")
    push!(lines, "--------------------------------------------------------------")
    push!(lines, "materiál: $(VV[:mat] === nothing ? "" : string(VV[:mat]))")
    append!(lines, profil_text_lines(VV))
    push!(lines, "zatížení: $(VV[:zatizeni])")
    push!(lines, "--------------------------------------------------------------")
    push!(lines, "zadání:")
    if VV[:F] !== nothing # zatěžující síla
        push!(lines, @sprintf("F = %g   %s", VV[:F], VV[:F_info]))
    end
    if VV[:k] !== nothing
        push!(lines, @sprintf("k = %g   %s", VV[:k], VV[:k_info]))
    end
    if VV[:S] !== nothing # plocha průřezu
        if VV[:S_text] != ""
            push!(lines, @sprintf("S = %s = %g   %s", VV[:S_text], VV[:S], VV[:S_info]))
        else
            push!(lines, @sprintf("S = %g   %s", VV[:S], VV[:S_info]))
        end
    end
    if VV[:sigmaDt] !== nothing # dovolené napětí
        push!(lines, @sprintf("sigmaDt = %g   %s", VV[:sigmaDt], VV[:sigmaDt_info]))
    end
    if VV[:L0] !== nothing # počáteční délka
        push!(lines, @sprintf("L0 = %g   %s", VV[:L0], VV[:L0_info]))
    end
    if VV[:Re] !== nothing # mez kluzu
        push!(lines, @sprintf("Re = %g   %s", VV[:Re], VV[:Re_info]))
    end
    if VV[:E] !== nothing # Youngův modul
        push!(lines, @sprintf("E = %g   %s", VV[:E], VV[:E_info]))
    end
    push!(lines, "--------------------------------------------------------------")
    push!(lines, "výpočet:")
    push!(lines, @sprintf("sigma = %s = %g   %s", VV[:sigma_str],VV[:sigma], VV[:sigma_info]))
    if VV[:epsilon] !== nothing # poměrné prodloužení
        push!(lines, @sprintf("epsilon = %s = %g %%   %s",
            VV[:epsilon_str], VV[:epsilon]*100, VV[:epsilon_info]))
    end
    if VV[:deltaL] !== nothing # skutečné prodloužení
        push!(lines, @sprintf("deltaL = %s = %g   %s",
            VV[:deltaL_str], VV[:deltaL], VV[:deltaL_info]))
    end
    if VV[:L] !== nothing # délka po deformaci
        push!(lines, @sprintf("L = %s = %g   %s", VV[:L_str], VV[:L], VV[:L_info]))
    end
    k = VV[:bezpecnost] # součinitel bezpečnosti
    push!(lines, @sprintf("k = %s = %g   %s\n%s:  %s", VV[:bezpecnost_str], 
        ustrip(k), VV[:bezpecnost_info], VV[:verdict_info], VV[:verdict]))

    return join(lines, "\n")
end
