## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce hridel() slouží k výpočtu namáhání kroucením hřídele 
# a k vytvoření textového výstupu s popisem výpočtu.
# ver: 2026-03-25
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
using Unitful

function hridel(; Mk=nothing, D=nothing, d=nothing, L=nothing, 
    mat=nothing, tauDk=nothing, G=nothing, Re=nothing, k=nothing,
    zatizeni::AbstractString="statický", druh="hybný", return_text=true)
    # ---------------------------------------------------------
    # pomocné
    # ---------------------------------------------------------
    k_uziv = k
    hasq(x) = x !== nothing && isa(x, Unitful.AbstractQuantity)
    attach_unit(x, u) = hasq(x) ? x : x * u
    # ---------------------------------------------------------
    # vstupy – jednotky
    # ---------------------------------------------------------
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
        if d >= D
            error("d musí být menší než D.")
        end
    end
    if L !== nothing
        L = attach_unit(L, u"mm")
        if L <= 0u"mm"
            error("L musí být kladná hodnota.")
        end
    end
    if tauDk !== nothing
        tauDk = attach_unit(tauDk, u"MPa")
        if tauDk <= 0u"MPa"
            error("tauDk musí být kladná hodnota.")
        end
    end
    if G !== nothing
        G = attach_unit(G, u"GPa")
        if G <= 0u"GPa"
            error("G musí být kladná hodnota.")
        end
    end
    if Re !== nothing
        Re = attach_unit(Re, u"MPa")
        if Re <= 0u"MPa"
            error("Re musí být kladná hodnota.")
        end
    end
    if k !== nothing
        if k <= 0
            error("k musí být kladná bezrozměrná hodnota.")
        end
    end
    # ---------------------------------------------------------
    # profil
    # ---------------------------------------------------------
    if D !== nothing && d === nothing
        D_mm = ustrip(u"mm", D)
        profil1 = "KR $(D_mm)"
        info = "hřídel"
        profil1info = "Hřídel s vnějším průměrem D=$D"
    elseif D !== nothing && d !== nothing
        t = (D - d) / 2
        D_mm = ustrip(u"mm", D)
        t_mm = ustrip(u"mm", t)
        profil1 = "TRKR $(D_mm)x$(t_mm)"
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
    k = VV1[:bezpecnost]
    if k_uziv === nothing
    verdict =   if k >= 1.5
                    "Hřídel je bezpečný"
                elseif k >= 1.0
                    "Hřídel je na hranici bezpečnosti"
                else
                    "Hřídel není bezpečný!"
                end # konec if
    else
        verdict =   if k >= k_uziv + 0.5
                        "Hřídel je bezpečný"
                    elseif k >= k_uziv
                        "Hřídel je na hranici bezpečnosti"
                    else
                        "Hřídel není bezpečný!"
                    end # konec if
    end
    # ---------------------------------------------------------
    # výstup
    # ---------------------------------------------------------
    VV = Dict{Symbol,Any}()
    VV[:info] = info
    VV[:zatizeni] = zatizeni # způsob zatížení
    VV[:zatizeni_info] = "Způsob zatížení"
    VV[:druh] = druh # druh hřídele dle zatížení
    VV[:druh_info] = "druh hřídele"
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
    VV[:bezpecnost] = VV1[:bezpecnost] # součinitel bezpečnosti
    VV[:bezpecnost_str] = VV1[:bezpecnost_str] # vzorec pro výpočet součinitele bezpečnosti
    VV[:bezpecnost_info] = "Součinitel bezpečnosti"
    VV[:verdict] =  verdict # textové hodnocení bezpečnosti spoje
    VV[:verdict_info] = "Bezpečnost součásti"
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
