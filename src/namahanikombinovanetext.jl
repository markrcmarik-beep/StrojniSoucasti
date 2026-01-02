## Funkce Julia
###############################################################
## Popis funkce:
#
# ver: 2026-01-02
## Funkce: namahannamahanikombinovanetextitahtext()
#
## Vzor:
## vystupni_promenne = namahanikombinovanetext(vstupni_promenne)
## Vstupní proměnné:
#
## Výstupní proměnné:
#
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
using Printf: @sprintf

function namahanikombinovanetext(VV::Dict{Symbol,Any})
    lines = String[]
    push!(lines, "Výpočet $(VV[:info])")
    push!(lines, "----------------------------------------------------------------")
    if haskey(VV, :tah) # napětí v tahu
        #push!(lines, "tah")
        push!(lines,StrojniSoucasti.namahanitahtext(VV[:tah]))
        push!(lines, "----------------------------------------------------------------")
    end
    if haskey(VV, :tlak) # napětí v tlaku
        #push!(lines, "tlak")
        push!(lines,StrojniSoucasti.namahanitlaktext(VV[:tlak]))
        push!(lines, "----------------------------------------------------------------")
    end
    if haskey(VV, :strih)
        #push!(lines, "strih")
        push!(lines, StrojniSoucasti.namahanistrihtext(VV[:strih]))
        push!(lines, "----------------------------------------------------------------")
    end
    if haskey(VV, :krut)
        #push!(lines, "krut")
        push!(lines, StrojniSoucasti.namahanikruttext(VV[:krut]))
        push!(lines, "----------------------------------------------------------------")
    end
    if haskey(VV, :ohyb)
        #push!(lines, "ohyb")
        push!(lines, StrojniSoucasti.namahaniohybtext(VV[:ohyb]))
        push!(lines, "----------------------------------------------------------------")
    end
    push!(lines, "kritérium: $(VV[:kriterium])")
    push!(lines, "zatížení:  $(VV[:zatizeni])")
    if haskey(VV, :k)
    if VV[:k] !== nothing
        push!(lines, @sprintf("k = %g   %s", VV[:k], VV[:k_info]))
    end
    end
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "napětí:  $(VV[:namahani])")
    if haskey(VV, :sigmat) # napětí v tahu
        push!(lines, @sprintf("sigmat = %g   %s", VV[:sigmat], VV[:sigmat_info]))
    end
    if haskey(VV, :sigmatl) # napětí v tlaku
        push!(lines, @sprintf("sigmatl = %g   %s", VV[:sigmatl], VV[:sigmatl_info]))
    end
    if haskey(VV, :taus) # napětí ve střihu
        push!(lines, @sprintf("taus = %g   %s", VV[:taus], VV[:taus_info]))
    end
    if haskey(VV, :tauk) # napětí v krutu
        push!(lines, @sprintf("tauk = %g   %s", VV[:tauk], VV[:tauk_info]))
    end
    if haskey(VV, :sigmao) # napětí v ohybu
        push!(lines, @sprintf("sigmao = %g   %s", VV[:sigmao], VV[:sigmao_info]))
    end
    push!(lines, "----------------------------------------------------------------")
    push!(lines, "kombinace: $(VV[:namahani])")
    push!(lines, @sprintf("sigma_eq = %s = %g   %s", VV[:sigma_eq_str],
        VV[:sigma_eq], VV[:sigma_eq_info]))
    push!(lines, @sprintf("sigmaD = %g   %s", VV[:sigmaD], VV[:sigmaD_info]))
    push!(lines, "----------------------------------------------------------------")
    push!(lines, @sprintf("k = %s = %g   %s\n%s: %s", VV[:bezpecnost_str], 
        VV[:bezpecnost], VV[:bezpecnost_info], VV[:verdict_info], VV[:verdict]))

    return join(lines, "\n")
end # konec funkce
