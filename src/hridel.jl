## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce hridel() slouží k vytvoření slovníku obsahujícího základní 
# parametry hřídele, jako jsou vnější průměr (D), vnitřní průměr (d), 
# délka (L) a materiál. Tato funkce je užitečná pro organizaci a 
# uchovávání informací o hřídeli, které mohou být následně použity 
# pro další výpočty nebo analýzy.
# ver: 2026-03-18
## Funkce: nazev_funkce()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/hridel.jl
#
## Vzor:
## vystupni_promenne = hridel(vstupni_promenne)
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
function hridel(; Mk=nothing, D=nothing, d=nothing, L=nothing, material=nothing)

    if D === nothing || d === nothing || L === nothing || material === nothing
        error("All parameters (D, d, L, material) must be provided.")
    end
    if Mk !== nothing
        Mk = attach_unit(Mk, u"N*m")
        if Mk <= 0u"N*m"
            error("Mk musí být kladná hodnota.")
        end
    else
        error("mk musí být číslo nebo Unitful.Quantity")
    end
    
    return Dict("D" => D, "d" => d, "L" => L, "material" => material)

end