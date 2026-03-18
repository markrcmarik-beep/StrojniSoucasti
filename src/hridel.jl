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
function hridel(; Mk=nothing, D=nothing, d=nothing, L=nothing, 
    mat=nothing, tauDk=nothing, G=nothing, Re=nothing,
    zatizeni::AbstractString="statický", return_text=true)

    if D === nothing || d === nothing || L === nothing || mat === nothing
        error("All parameters (D, d, L, material) must be provided.")
    end
    if Mk !== nothing
        Mk = attach_unit(Mk, u"N*m")
        if Mk <= 0u"N*m"
            error("Mk musí být kladná hodnota.")
        end
    else
        error("Mk musí být číslo nebo Unitful.Quantity")
    end
    if D !== nothing
        D = attach_unit(D, u"mm")
        if D <= 0u"mm"
            error("D musí být kladná hodnota.")
        end
    else
        error("D musí být číslo nebo Unitful.Quantity")
    end
    if d !== nothing
        d = attach_unit(d, u"mm")
        if d <= 0u"mm"
            error("d musí být kladná hodnota.")
        end
    end
    if L !== nothing
        L = attach_unit(L, u"mm")
        if L <= 0u"mm"
            error("L musí být kladná hodnota.")
        end
    end

    if D !== nothing && d === nothing
        profil1 = "TRKR $D"
    elseif D !== nothing && d !== nothing
        profil1 = "TRKR $Dxd"
    else
        error("Nesprávné kombinace D a d. Musí být buď D nebo D a d.")
    end

    VV = namahanikrut(Mk = Mk, profil = profil1, L0 = L, mat = mat, 
    zatizeni=zatizeni, return_text = false)
    
    return Dict("D" => D, "d" => d, "L" => L, "material" => mat)

end