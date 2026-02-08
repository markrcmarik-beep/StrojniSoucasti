## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet namáhání v tahu pro strojní součásti.
# ver: 2026-01-22
## Funkce: namahanitah()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahanitah.jl
#
## Vzor:
## vystupni_promenne = namahanitah(vstupni_promenne)
## Vstupní proměnné:
# F - Zatěžující síla (Unitful.Quantity), povinné. Musí být v tahu (kladná hodnota).
# S - Plocha průřezu (Unitful.Quantity), povinné pokud není zadán profil
# sigmaDt - Dovolené napětí v tahu (Unitful.Quantity), povinné pokud není zadán mat
# E - Modul pružnosti v tahu, Youngův modul (Unitful.Quantity), volitelný, výchozí 210 GPa
# Re - Mez kluzu (Unitful.Quantity), volitelný, pokud je zadán mat
# L0 - Délka namáhaného profilu (Unitful.Quantity), volitelný
# mat - Materiál jako řetězec (název materiálu) nebo Dict s vlastnostmi materiálu, volitelný
# zatizeni - způsob zatížení jako řetězec: "statický", "pulzní", "dynamický", "rázový" (výchozí: "statický")
# profil - název profilu jako řetězec (pro získání S), volitelný
# return_text - Logická hodnota (Bool). Určuje, zda se má vrátit i
#     textový výpis výpočtu. Výchozí hodnota je true. Pokud je false,
#     vrací se pouze dict s výsledky.
## Výstupní proměnné:
# VV - Dict s výsledky výpočtu namáhání v tahu. Pole VV obsahují:
#   :info - Popis výpočtu
#   :zatizeni - Typ zatížení (statický, pulzní, dynamický, rázový)
#   :F - Zatěžující síla (Unitful.Quantity)
#   :F_info - Popis pole F
#   :S - Plocha průřezu (Unitful.Quantity)
#   :S_text - Textový popis výpočtu S (je-li k dispozici)
#   :S_info - Popis pole S
#   :sigmaDt - Dovolené napětí v tahu (Unitful.Quantity)
#   :sigmaDt_info - Popis pole sigmaDt
#   :sigma - Skutečné napětí v tahu (Unitful.Quantity v MPa)
#   :sigma_info - Popis pole sigma
#   :epsilon - Poměrné prodloužení (bez jednotky)
#   :epsilon_info - Popis pole epsilon
#   :bezpecnost - Součinitel bezpečnosti k (bez jednotky)
#   :bezpecnost_info - Popis pole bezpecnost
#   :verdict - Závěr o bezpečnosti spoje (řetězec)
#   :verdict_info - Popis pole verdict
#   :E - Modul pružnosti v tahu, Youngův modul (Unitful.Quantity)
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
# namahanitah(F=1000u"N", S=50u"mm^2", mat="11373")
#  vrátí dict s výsledky a textový výpis výpočtu
# println(VV) => dict s výsledky výpočtu
# println(txt) => textový výpis výpočtu
# namahanitah(F=2000, S=100, sigmaDt=150u"MPa", E=200u"GPa", L0=500u"mm", 
#   zatizeni="statický", profil="PLO 20x10")
#  vrátí dict s výsledky a textový výpis výpočtu
# println(VV) => dict s výsledky výpočtu
# println(txt) => textový výpis výpočtu
###############################################################
## Použité proměnné vnitřní:
#
using Unitful

"""
    namahanitah(; F, S=nothing, sigmaDt=nothing, E=nothing, Re=nothing, L0=nothing,
        mat=nothing, zatizeni::AbstractString="statický", profil=nothing,
        k=nothing, return_text::Bool=true)

Výpočet namáhání v tahu. Vrací slovník s výsledky a volitelně i textový výpis.

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
namahanitah(F=1000u"N", S=50u"mm^2", mat="S235")
```
"""
function namahanitah(; F=nothing, S=nothing, sigmaDt=nothing, 
    E=nothing, Re=nothing, L0=nothing, mat=nothing, 
    zatizeni::AbstractString="statický", profil=nothing, 
    k=nothing, return_text::Bool=true)
    # ---------------------------------------------------------
    # pomocné
    # ---------------------------------------------------------
    k_uziv=k
    hasq(x) = x !== nothing && isa(x, Unitful.AbstractQuantity)
    isnum(x) = x !== nothing && isa(x, Number)
    attach_unit(x, u) = hasq(x) ? x : x * u
    # kontroly duplicity S/profil
    cntS = (S !== nothing ? 1 : 0) + (profil !== nothing ? 1 : 0)
    if cntS > 1
        error("Zadejte pouze jednu hodnotu z: S nebo profil.")
    end
    if (sigmaDt !== nothing) && (mat !== nothing)
        error("Zadejte pouze sigmaDt nebo mat, ne obojí.")
    end
    # ---------------------------------------------------------
    # vstupy – jednotky
    # ---------------------------------------------------------
    if F !== nothing
        F = attach_unit(F, u"N")
    else
        error("F musí být číslo nebo Unitful.Quantity")
    end
    if S !== nothing
        S = attach_unit(S, u"mm^2")
    end
    if sigmaDt !== nothing
        sigmaDt = attach_unit(sigmaDt, u"MPa")
    end
    if Re !== nothing
        Re = attach_unit(Re, u"MPa")
    end
    if E !== nothing
        E = attach_unit(E, u"GPa")
    end
    if L0 !== nothing
        L0 = attach_unit(L0, u"mm")
    end
    if k_uziv !== nothing
        if !isnum(k_uziv)
            error("Chybně zadáno k: $k_uziv")
        end
    end
    # ---------------------------------------------------------
    # materiál
    # ---------------------------------------------------------
    if mat !== nothing
        if !isdefined(Main, :materialy)
            error("Funkce materialy(mat) není definována.")
        end
        matinfo = materialy(mat)
        Re = (matinfo.Re)u"MPa" # mez kluzu
        E = (matinfo.E)u"GPa" # modul pružnosti
    end
    # ---------------------------------------------------------
    # dovolené napětí
    # ---------------------------------------------------------
    if sigmaDt === nothing
        if Re === nothing
            error("Chybí sigmaDt i Re - nelze stanovit dovolené napětí.")
        end
        if !isdefined(Main, :dovoleneNapeti)
            error("Funkce dovoleneNapeti není definována.")
        end
        sigmaDt = dovoleneNapeti(Re, "tah", zatizeni)
    end
    # ---------------------------------------------------------
    # profil (automatické volání profily(profil, "S"))
    # ---------------------------------------------------------
    S_text = ""
    profil_info = Dict{Symbol,Any}()
    if profil !== nothing
        if !isdefined(Main, :profily)
            error("Funkce profily(...) není definována.")
        end
        tv = profily(profil, "S")  # vynucení výpočtu S
        if !haskey(tv, :S)
            error("Funkce profily(...) nevrací :S ani po zadání \"S\".")
        end
        S = tv[:S]
        if haskey(tv, :S_str)
            S_text = tv[:S_str]
        end
        for k in keys(tv)
            if k ∉ (:S, :S_str)
                profil_info[k] = tv[k]
            end
        end
    end
    # kontrola F, S, sigmaDt
    if F === nothing
        error("Chybí F.")
    end
    if S === nothing
        error("Chybí S (ani profil nebyl použit).")
    end
    if sigmaDt === nothing
        error("Chybí sigmaDt (nezadáno sigmaDt ani mat/Re).")
    else
        sigmaDt = uconvert(u"MPa", sigmaDt)
    end
    # ---------------------------------------------------------
    # výpočet
    # ---------------------------------------------------------
    sigma_str = "F / S"
    sigma = F / S
    sigma = uconvert(u"MPa", sigma)
    k_str = "sigmaDt / sigma"
    k = sigmaDt / sigma
    epsilon = nothing
    if E !== nothing
        epsilon_str = "sigma / E"
        epsilon = sigma / E
        epsilon = ustrip(epsilon)  # bez jednotky
    end
    deltaL = nothing
    L = nothing
    if L0 !== nothing && epsilon !== nothing
        deltaL_str = "epsilon * L0"
        deltaL = epsilon * L0
        deltaL = uconvert(u"mm", deltaL)
        L_str = "L0 + deltaL"
        L = L0 + deltaL
        L = uconvert(u"mm", L)
    end
    if k_uziv === nothing
    verdict = if k >= 1.5
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
    # ---------------------------------------------------------
    # výstup
    # ---------------------------------------------------------
    VV = Dict{Symbol,Any}()
    VV[:info] = "namáhání v tahu"
    VV[:zatizeni] = zatizeni
    VV[:zatizeni_info] = "Druh zatížení"
    VV[:F] = F # zatěžující síla
    VV[:F_info] = "Zatěžující síla"
    VV[:k] = k_uziv # uživatelský požadavek bezpečnosti
    VV[:k_info] = "Uživatelský požadavek bezpečnosti"
    VV[:S] = S # plocha průřezu
    VV[:S_text] = S_text # textový popis výpočtu S
    VV[:S_info] = "Plocha průřezu"
    VV[:sigmaDt] = sigmaDt # dovolené napětí
    VV[:sigmaDt_info] = "Dovolené napětí"
    VV[:sigma] = sigma # skutečné napětí v tahu
    VV[:sigma_str] = sigma_str
    VV[:sigma_info] = "Skutečné napětí v tahu"
    VV[:epsilon] = epsilon # poměrné prodloužení
    VV[:epsilon_str] = @isdefined(epsilon_str) ? epsilon_str : ""
    VV[:epsilon_info] = "Poměrné prodloužení"
    VV[:bezpecnost] = k # součinitel bezpečnosti
    VV[:bezpecnost_str] = k_str
    VV[:bezpecnost_info] = "Součinitel bezpečnosti"
    VV[:verdict] = verdict
    VV[:verdict_info] = "Bezpečnost spoje"
    VV[:E] = E # Youngův modul
    VV[:E_info] = "Youngův modul"
    VV[:Re] = Re # mez kluzu
    VV[:Re_info] = "Mez kluzu"
    VV[:mat] = mat
    VV[:mat_info] = "Materiál"
    VV[:L0] = L0 # počáteční délka
    VV[:L0_info] = "Počáteční délka"
    VV[:deltaL] = deltaL # skutečné prodloužení
    VV[:deltaL_str] = @isdefined(deltaL_str) ? deltaL_str : ""
    VV[:deltaL_info] = deltaL === nothing ? "" : "Skutečné prodloužení"
    VV[:L] = L # délka po deformaci
    VV[:L_str] = @isdefined(L_str) ? L_str : ""
    VV[:L_info] = L === nothing ? "" : "Délka po deformaci"
    VV[:profil] = profil === nothing ? "" : profil
    VV[:profil_info] = profil_info
    if return_text
        Dispstr = StrojniSoucasti.namahanitahtext(VV)
        return VV, Dispstr
    else
        return VV
    end
end

"""
## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet namáhání v tahu pro strojní součásti.
# ver: 2026-01-22
## Funkce: namahanitah()
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahanitah.jl
#
## Vzor:
## vystupni_promenne = namahanitah(vstupni_promenne)
## Vstupní proměnné:
# F - Zatěžující síla (Unitful.Quantity), povinné. Musí být v tahu (kladná hodnota).
# S - Plocha průřezu (Unitful.Quantity), povinné pokud není zadán profil
# sigmaDt - Dovolené napětí v tahu (Unitful.Quantity), povinné pokud není zadán mat
# E - Modul pružnosti v tahu, Youngův modul (Unitful.Quantity), volitelný, výchozí 210 GPa
# Re - Mez kluzu (Unitful.Quantity), volitelný, pokud je zadán mat
# L0 - Délka namáhaného profilu (Unitful.Quantity), volitelný
# mat - Materiál jako řetězec (název materiálu) nebo Dict s vlastnostmi materiálu, volitelný
# zatizeni - způsob zatížení jako řetězec: "statický", "pulzní", "dynamický", "rázový" (výchozí: "statický")
# profil - název profilu jako řetězec (pro získání S), volitelný
# return_text - Logická hodnota (Bool). Určuje, zda se má vrátit i
#     textový výpis výpočtu. Výchozí hodnota je true. Pokud je false,
#     vrací se pouze dict s výsledky.
## Výstupní proměnné:
# VV - Dict s výsledky výpočtu namáhání v tahu. Pole VV obsahují:
#   :info - Popis výpočtu
#   :zatizeni - Typ zatížení (statický, pulzní, dynamický, rázový)
#   :F - Zatěžující síla (Unitful.Quantity)
#   :F_info - Popis pole F
#   :S - Plocha průřezu (Unitful.Quantity)
#   :S_text - Textový popis výpočtu S (je-li k dispozici)
#   :S_info - Popis pole S
#   :sigmaDt - Dovolené napětí v tahu (Unitful.Quantity)
#   :sigmaDt_info - Popis pole sigmaDt
#   :sigma - Skutečné napětí v tahu (Unitful.Quantity v MPa)
#   :sigma_info - Popis pole sigma
#   :epsilon - Poměrné prodloužení (bez jednotky)
#   :epsilon_info - Popis pole epsilon
#   :bezpecnost - Součinitel bezpečnosti k (bez jednotky)
#   :bezpecnost_info - Popis pole bezpecnost
#   :verdict - Závěr o bezpečnosti spoje (řetězec)
#   :verdict_info - Popis pole verdict
#   :E - Modul pružnosti v tahu, Youngův modul (Unitful.Quantity)
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
# namahanitah(F=1000u"N", S=50u"mm^2", mat="11373")
#  vrátí dict s výsledky a textový výpis výpočtu
# println(VV) => dict s výsledky výpočtu
# println(txt) => textový výpis výpočtu
# namahanitah(F=2000, S=100, sigmaDt=150u"MPa", E=200u"GPa", L0=500u"mm", 
#   zatizeni="statický", profil="PLO 20x10")
#  vrátí dict s výsledky a textový výpis výpočtu
# println(VV) => dict s výsledky výpočtu
# println(txt) => textový výpis výpočtu
###############################################################
## Použité proměnné vnitřní:
#
"""
