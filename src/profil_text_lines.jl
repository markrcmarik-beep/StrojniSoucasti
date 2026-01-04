## Funkce Julia
###############################################################
## Popis funkce:
# Pomocná funkce pro výpis profil informací
# ver: 2026-01-03
## Funkce: nazev_funkce()
#
## Vzor:
## vystupni_promenne = nazev_funkce(vstupni_promenne)
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
                    push!(lines, "  $(k) = $(v2)")
                else
                    push!(lines, "  $(k) = $(v)")
                end
            end
        end
    else
        push!(lines, "profil:") # prázdný profil
    end
    return lines # návrat výpisu
end