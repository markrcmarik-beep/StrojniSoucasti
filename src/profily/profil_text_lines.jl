## Funkce Julia
###############################################################
## Popis funkce:
# Pomocná funkce pro výpis profil informací do textového výstupu.
# ver: 2026-02-28
## Funkce: profil_text_lines()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profil_text_lines.jl
#
## Vzor:
## vystupni_promenne = nazev_funkce(vstupni_promenne)
## Vstupní proměnné:
# VV::Dict{Symbol,Any} - slovník vstupních a výstupních proměnných.
## Výstupní proměnné:
# lines - textový výstup s informacemi o profilu.
## Použité balíčky:
# Printf: @sprintf
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
using Printf: @sprintf

function profil_text_lines(VV::Dict{Symbol,Any})
    lines = String[] # výpis informací o profilu
    if VV[:profil] != ""
        push!(lines, "profil: $(VV[:profil])") # název profilu
        selected_keys = [:a, :b, :D, :d, :t, :R] # běžné rozměry profilu
        for k in selected_keys # výpis rozměrů profilu
            if haskey(VV[:profil_info], k)
                v = VV[:profil_info][k] 
                if isa(v, Unitful.AbstractQuantity)
                    v2 = try uconvert(u"mm", v) catch v end
                    push!(lines, "  $(k) = $(v2)") # výpis rozměru s jednotkami převedenými na mm pro lepší čitelnost
                else
                    push!(lines, "  $(k) = $(v)") # výpis rozměru bez jednotek
                end
            end
        end
    else
        push!(lines, "profil:") # prázdný profil
    end
    return lines # návrat výpisu
end
