## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce hridel() slouží k výpočtu namáhání kroucením hřídele 
# a k vytvoření textového výstupu s popisem výpočtu.
# ver: 2026-03-27
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
    Fr=nothing, L1=nothing, L2=nothing,
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
    if druh == "nosný"
    if Fr !== nothing
        Fr = attach_unit(Fr, u"N")
        if Fr <= 0u"N"
            error("Fr musí být kladná hodnota.")
        end
    else
        error("Fr musí být číslo nebo Unitful.Quantity")
    end
    if L1 !== nothing
        L1 = attach_unit(L1, u"N")
        if L1 <= 0u"N"
            error("L1 musí být kladná hodnota.")
        end
    else
        error("L1 musí být číslo nebo Unitful.Quantity")
    end
    if L2 !== nothing
        L2 = attach_unit(L2, u"N")
        if L2 <= 0u"N"
            error("L2 musí být kladná hodnota.")
        end
    else
        error("L2 musí být číslo nebo Unitful.Quantity")
    end
    elseif druh == "hybný"
    if Mk !== nothing
        Mk = attach_unit(Mk, u"N*m")
        if Mk <= 0u"N*m"
            error("Mk musí být kladná hodnota.")
        end
    else
        error("Mk musí být číslo nebo Unitful.Quantity")
    end
    else
        error("Chybný druh hřídele.")
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
if druh == "nosný"
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
    F1 = nothing
    F2 = nothing
    if Fr !== nothing && L1 !== nothing && L2 !== nothing
        F1_str = "Fr*L2*(L1+L2)"
        F1 = Fr*L2*(L1+L2)
        F2_str = "Fr*L1*(L1+L2)"
        F2 = Fr*L1*(L1+L2)
    end
    vypocet=hridelhybnyvypocet(; Mk=Mk, profil1=profil1, L=L, mat=mat,
        tauDk=tauDk, G=G, Re=Re, zatizeni=zatizeni, k_uziv=k_uziv)
elseif druh == "hybný"
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
    vypocet=hridelhybnyvypocet(; Mk=Mk, profil1=profil1, L=L, mat=mat,
        tauDk=tauDk, G=G, Re=Re, zatizeni=zatizeni, k_uziv=k_uziv)
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
    VV[:k] = k_uziv
    VV[:k_info] = "Uživatelský požadavek bezpečnosti"
    VV[:Wk] = vypocet[:Wk] # průřezový modul v krutu
    VV[:Wk_info] = "Průřezový modul v krutu"
    VV[:Wk_str] = vypocet[:Wk_str] # textový popis Wk (např. z profilu)
    VV[:Ip] = vypocet[:Ip] # polární moment setrvačnosti
    VV[:Ip_info] = "Polární moment setrvačnosti"
    VV[:Ip_str] = vypocet[:Ip_str] # textový popis Ip (např. z profilu)
    VV[:tauDk] = vypocet[:tauDk]
    VV[:tauDk_info] = "Dovolené napětí v krutu"
    VV[:tau] = vypocet[:tau] # smykové napětí v krutu
    VV[:tau_str] = vypocet[:tau_str] # vzorec pro výpočet tau
    VV[:tau_info] = "Napětí v krutu"
    VV[:phi] = vypocet[:phi] # úhel zkroucení
    VV[:phi_str] = vypocet[:phi_str] # vzorec pro výpočet phi
    VV[:phi_info] = "Úhel zkroucení"
    VV[:bezpecnost] = vypocet[:k] # součinitel bezpečnosti
    VV[:bezpecnost_str] = vypocet[:k_str] # vzorec pro výpočet součinitele bezpečnosti
    VV[:bezpecnost_info] = "Součinitel bezpečnosti"
    VV[:verdict] =  vypocet[:verdict] # textové hodnocení bezpečnosti spoje
    VV[:verdict_info] = "Bezpečnost součásti"
    VV[:G] = vypocet[:G] # smykový modul
    VV[:G_info] = "Smykový modul"
    VV[:Re] = vypocet[:Re] # mez kluzu
    VV[:Re_info] = "Mez kluzu"
    VV[:mat] = mat # materiál
    VV[:mat_info] = "Materiál"
    VV[:L0] = L # délka pro výpočet úhlu zkroucení
    VV[:L0_info] = "Délka hřídele"
    VV[:theta] = vypocet[:theta] # poměrné zkroucení
    VV[:theta_str] = vypocet[:theta_str] # vzorec pro výpočet poměrného zkroucení
    VV[:theta_info] = "Poměrné zkroucení"
    #VV[:profil] = profil === nothing ? "" : profil
    VV[:profil_info] = profil1info # další info o profilu

    if return_text
        Dispstr = StrojniSoucasti.hrideltext(VV)
        return VV, Dispstr
    else
        return VV
    end

end # konec funkce

function hridelhybnyvypocet(; Mk=nothing, profil1=nothing, L=nothing, mat=nothing,
    tauDk=nothing, G=nothing, Re=nothing, zatizeni=nothing, k_uziv=nothing)

    VV1 = namahanikrut(Mk = Mk, profil = profil1, L0 = L, mat = mat, 
    tauDk=tauDk, G=G, Re=Re, zatizeni=zatizeni, k=k_uziv, return_text=false)
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
    k_str = VV1[:bezpecnost_str]
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
    vypocet = Dict{Symbol,Any}()
    vypocet[:tauDk] = tauDk
    vypocet[:G] = G
    vypocet[:Re] = Re
    vypocet[:k] = k
    vypocet[:k_str] = k_str
    vypocet[:verdict] = verdict # textové hodnocení bezpečnosti spoje
    vypocet[:Wk] = VV1[:Wk] # průřezový modul v krutu
    vypocet[:Wk_str] = VV1[:Wk_str] # textový popis Wk (např. z profilu)
    vypocet[:Ip] = VV1[:Ip] # polární moment setrvačnosti
    vypocet[:Ip_str] = VV1[:Ip_str] # textový popis Ip (např. z profilu)
    vypocet[:tau] = VV1[:tau] # smykové napětí v krutu
    vypocet[:tau_str] = VV1[:tau_str] # vzorec pro výpočet tau
    vypocet[:phi] = VV1[:phi] # úhel zkroucení
    vypocet[:phi_str] = VV1[:phi_str] # vzorec pro výpočet phi
    vypocet[:theta] = VV1[:theta] # poměrné zkroucení
    vypocet[:theta_str] = VV1[:theta_str] # vzorec pro výpočet poměrného zkroucení
    return vypocet

end
