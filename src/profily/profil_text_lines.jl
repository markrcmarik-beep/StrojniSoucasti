## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Pomocná funkce pro výpis profil informací do textového výstupu.
# ver: 2026-05-16
## Funkce: profil_text_lines()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profil_text_lines.jl
#
## Vzor:
## lines = profil_text_lines(VV)
## Vstupní proměnné:
# VV::Dict{Symbol,Any} - slovník vstupních a výstupních proměnných.
## Výstupní proměnné:
# lines - textový výstup s informacemi o profilu.
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
function _profil_number_text(v::Number)::String
    if isfinite(v) && isapprox(v, round(v); atol=1e-12, rtol=0.0)
        return string(Int(round(v)))
    end
    return string(v)
end

function _profil_quantity_mm_text(v)
    v2 = try uconvert(u"mm", v) catch v end
    n = Unitful.ustrip(v2)
    nstr = n isa Number ? _profil_number_text(n) : string(n)
    return nstr * " " * string(Unitful.unit(v2))
end

function profil_text_lines(VV::Dict{Symbol,Any})
    lines = String[] # výpis informací o profilu
    if VV[:profil] != ""
        push!(lines, "profil: $(VV[:profil])") # název profilu
        selected_keys = [:a, :b, :D, :d, :t, :t1, :t2, :h, :h1, :h2, :R, :R1, :R2, :n] # běžné rozměry profilu
        for k in selected_keys # výpis rozměrů profilu
            if haskey(VV[:profil_info], k)
                v = VV[:profil_info][k] 
                if isa(v, Unitful.AbstractQuantity)
                    push!(lines, "  $(k) = $(_profil_quantity_mm_text(v))") # výpis rozměru s jednotkami převedenými na mm bez zbytečných nul
                else
                    vtxt = v isa Number ? _profil_number_text(v) : string(v)
                    push!(lines, "  $(k) = $(vtxt)") # výpis rozměru bez zbytečných nul
                end
            end
        end
    else
        push!(lines, "profil:") # prázdný profil
    end
    return lines # návrat výpisu
end
