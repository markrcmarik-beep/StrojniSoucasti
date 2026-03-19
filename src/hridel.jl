## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce hridel() slouží k vytvoření slovníku obsahujícího základní 
# parametry hřídele, jako jsou vnější průměr (D), vnitřní průměr (d), 
# délka (L) a materiál. Tato funkce je užitečná pro organizaci a 
# uchovávání informací o hřídeli, které mohou být následně použity 
# pro další výpočty nebo analýzy.
# ver: 2026-03-19
## Funkce: hridel()
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
    mat=nothing, tauDk=nothing, G=nothing, Re=nothing, k=nothing,
    zatizeni::AbstractString="statický", return_text=true)
    # ---------------------------------------------------------
    # pomocné
    # ---------------------------------------------------------
    k_uziv=k
    # ---------------------------------------------------------
    # vstupy – jednotky
    # ---------------------------------------------------------
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
        info = "hřídel"
        profil1info = "Hřídel s vnějším průměrem D=$D"
    elseif D !== nothing && d !== nothing
        t = (D - d) / 2
        profil1 = "TRKR $D x $t"
        info = "hřídel dutý"
        profil1info = "Dutý Hřídel s vnějším průměrem D=$D a vnitřním průměrem d=$d"
    else
        error("Nesprávné kombinace D a d. Musí být buď D nebo D a d.")
    end
    # ---------------------------------------------------------
    # výpočet
    # ---------------------------------------------------------
    VV1 = namahanikrut(Mk = Mk, profil = profil1, L0 = L, mat = mat, 
    tauDk=tauDk, G=G, Re=Re, zatizeni=zatizeni, k=k_uziv,
    return_text = false)
    if tauDk === nothing
        tauDk = VV1[:tauDk] # dovolené smykové napětí v krutu
    end
    if G === nothing
        G = VV1[:G] # smykový modul
    end
    if Re === nothing
        Re = VV1[:Re] # mez kluzu
    end
    # ---------------------------------------------------------
    # výstup
    # ---------------------------------------------------------
    VV = Dict{Symbol,Any}()
    VV[:info] = info
    VV[:zatizeni] = zatizeni # způsob zatížení
    VV[:zatizeni_info] = "Způsob zatížení"
    VV[:Mk] = Mk # krouticí moment
    VV[:Mk_info] = "Krouticí moment"
    VV[:D] = D # vnější průměr
    VV[:D_info] = "Vnější průměr hřídele"
    VV[:d] = d # vnitřní průměr
    VV[:d_info] = "Vnitřní průměr hřídele"
    VV[:k] = k_uziv # uživatelský požadavek bezpečnosti
    VV[:k_info] = "Uživatelský požadavek bezpečnosti"
    VV[:Wk] = VV1[:Wk] # průřezový modul v krutu
    VV[:Wk_info] = "Průřezový modul v krutu"
    VV[:Wk_str] = VV1[:Wk_str] # textový popis Wk (např. z profilu)
    VV[:Ip] = VV1[:Ip] # polární moment setrvačnosti
    VV[:Ip_info] = "Polární moment setrvačnosti"
    VV[:Ip_str] = VV1[:Ip_str] # textový popis Ip (např. z profilu)
    VV[:tauDk] = tauDk
    VV[:tauDk_info] = "Dovolené napětí v krutu"
    VV[:tau] = VV1[:tau] # smykové napětí v krutu
    VV[:tau_str] = VV1[:tau_str] # vzorec pro výpočet tau
    VV[:tau_info] = "Napětí v krutu"
    VV[:phi] = VV1[:phi] # úhel zkroucení
    VV[:phi_str] = VV1[:phi_str] # vzorec pro výpočet phi
    VV[:phi_info] = "Úhel zkroucení"
    VV[:bezpecnost] = VV1[:k] # součinitel bezpečnosti
    VV[:bezpecnost_str] = VV1[:k_str] # vzorec pro výpočet součinitele bezpečnosti
    VV[:bezpecnost_info] = "Součinitel bezpečnosti"
    VV[:verdict] =  VV1[:verdict] # textové hodnocení bezpečnosti spoje
    VV[:verdict_info] = "Bezpečnost spoje"
    VV[:G] = G # smykový modul
    VV[:G_info] = "Smykový modul"
    VV[:Re] = Re # mez kluzu
    VV[:Re_info] = "Mez kluzu"
    VV[:mat] = mat # materiál
    VV[:mat_info] = "Materiál"
    VV[:L0] = L # délka pro výpočet úhlu zkroucení
    VV[:L0_info] = "Délka pro výpočet zkroucení"
    VV[:theta] = VV1[:theta] # poměrné zkroucení
    VV[:theta_str] = VV1[:theta_str] # vzorec pro výpočet poměrného zkroucení
    VV[:theta_info] = "Poměrné zkroucení"
    #VV[:profil] = profil === nothing ? "" : profil
    VV[:profil_info] = profil1info # další info o profilu

    if return_text
        Dispstr = StrojniSoucasti.hrideltext(VV)
        return VV, Dispstr
    else
        return VV
    end
end