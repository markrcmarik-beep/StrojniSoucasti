## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet namáhání v krutu pro strojní součásti.
# ver: 2026-03-13
## Funkce: namahanikrut()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahanikrut.jl
#
## Vzor:
## vystupni_promenne = namahanikrut(vstupni_promenne)
## Vstupní proměnné:
# Mk - krouticí moment s jednotkou (N*m)
# Wk - průřezový modul v krutu s jednotkou (mm³)
# Ip - polární moment setrvačnosti s jednotkou (mm⁴), volitelný (pro výpočet úhlu zkroucení)
# tauDk - dovolené smykové napětí v krutu s jednotkou (MPa)
# G - smykový modul materiálu s jednotkou (GPa), volitelný (pro výpočet úhlu zkroucení)
# E - Youngův modul materiálu s jednotkou (GPa), volitelný (pokud není G zadáno)
# Re - mez kluzu materiálu s jednotkou (MPa), volitelný (pro výpočet tauDk)
# L0 - délka součásti pro výpočet úhlu zkroucení s jednotkou (mm), volitelný
# mat - materiál jako řetězec (název materiálu) nebo Dict s vlastnostmi materiálu, volitelný
# zatizeni - způsob zatížení jako řetězec: "statický", "pulzní", "dynamický", "rázový" (výchozí: "statický")
# profil - název profilu jako řetězec (pro získání Wk, Ip, S), volitelný
# return_text - Logická hodnota (Bool). Určuje, zda se má vrátit i
#     textový výpis výpočtu. Výchozí hodnota je true. Pokud je false,
#     vrací se pouze dict s výsledky.
## Výstupní proměnné:
# VV - slovník (Dict) s výsledky výpočtu
#   :info - Popis výpočtu
#   :zatizeni - Typ zatížení (statický, pulzní, dynamický, rázový)
#   :Mk - Kroutící moment
#   :Mk_info - Popis veličiny Mk
#   :Wk - Průřezový modul v krutu
#   :Wk_info - Popis veličiny Wk
#   :Wk_str - Textový popis Wk (z profilu)
#   :Ip - Polární moment setrvačnosti
#   :Ip_info - Popis veličiny Ip
#   :Ip_str - Textový popis Ip (z profilu)
#   :tauDk - Dovolené smykové napětí v krutu
#   :tauDk_info - Popis veličiny tauDk
#   :tau - Smykové napětí v krutu
#   :tau_str - Vzorec pro výpočet tau
#   :tau_info - Popis veličiny tau
#   :phi - Úhel zkroucení (pokud je L0 a Ip zadáno)
#   :phi_str - Vzorec pro výpočet phi
#   :phi_info - Popis veličiny phi
#   :bezpecnost - Součinitel bezpečnosti
#   :bezpecnost_str - Vzorec pro výpočet součinitele bezpečnosti
#   :bezpecnost_info - Popis veličiny bezpecnost
#   :verdict - Textové hodnocení bezpečnosti spoje
#   :verdict_info - Popis veličiny verdict
# txt - Volitelně i textový výpis výpočtu. Je-li parametr 
#   return_text=true (výchozí). Pokud return_text=false, vrací 
#   se pouze VV.
## Použité balíčky
# Unitful, Printf: @sprintf
## Použité uživatelské funkce:
# dovoleneNapeti(), tvarprofilu(), materialy()
## Příklad:
# Mk = 500.0 * u"N*m"
# Wk = 2000.0 * u"mm^3"
# tauDk = 100.0 * u"MPa"
# mat = "11 373"
# zatizeni = "statický"
# profil = "TR4HR 100x100x6"
# VV, txt = namahanikrut(Mk=Mk, Wk=Wk, tauDk=tauDk, mat=mat, zatizeni=zatizeni,
# profil=profil, return_text=true)
# println(VV) => Dict s výsledky
# println(txt) => textový výpis
###############################################################
## Použité proměnné vnitřní:
#
using Unitful

"""
    namahanikrut(; Mk, Wk=nothing, Ip=nothing, S=nothing, tauDk=nothing, G=nothing,
        Re=nothing, L0=nothing, mat=nothing, zatizeni::AbstractString="statický",
        profil=nothing, k=nothing, return_text::Bool=true)

Výpočet namáhání v krutu. Vrací slovník s výsledky a volitelně i textový výpis.

Vstupy:
- `Mk`: krouticí moment.
- `Wk`/`Ip`: průřezové charakteristiky (nebo `profil`).
- `tauDk`: dovolené smykové napětí (nebo `mat`/`Re`).
- `return_text`: pokud `true`, vrací i textový výpis.

Výstup:
- `Dict{Symbol,Any}` s výsledky, případně `(Dict, String)`.

Příklad:
```julia
namahanikrut(Mk=500u"N*m", profil="TR4HR 100x100x6", mat="S235")
```
"""
function namahanikrut(; Mk=nothing, Wk=nothing, Ip=nothing, 
    tauDk=nothing, G=nothing, Re=nothing, L0=nothing, 
    mat=nothing, zatizeni::AbstractString="statický",
    profil=nothing, k=nothing, return_text::Bool=true)
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
    if Mk !== nothing
        Mk = attach_unit(Mk, u"N*m") # převod na N*m
        if Mk <= 0u"N*m"
            error("Mk musí být kladná hodnota.")
        end
    else
        error("Mk musí být zadáno(N*m).")
    end
    if Wk !== nothing
        Wk = attach_unit(Wk, u"mm^3") # převod na mm^3
        if Wk <= 0u"mm^3"
            error("Wk musí být kladná hodnota.")
        end
    end
    if Ip !== nothing
        Ip = attach_unit(Ip, u"mm^4") # převod na mm^4
        if Ip <= 0u"mm^4"
            error("Ip musí být kladná hodnota.")
        end
    end
    if tauDk !== nothing
        tauDk = attach_unit(tauDk, u"MPa") # převod na MPa
        if tauDk <= 0u"MPa"
            error("tauDk musí být kladná hodnota.")
        end
    end
    if G !== nothing
        G = attach_unit(G, u"GPa") # převod na GPa
        if G <= 0u"GPa"
            error("G musí být kladná hodnota.")
        end
    end
    if Re !== nothing
        Re = attach_unit(Re, u"MPa") # převod na MPa
        if Re <= 0u"MPa"
            error("Re musí být kladná hodnota.")
        end
    end
    if L0 !== nothing
        L0 = attach_unit(L0, u"mm") # převod na mm
        if L0 <= 0u"mm"
            error("L0 musí být kladná hodnota.")
        end
    end
    if k_uziv !== nothing
        if !isnum(k_uziv)
            error("Chybně zadáno k: $k_uziv")
        elseif k_uziv <= 0
            error("k musí být kladná hodnota.")
        end
    end
    # ---------------------------------------------------------
    # materiál
    # ---------------------------------------------------------
    if mat !== nothing
        if mat isa AbstractString
            if !isdefined(@__MODULE__, :materialy)
                error("Funkce materialy(mat) není definována.")
            end
            matinfo = materialy(mat)
        else
            matinfo = mat
        end
        if matinfo === nothing
            error("Materiál '$mat' nebyl nalezen.")
        end
        if matinfo isa AbstractDict
            Re_raw = haskey(matinfo, :Re) ? matinfo[:Re] : get(matinfo, "Re", nothing)
            G_raw = haskey(matinfo, :G) ? matinfo[:G] : get(matinfo, "G", nothing)
            matName = haskey(matinfo, :name) ? matinfo[:name] : get(matinfo, "name", "")
        else
            Re_raw = hasproperty(matinfo, :Re) ? getproperty(matinfo, :Re) : nothing
            G_raw = hasproperty(matinfo, :G) ? getproperty(matinfo, :G) : nothing
            matName = hasproperty(matinfo, :name) ? getproperty(matinfo, :name) : ""
        end
        Re = Re_raw === nothing ? Re : attach_unit(Re_raw, u"MPa")
        G = G_raw === nothing ? G : attach_unit(G_raw, u"GPa")
     else
        matinfo = nothing
        matName = "" # prázdný řetězec, pokud není materiál zadán
    end
    # ---------------------------------------------------------
    # dovolené krutové napětí
    # ---------------------------------------------------------
    if tauDk === nothing
        if Re === nothing && mat === nothing
            error("Chybí tauDk, Re, mat - nelze stanovit dovolené napětí.")
        end
        if isdefined(@__MODULE__, :dovoleneNapeti)
            if matinfo !== nothing
                tauDk = dovoleneNapeti("střih", zatizeni; mat=matinfo)
            elseif Re !== nothing
                tauDk = dovoleneNapeti("střih", zatizeni; Re=Re)
            end
        else
            error("Funkce dovoleneNapeti není definována.")
        end
    end
    # ---------------------------------------------------------
    # profil
    # ---------------------------------------------------------
    if profil !== nothing && isdefined(@__MODULE__, :profily)
        tv = profily(profil)  # získání všech informací o profilu
        for k in keys(tv)
            if k ∉ (:S, :S_str) # vynecháme S a S_str, které zpracujeme zvlášť
                profil_info[k] = tv[k] # přidáme další informace z profilu do profil_info
            end
        end
    end
    Wk_str = ""
    if Wk === nothing
        if profil === nothing
            error("Chybí Wk a profil - nelze stanovit průřezový modul.")
        elseif !isdefined(@__MODULE__, :profily)
            error("Funkce profily není definována.")
        else
            tv = profily(profil, "Wk")  # získání Wk z profilu
            if !haskey(tv, :Wk)
                error("Profil $profil neobsahuje informaci o Wk.")
            end
            Wk = tv[:Wk] # převzetí Wk z profilu
            if haskey(tv, :Wk_str) # textový popis výpočtu Wk z profilu
                Wk_str = tv[:Wk_str] # převzetí textového popisu Wk z profilu
            end
        end
    end
    Ip_str = ""
    if Ip === nothing
        if profil !== nothing
            #error("Chybí Ip a profil - nelze stanovit polární moment setrvačnosti.")
            if !isdefined(@__MODULE__, :profily)
                error("Funkce profily není definována.")
            else
                tv = profily(profil, "Ip")  # získání Ip z profilu
                if !haskey(tv, :Ip)
                    error("Profil $profil neobsahuje informaci o Ip.")
                end
                Ip = tv[:Ip] # převzetí Ip z profilu
                if haskey(tv, :Ip_str) # textový popis výpočtu Ip z profilu
                    Ip_str = tv[:Ip_str] # převzetí textového popisu Ip z profilu
                end
            end
        end
    end
        # kontrola
    if Wk === nothing
        error("Chybí Wk (ani profil nebyl použit).")
    end
    # ---------------------------------------------------------
    # výpočet
    # ---------------------------------------------------------
    vypocet = namahanikrutvypocet(Mk=Mk, Wk=Wk, tauDk=tauDk, G=G, 
        L0=L0, Ip=Ip, k_uziv=k_uziv)
    # ---------------------------------------------------------
    # výstup
    # ---------------------------------------------------------
    VV = Dict{Symbol,Any}()
    VV[:info] = "namáhání v krutu"
    VV[:zatizeni] = zatizeni # způsob zatížení
    VV[:zatizeni_info] = "Způsob zatížení"
    VV[:Mk] = Mk # krouticí moment
    VV[:Mk_info] = "Krouticí moment"
    VV[:k] = k_uziv # uživatelský požadavek bezpečnosti
    VV[:k_info] = "Uživatelský požadavek bezpečnosti"
    VV[:Wk] = Wk # průřezový modul v krutu
    VV[:Wk_info] = "Průřezový modul v krutu"
    VV[:Wk_str] = Wk_str # textový popis Wk (např. z profilu)
    VV[:Ip] = Ip # polární moment setrvačnosti
    VV[:Ip_info] = "Polární moment setrvačnosti"
    VV[:Ip_str] = Ip_str # textový popis Ip (např. z profilu)
    VV[:tauDk] = tauDk # dovolené smykové napětí v krutu
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
    VV[:verdict_info] = "Bezpečnost spoje"
    VV[:G] = G # smykový modul
    VV[:G_info] = "Smykový modul"
    VV[:Re] = Re # mez kluzu
    VV[:Re_info] = "Mez kluzu"
    VV[:mat] = matName # materiál
    VV[:mat_info] = "Materiál"
    VV[:L0] = L0 # délka pro výpočet úhlu zkroucení
    VV[:L0_info] = "Délka pro výpočet zkroucení"
    VV[:theta] = vypocet[:theta] # poměrné zkroucení
    VV[:theta_str] = vypocet[:theta_str] # vzorec pro výpočet poměrného zkroucení
    VV[:theta_info] = "Poměrné zkroucení"
    VV[:profil] = profil === nothing ? "" : profil
    VV[:profil_info] = profil_info # další info o profilu

    if return_text
        Dispstr = StrojniSoucasti.namahanikruttext(VV)
        return VV, Dispstr
    else
        return VV
    end
end

function namahanikrutvypocet(; Mk=nothing, Wk=nothing, tauDk=nothing, 
    G=nothing, L0=nothing, Ip=nothing, k_uziv=nothing)

    tau_str = "Mk / Wk"
    tau = Mk / Wk
    tau = uconvert(u"MPa", tau)
    k_str = "tauDk / tau"
    k = tauDk / tau
    phi = nothing    # skutečný úhel zkroucení [rad]
    if L0 !== nothing && Ip !== nothing && G !== nothing
        phi_str = "(Mk * L0) / (G * Ip)"
        phi = (Mk * L0) / (G * Ip)
        phi = uconvert(u"rad", phi) # převod na radiany
    end
    theta = nothing  # poměrné zkroucení [rad/m]
    if Ip !==nothing && G !== nothing
        theta_str = "Mk / (G * Ip)"
        theta = Mk / (G * Ip)
        theta = uconvert(u"rad/m", theta) # převod na rad/m
    end
    if k_uziv === nothing
    verdict =   if k >= 1.5
                    "Spoj je bezpečný"
                elseif k >= 1.0
                    "Spoj je na hranici bezpečnosti"
                else
                    "Spoj není bezpečný!"
                end # konec if
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
    vypocet[:tau] = tau
    vypocet[:tau_str] = tau_str
    vypocet[:k] = k
    vypocet[:k_str] = k_str
    vypocet[:phi] = (phi)
    vypocet[:phi_str] = @isdefined(phi_str) ? phi_str : ""
    vypocet[:theta] = (theta)
    vypocet[:theta_str] = @isdefined(theta_str) ? theta_str : ""
    vypocet[:verdict] = verdict
    return vypocet

end
