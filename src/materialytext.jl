## Funkce Julia
###############################################################
## Popis funkce:
#
# ver: 2026-01-01
## Funkce: materialytext()
#
## Vzor:
## vystupni_promenne = materialytext(vstupni_promenne)
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
using Printf: @sprintf

function materialytext(VV::Dict{Symbol,Any})
    lines = String[]
    # Hlavní nadpis - prioritně ČSN, jinak značka, jinak obecný text
    nazev = haskey(VV, :CSN) ? VV[:CSN] : (haskey(VV, :znacka) ? VV[:znacka] : "neznámý")
    push!(lines, "Materiál:")
    push!(lines, "--------------------------------------------------------------")
    # Kontrola a výpis identifikačních značení
    for (klic, label) in [(:CSN, "ČSN"), (:ISO, "ISO"), (:EN, "EN"), (:znacka, "Značka")]
        if haskey(VV, klic)
            hodnota = string(VV[klic])
            # Vypíše pouze pokud hodnota není prázdná nebo jen pomlčka
            if !isempty(strip(hodnota)) && hodnota != "-"
                push!(lines, "$label: $hodnota")
            end
        end
    end
    push!(lines, "--------------------------------------------------------------")
    # Volitelně: přidání mechanických vlastností pro přehlednost
    if haskey(VV, :Re) 
        push!(lines, @sprintf("Re =  %g   %s", VV[:Re], VV[:Re_info]))
    end # [cite: 1, 21]
    if haskey(VV, :Rm) 
        push!(lines, @sprintf("Rm =  %g   %s", VV[:Rm], VV[:Rm_info]))
    end  # [cite: 1, 2, 21]

    return join(lines, "\n")
end