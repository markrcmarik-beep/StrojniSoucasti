## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet namáhání v tlaku pro strojní součásti. Funkce umožňuje 
# zadat zatěžující sílu, plochu průřezu nebo profil, dovolené 
# napětí nebo materiál, délku namáhaného profilu a typ zatížení. 
# Vrací slovník s výsledky výpočtu a volitelně i textový výpis.
# ver: 2026-03-24
## Funkce: namahanitlak()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahanitlak.jl
#
## Vzor:
## vystupni_promenne = namahanitlak(vstupni_promenne)
## Vstupní proměnné:
# F - Zatěžující síla (Number nebo Unitful.Quantity s jednotkou síly,
#     např. N, kN). Povinné.
# S - Plocha průřezu (Number nebo Unitful.Quantity s jednotkou plochy,
#     např. mm^2, cm^2). Povinné, pokud není zadán parametr profil.
# sigmaDt - Dovolené napětí v tlaku (Number nebo Unitful.Quantity s
#     jednotkou tlaku, např. MPa, GPa). Povinné, pokud není zadán
#     parametr mat nebo Re.
# E - Modul pružnosti v tlaku, Youngův modul (Number nebo
#     Unitful.Quantity s jednotkou tlaku, např. GPa, MPa). Volitelné,
#     výchozí hodnota je 210 GPa.
# Re - Mez kluzu (Number nebo Unitful.Quantity s jednotkou tlaku,
#     např. MPa, GPa). Volitelné, pokud není zadán parametr mat.
# L0 - Délka namáhaného profilu (Number nebo Unitful.Quantity s jednotkou délky,
#     např. mm, m). Volitelné.
# Imin - Minimální kvadratický moment průřezu pro výpočet stability v tlaku
#     (Number nebo Unitful.Quantity s jednotkou mm^4). Má přednost před 
#     parametrem profil. (Volitelné)
# mat - Materiál (String s názvem materiálu nebo Dict s vlastnostmi
#     materiálu, např. Dict(:Re => 235MPa, :E => 210GPa)). Volitelné,
#     pokud není zadán parametr sigmaDt nebo Re.
# zatizeni - Typ zatížení (String: "statický", "dynamický", "rázový").
#     Výchozí hodnota je "statický".
# profil - Tvar profilu (String s názvem profilu, např. "PLO 20x10").
#     Volitelné, pokud není zadán parametr S.
# return_text - Logická hodnota (Bool). Určuje, zda se má vrátit i
#     textový výpis výpočtu. Výchozí hodnota je true. Pokud je false,
#     vrací se pouze dict s výsledky.
## Výstupní proměnné:
# VV - Dict s výsledky výpočtu namáhání v tlaku. Pole VV obsahují:
#   :info - Popis výpočtu
#   :zatizeni - Typ zatížení (statický, dynamický, rázový)
#   :F - Zatěžující síla (Unitful.Quantity)
#   :F_info - Popis pole F
#   :S - Plocha průřezu (Unitful.Quantity)
#   :S_str - Textový popis výpočtu S (je-li k dispozici)
#   :S_info - Popis pole S
#   :sigmaDt - Dovolené napětí v tlaku (Unitful.Quantity)
#   :sigmaDt_info - Popis pole sigmaDt
#   :sigma - Skutečné napětí v tlaku (Unitful.Quantity v MPa)
#   :sigma_info - Popis pole sigma
#   :epsilon - Poměrné zkrácení (bez jednotky)
#   :epsilon_info - Popis pole epsilon
#   :bezpecnost - Součinitel bezpečnosti k (bez jednotky)
#   :bezpecnost_info - Popis pole bezpecnost
#   :verdict - Závěr o bezpečnosti spoje (řetězec)
#   :verdict_info - Popis pole verdict
#   :E - Modul pružnosti v tlaku, Youngův modul (Unitful.Quantity)
#   :E_info - Popis pole E
#   :Re - Mez kluzu (Unitful.Quantity)
#   :Re_info - Popis pole Re
#   :mat - Materiál (řetězec)
#   :mat_info - Popis pole mat
#   :L0 - Délka namáhaného profilu (Unitful.Quantity)
#   :L0_info - Popis pole L0
#   :deltaL - Skutečné prodloužení (Unitful.Quantity), je-li spočítané
#   :deltaL_info - Popis pole deltaL
#   :L - Délka po prodloužení (Unitful.Quantity), je-li spočítané
#   :L_info - Popis pole L
#   :profil - Tvar profilu (řetězec), jestli byl zadaný
#   :profil_info - Popis pole profil
# txt - Volitelně i textový výpis výpočtu. Je-li parametr 
#   return_text=true (výchozí). Pokud return_text=false, vrací 
#   se pouze VV.
## Použité balíčky
# Unitful, Printf: @sprintf
## Použité uživatelské funkce:
# materialy, dovoleneNapeti, profily
## Příklad:
# namahanitlak(F=1000u"N", S=50u"mm^2", mat="11373")
#  vrátí dict s výsledky a textový výpis výpočtu
# println(VV) => dict s výsledky výpočtu
# println(txt) => textový výpis výpočtu
# namahanitlak(F=2000, S=100, sigmaDt=150u"MPa", E=200u"GPa", L0=500u"mm", 
#   zatizeni="statický", profil="PLO 20x10")
#  vrátí dict s výsledky a textový výpis výpočtu
# println(VV) => dict s výsledky výpočtu
# println(txt) => textový výpis výpočtu
###############################################################
## Použité proměnné vnitřní:
#
using Unitful

"""
    namahanitlak(; F, S=nothing, sigmaDt=nothing, E=nothing, Re=nothing, L0=nothing,
        mat=nothing, zatizeni::AbstractString="statický", profil=nothing,
        k=nothing, return_text::Bool=true)

Výpočet namáhání v tlaku. Vrací slovník s výsledky a volitelně i textový výpis.

Vstupy:
- `F`: zatěžující síla.
- `S`: plocha průřezu (nebo `profil`).
- `sigmaDt`: dovolené napětí (nebo `mat`).
- `mat`: materiál pro určení `Re`/`E`.
- `return_text`: pokud `true`, vrací i textový výpis.

Výstup:
- `Dict{Symbol,Any}` s výsledky, případně `(Dict, String)`.

Příklad:
```julia
namahanitlak(F=1000u"N", S=50u"mm^2", mat="S235")
```
"""
function namahanitlak(; F=nothing, S=nothing, sigmaDt=nothing, 
    E=nothing, Re=nothing, L0=nothing, Imin=nothing, mat=nothing,
    zatizeni::AbstractString="statický", profil=nothing,
    k=nothing, kp=nothing, return_text::Bool=true)
    # ---------------------------------------------------------
    # pomocné
    # ---------------------------------------------------------
    k_uziv=k
    hasq(x) = x !== nothing && isa(x, Unitful.AbstractQuantity)
    isnum(x) = x !== nothing && isa(x, Number)
    attach_unit(x, u) = hasq(x) ? x : x * u
    profil_info = Dict{Symbol,Any}()
    # ---------------------------------------------------------
    # vstupy – jednotky
    # ---------------------------------------------------------
    if F !== nothing
        F = attach_unit(F, u"N")
        if F <= 0u"N"
            error("F musí být kladná hodnota.")
        end
    else # F je povinné
        error("F musí být číslo nebo Unitful.Quantity")
    end
    if S !== nothing
        S = attach_unit(S, u"mm^2")
        if S <= 0u"mm^2"
            error("S musí být kladná hodnota.")
        end
    end
    if sigmaDt !== nothing
        sigmaDt = attach_unit(sigmaDt, u"MPa")
        if sigmaDt <= 0u"MPa"
            error("sigmaDt musí být kladná hodnota.")
        end
    end
    if Re !== nothing
        Re = attach_unit(Re, u"MPa")
        if Re <= 0u"MPa"
            error("Re musí být kladná hodnota.")
        end
    end
    if E !== nothing
        E = attach_unit(E, u"GPa")
        if E <= 0u"GPa"
            error("E musí být kladná hodnota.")
        end
    end
    if L0 !== nothing
        L0 = attach_unit(L0, u"mm")
        if L0 <= 0u"mm"
            error("L0 musí být kladná hodnota.")
        end
    end
    if Imin !== nothing
        Imin = attach_unit(Imin, u"mm^4")
        if Imin <= 0u"mm^4"
            error("Imin musí být kladná hodnota.")
        end
    end
    if k_uziv !== nothing
        if !isnum(k_uziv)
            error("Chybně zadáno k: $k_uziv")
        elseif k_uziv <= 0
            error("k musí být kladné číslo.")
        end
    end
    # ---------------------------------------------------------
    # materiál
    # ---------------------------------------------------------
    if mat !== nothing # pokud je mat zadán, pokusíme se získat informace o materiálu
        if mat isa AbstractString # pokud je mat řetězec, pokusíme se získat informace o materiálu pomocí funkce materialy(mat)
            if !isdefined(@__MODULE__, :materialy)
                error("Funkce materialy(mat) není definována.")
            end
            matinfo = materialy(mat)
        else # pokud je mat již dict nebo struct s potřebnými informacemi, použijeme ho přímo a nebudeme volat materialy(mat)
            matinfo = mat
        end
        if matinfo === nothing
            error("Materiál '$mat' nebyl nalezen.")
        end
        if matinfo isa AbstractDict # pokud je matinfo dict, získáme hodnoty z dictu s použitím haskey a get, abychom se vyhnuli chybám při přístupu k neexistujícím klíčům
            Re_raw = haskey(matinfo, :Re) ? matinfo[:Re] : get(matinfo, "Re", nothing)
            E_raw = haskey(matinfo, :E) ? matinfo[:E] : get(matinfo, "E", nothing)
            matName = haskey(matinfo, :name) ? matinfo[:name] : get(matinfo, "name", "")
        else # pokud je matinfo struct, získáme hodnoty z vlastností struct pomocí hasproperty a getproperty, abychom se vyhnuli chybám při přístupu k neexistujícím vlastnostem
            Re_raw = hasproperty(matinfo, :Re) ? getproperty(matinfo, :Re) : nothing
            E_raw = hasproperty(matinfo, :E) ? getproperty(matinfo, :E) : nothing
            matName = hasproperty(matinfo, :name) ? getproperty(matinfo, :name) : ""
        end
        Re = Re_raw === nothing ? Re : attach_unit(Re_raw, u"MPa")
        E = E_raw === nothing ? E : attach_unit(E_raw, u"GPa")
    else # pokud není mat zadán, nemáme informace o materiálu
        matinfo = nothing
        matName = "" # prázdný řetězec, pokud není materiál zadán
    end
    # ---------------------------------------------------------
    # dovolené tlakové napětí
    # ---------------------------------------------------------
    if sigmaDt === nothing
        if Re === nothing && mat === nothing
            error("Chybí sigmaDt, Re,  mat - nelze stanovit dovolené napětí.")
        end
        if isdefined(@__MODULE__, :dovoleneNapeti)
            if matinfo !== nothing
                sigmaDt = dovoleneNapeti("tlak", zatizeni; mat=matinfo)
            elseif Re !== nothing
                sigmaDt = dovoleneNapeti("tlak", zatizeni; Re=Re)
            end
        else
            error("Funkce dovoleneNapeti není definována.")
        end
    end
    # ---------------------------------------------------------
    # profil (automatické volání profily(profil, "S"))
    # ---------------------------------------------------------
    if profil !== nothing && isdefined(@__MODULE__, :profily)
        tv = profily(profil)  # získání všech informací o profilu
        for k in keys(tv)
            if k ∉ (:S, :S_str) # vynecháme S a S_str, které zpracujeme zvlášť
                profil_info[k] = tv[k] # přidáme další informace z profilu do profil_info
            end
        end
    end
    S_str = ""
    if S === nothing
        if profil === nothing
            error("Chybí S nebo profil - nelze stanovit plochu průřezu.")
        elseif !isdefined(@__MODULE__, :profily)
            error("Funkce profily(profil, \"S\") není definována.")
        else
            tv = profily(profil, "S")  # získání plochy průřezu z profilu
            if !haskey(tv, :S)
                error("Funkce profily(...) nevrací :S ani po zadání \"S\".")
            end
            S = tv[:S] # plocha průřezu pro výpočet napětí
            if haskey(tv, :S_str) # textový popis výpočtu S z profilu
                S_str = tv[:S_str]
            end
        end
    end
    Imin_str = ""
    if Imin === nothing
        if profil !== nothing
    #        error("Chybí Imin nebo profil - nelze stanovit minimální kvadratický moment.")
            if !isdefined(@__MODULE__, :profily)
                error("Funkce profily(profil, \"Imin\") není definována.")
            else
                tv = profily(profil, "Imin")  # vynucení výpočtu Imin
                if !haskey(tv, :Imin)
                    error("Funkce profily(...) nevrací :Imin ani po zadání \"Imin\".")
                end
                Imin = tv[:Imin] # minimální kvadratický moment průřezu pro výpočet stability v tlaku
                if haskey(tv, :Imin_str)
                    Imin_str = tv[:Imin_str]
                end
            end
        end
    end
    # kontrola
    if S === nothing
        error("Chybí S (ani profil nebyl použit).")
    end
    if sigmaDt === nothing
        error("Chybí sigmaDt (nezadáno sigmaDt ani mat/Re).")
    else
        sigmaDt = uconvert(u"MPa", sigmaDt)
    end
    if L0 !== nothing && E === nothing
        error("Pro vypocet zkraceni (L0) je nutne zadat i E.")
    end
    # ---------------------------------------------------------
    # výpočet
    # ---------------------------------------------------------
    V2 = namahanitlakvypocet(F=F, S=S, sigmaDt=sigmaDt, E=E, Re=Re, 
        L0=L0, Imin=Imin, kp=kp, k_uziv=k_uziv)
    # ---------------------------------------------------------
    # VÝSTUPNÍ DICT
    # ---------------------------------------------------------
    VV = Dict{Symbol,Any}()
    VV[:info] = "namáhání v tlaku"
    VV[:zatizeni] = zatizeni
    VV[:F] = F # zatěžující síla
    VV[:F_info] = "Zatěžující síla"
    VV[:k] = k_uziv # uživatelský požadavek bezpečnosti
    VV[:k_info] = "Uživatelský požadavek bezpečnosti"
    VV[:kp] = kp
    VV[:kp_info] = "druh"
    VV[:S] = S # plocha průřezu
    VV[:S_str] = S_str # textový popis výpočtu S (např. z profilu)
    VV[:S_info] = "Plocha průřezu"
    VV[:sigmaDt] = sigmaDt # dovolené napětí v tlaku
    VV[:sigmaDt_info] = "Dovolené napětí v tlaku"
    VV[:sigma] = V2[:sigma] # skutečné napětí v tlaku
    VV[:sigma_str] = V2[:sigma_str] # textový popis výpočtu sigma (např. z F a S)
    VV[:sigma_info] = "Napětí v tlaku"
    VV[:epsilon] = V2[:epsilon] # poměrné zkrácení (bez jednotky)
    VV[:epsilon_str] = V2[:epsilon_str] # textový popis výpočtu epsilon (např. z sigma a E)
    VV[:epsilon_info] = "Poměrné zkrácení"
    VV[:bezpecnost] = V2[:k] # součinitel bezpečnosti k
    VV[:bezpecnost_str] = V2[:k_str] # textový popis výpočtu k
    VV[:bezpecnost_info] = "Součinitel bezpečnosti"
    VV[:verdict] = V2[:verdict] # závěr o bezpečnosti spoje
    VV[:verdict_info] = "Bezpečnost spoje"
    VV[:E] = E # Youngův modul
    VV[:E_info] = "Youngův modul (tlak)"
    VV[:Re] = Re # mez kluzu
    VV[:Re_info] = "Mez kluzu"
    VV[:mat] = matName # název materiálu z dictu
    VV[:mat_info] = "Materiál"
    VV[:L0] = L0 # délka namáhaného profilu
    VV[:L0_info] = "Délka namáhaného profilu"
    VV[:Imin] = Imin # minimální kvadratický moment průřezu pro výpočet stability v tlaku
    VV[:Imin_str] = Imin_str # textový popis výpočtu Imin (např. z profilu)
    VV[:Imin_info] = "Minimální kvadratický moment průřezu pro výpočet stability v tlaku"
    VV[:deltaL] = V2[:deltaL] # skutečné zkrácení
    VV[:deltaL_str] = V2[:deltaL_str] # textový popis výpočtu deltaL (např. z epsilon a L0)
    VV[:deltaL_info] = "Skutečné zkrácení"
    VV[:Nkr] = V2[:Nkr]
    VV[:Nkr_str] = V2[:Nkr_str]
    VV[:Nkr_info] = "Kritická síla"
    VV[:L] = V2[:L] # délka po zkrácení
    VV[:L_str] = V2[:L_str] # textový popis výpočtu L (např. z L0 a deltaL)
    VV[:L_info] = "Délka po deformaci"
    VV[:profil] = profil === nothing ? "" : profil
    VV[:profil_info] = profil_info

    if return_text
        Dispstr = StrojniSoucasti.namahanitlaktext(VV)
        return VV, Dispstr
    else
        return VV
    end
end

function namahanitlakvypocet(; F=nothing, S=nothing, sigmaDt=nothing, 
    E=nothing, Re=nothing, L0=nothing, Imin=nothing, k_uziv=nothing,
    kp=nothing)
#kp=1 # první případ
sigma_str = "F / S"
sigma = F / S
sigma = uconvert(u"MPa", sigma)
k_str = "sigmaDt / sigma"
k = sigmaDt / sigma
epsilon = nothing
if E !== nothing
    epsilon_str = "sigma / E"
    epsilon = sigma / E  # poměrné zkrácení (kladné)
    epsilon = ustrip(epsilon)  # bez jednotky
end
# deltaL a L (zkrácení: záporné deltaL)
deltaL = nothing
L = nothing
if L0 !== nothing
    deltaL_str = "-epsilon * L0"
    deltaL = -epsilon * L0    # zkrácení materiálu v tlaku (mm)
    deltaL = uconvert(u"mm", deltaL)
    L_str = "L0 + deltaL"
    L = L0 + deltaL
    L = uconvert(u"mm", L)
end
# kritická síla
Nkr = nothing
if Imin !== nothing && L0 !== nothing && E !== nothing && kp !== nothing
    #al = kp * pi / 2
    Nkr_str = "kp^2*pi^2*E*Imin/(4*L0^2)"
    Nkr = kp^2*pi^2*E*Imin/(4*L0^2)
    Nkr = uconvert(u"mm", Nkr)
end
if k_uziv === nothing
    verdict =   if k >= 1.5
                    "Spoj je bezpečný"
                elseif k >= 1.0
                    "Spoj je na hranici bezpečnosti"
                else
                    "Spoj není bezpečný!"
                end
else
    verdict =   if k >= k_uziv + 0.5
                    "Spoj je bezpečný"
                elseif k >= k_uziv
                    "Spoj je na hranici bezpečnosti"
                else
                    "Spoj není bezpečný!"
                end # konec if
end

vypocet = Dict{Symbol,Any}()
vypocet[:sigma_str] = sigma_str
vypocet[:sigma] = sigma
vypocet[:Nkr] = Nkr
vypocet[:Nkr_str] = @isdefined(Nkr_str) ? Nkr_str : ""
vypocet[:k_str] = k_str
vypocet[:k] = k
vypocet[:epsilon_str] = @isdefined(epsilon_str) ? epsilon_str : ""
vypocet[:epsilon] = epsilon
vypocet[:deltaL_str] = @isdefined(deltaL_str) ? deltaL_str : ""
vypocet[:deltaL] = deltaL
vypocet[:L_str] = @isdefined(L_str) ? L_str : ""
vypocet[:L] = L
vypocet[:verdict] = verdict
return vypocet

end