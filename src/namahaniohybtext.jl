## Funkce Julia
###############################################################
## Popis funkce:
#
# ver: 2025-12-29
## Funkce: namahaniohybtext()
#
## Vzor:
## vystupni_promenne = namahaniohybtext(vstupni_promenne)
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
    if VV[:k] !== nothing
        push!(lines, @sprintf("k = %g   %s", VV[:k], VV[:k_info]))
    end
    if VV[:natoceni] !== nothing
        push!(lines, @sprintf("natočení = %g   %s", VV[:natoceni], VV[:natoceni_info]))
    end
    push!(lines, @sprintf("Wo = %g   %s", VV[:Wo], VV[:Wo_info]))
    if VV[:Ix] !== nothing
        push!(lines, @sprintf("Ix = %g   %s", VV[:Ix], VV[:Ix_info]))
    end
    if VV[:Re] !== nothing
        push!(lines, @sprintf("Re = %g   %s", VV[:Re], VV[:Re_info]))
    end
    if VV[:E] !== nothing
        push!(lines, @sprintf("E = %g   %s", VV[:E], VV[:E_info]))
    end
    if VV[:Lo] !== nothing
        push!(lines, @sprintf("Lo = %g   %s", VV[:Lo], VV[:Lo_info]))
    end
    push!(lines, @sprintf("sigmaDo = %g   %s", VV[:sigmaDo], VV[:sigmaDo_info]))
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "výpočet:")
    push!(lines, @sprintf("sigma = %s = %g   %s", VV[:sigma_str], VV[:sigma], 
        VV[:sigma_info]))
    if VV[:delta] !== nothing
        push!(lines, @sprintf("delta = %s = %g   %s", VV[:delta_str], VV[:delta], 
            VV[:delta_info]))
    end
    if VV[:y] !== nothing
        push!(lines, @sprintf("y = %s = %g   %s", VV[:y_str], VV[:y], VV[:y_info]))
    end
    if VV[:alfa] !== nothing
        push!(lines, @sprintf("alfa = %s = %g = %g   %s", VV[:alfa_str], VV[:alfa], 
            uconvert(u"deg", VV[:alfa]), VV[:alfa_info]))
    end
    push!(lines, @sprintf("k = %s = %g   %s\n%s: %s", VV[:bezpecnost_str],
        ustrip(VV[:bezpecnost]), VV[:bezpecnost_info], VV[:verdict_info], VV[:verdict]))

    return join(lines, "\n")
end