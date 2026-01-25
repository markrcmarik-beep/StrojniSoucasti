## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet kombinovaného namáhání (tah/střih + tlak/střih + 
# tah/krut + tlak/krut + ohyb/krut)
# pomocí HMH nebo Tresca kritéria. Funkce využívá výstupy
# z již existujících funkcí namáhání (namahanitah, namahanitlak,
# namahanistrih, namahanikrut, namahaniohyb).
# ver: 2026-01-02
## Funkce: namahanikombinovane()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahanikombinovane.jl
#
## Vzor:
## vystupni_promenne = namahanikombinovane(vstupni_promenne)
## Vstupní proměnné:
# vysledky - Vector{Dict} výstupů z dílčích funkcí namáhání
# kriterium - :HMH nebo :Tresca (výchozí :HMH)
# sigmaD - dovolené napětí (MPa), volitelné pokud je v datech Re
# return_text - vrátí i textový výpis (true/false)
## Výstupní proměnné:
# VV - Dict s výsledky kombinovaného namáhání
# txt - textový výpis (volitelně)
## Použité balíčky
# Unitful, Printf
## Použité uživatelské funkce:
# dovoleneNapeti(), namahanitah(), namahanitlak(), 
# namahanistrih(), namahanikrut(), namahaniohyb()
## Příklad:
# VVkomb, txtkomb = namahanikombinovane(vysledky = [VVtah, VVsmyk])
# println(VVkomb)
# println(txtkomb)
###############################################################
## Použité proměnné vnitřní:
#
using Unitful

function namahanikombinovane(; 
    vysledky::Vector{Dict{Symbol,Any}},
    kriterium::Symbol = :HMH, sigmaD = nothing,
    k=nothing, return_text::Bool = true)
    # ---------------------------------------------------------
    # pomocné
    # ---------------------------------------------------------
    k_uziv=k
    hasq(x) = x !== nothing && isa(x, Unitful.AbstractQuantity)
    isnum(x) = x !== nothing && isa(x, Number)
    attach_unit(x, u) = hasq(x) ? x : x * u
    # ---------------------------------------------------------
    # vstupy – jednotky
    # ---------------------------------------------------------
    if sigmaD !== nothing
        sigmaD = attach_unit(sigmaD, u"MPa") # převod na MPa
    end
    if k_uziv !== nothing
        if !isnum(k_uziv)
            error("Chybně zadáno uživatelské k: $k_uziv")
        end
    end
    # ---------------------------------------------------------
    # sběr napětí
    # ---------------------------------------------------------
    # -- tah-střih --
if ((vysledky[1][:info] == "namáhání v tahu" &&
    vysledky[2][:info] == "namáhání ve střihu") ||
    (vysledky[1][:info] == "namáhání ve střihu" && 
    vysledky[2][:info] == "namáhání v tahu"))
    namahanizkr = "tah-střih"
    namahani_info = "namáhání v tahu - střihu"
    if vysledky[1][:info] == "namáhání v tahu" # první je tah
        vsldkTah = vysledky[1]
        vsldkStrih = vysledky[2]
    elseif vysledky[1][:info] == "namáhání ve střihu" # první je smyk
        vsldkTah = vysledky[2]
        vsldkStrih = vysledky[1]
    end
    # -- tlak-střih --
elseif (vysledky[1][:info] == "namáhání v tlaku" && 
    vysledky[2][:info] == "namáhání ve střihu") ||
    (vysledky[1][:info] == "namáhání ve střihu" && 
    vysledky[2][:info] == "namáhání v tlaku")
    namahanizkr = "tlak-střih"
    namahani_info = "namáháni v tlaku - střihu"
    if vysledky[1][:info] == "namáhání v tlaku" # první je tlak
        vsldkTlak = vysledky[1]
        vsldkStrih = vysledky[2]
    elseif vysledky[1][:info] == "namáhání ve střihu" # první je smyk
        vsldkTlak = vysledky[2]
        vsldkStrih = vysledky[1]
    end
    # -- tah-krut --
elseif (vysledky[1][:info] == "namáhání v tahu" && 
    vysledky[2][:info] == "namáhání v krutu") ||
    (vysledky[1][:info] == "namáhání v krutu" && 
    vysledky[2][:info] == "namáhání v tahu")
    namahanizkr = "tah-krut"
    namahani_info = "namáhání v tahu - krutu"
    if vysledky[1][:info] == "namáhání v tahu" # první je tah
        vsldkTah = vysledky[1]
        vsldkKrut = vysledky[2]
    elseif vysledky[1][:info] == "namáhání v krutu" # první je krut
        vsldkTah = vysledky[2]
        vsldkKrut = vysledky[1]
    end
    # -- tlak-krut --
elseif (vysledky[1][:info] == "namáhání v tlaku" && 
    vysledky[2][:info] == "namáhání v krutu") ||
    (vysledky[1][:info] == "namáhání v krutu" && 
    vysledky[2][:info] == "namáhání v tlaku")
    namahanizkr = "tlak-krut"
    namahani_info = "namáhání v tlaku - krutu"
    if vysledky[1][:info] == "namáhání v tlaku" # první je tlak
        vsldkTlak = vysledky[1]
        vsldkKrut = vysledky[2]
    elseif vysledky[1][:info] == "namáhání v krutu" # první je krut
        vsldkTlak = vysledky[2]
        vsldkKrut = vysledky[1]
    end
    # -- tah-ohyb --
elseif (vysledky[1][:info] == "namáhání v tahu" && 
    vysledky[2][:info] == "namáhání v ohybu") ||
    (vysledky[1][:info] == "namáhání v ohybu" && 
    vysledky[2][:info] == "namáhání v tahu")
    namahanizkr = "tah-ohyb"
    namahani_info = "namáhání v tahu - ohybu"
    if vysledky[1][:info] == "namáhání v tahu" # první je tah
        vsldkTah = vysledky[1]
        vsldkOhyb = vysledky[2]
    elseif vysledky[1][:info] == "namáhání v ohybu" # první je ohyb
        vsldkTah = vysledky[2]
        vsldkOhyb = vysledky[1]
    end
    # -- tlak-ohyb --
elseif (vysledky[1][:info] == "namáhání v tlaku" && 
    vysledky[2][:info] == "namáhání v ohybu") ||
    (vysledky[1][:info] == "namáhání v ohybu" && 
    vysledky[2][:info] == "namáhání v tlaku")
    namahanizkr = "tlak-ohyb"
    namahani_info = "namáhání v tlaku - ohybu"
    if vysledky[1][:info] == "namáhání v tlaku" # první je tlak
        vsldkTlak = vysledky[1]
        vsldkOhyb = vysledky[2]
    elseif vysledky[1][:info] == "namáhání v ohybu" # první je ohyb
        vsldkTlak = vysledky[2]
        vsldkOhyb = vysledky[1]
    end
    # -- střih-krut --
elseif (vysledky[1][:info] == "namáhání ve střihu" && 
    vysledky[2][:info] == "namáhání v krutu") ||
    (vysledky[1][:info] == "namáhání v krutu" && 
    vysledky[2][:info] == "namáhání v střihu")
    namahanizkr = "střih-krut"
    namahani_info = "namáhání v střihu - krutu"
    if vysledky[1][:info] == "namáhání ve střihu" # první je tlak
        vsldkStrih = vysledky[1]
        vsldkKrut = vysledky[2]
    elseif vysledky[1][:info] == "namáhání v krutu" # první je krut
        vsldkStrih = vysledky[2]
        vsldkKrut = vysledky[1]
    end
    # -- střih-ohyb --
elseif (vysledky[1][:info] == "namáhání ve střihu" && 
    vysledky[2][:info] == "namáhání v ohybu") ||
    (vysledky[1][:info] == "namáhání v ohybu" && 
    vysledky[2][:info] == "namáhání ve střihu")
    namahanizkr = "střih-ohyb"
    namahani_info = "namáhání ve střihu - ohybu"
    if vysledky[1][:info] == "namáhání ve střihu" # první je střih
        vsldkStrih = vysledky[1]
        vsldkOhyb = vysledky[2]
    elseif vysledky[1][:info] == "namáhání v ohybu" # první je ohyb
        vsldkStrih = vysledky[2]
        vsldkOhyb = vysledky[1]
    end
    # -- krut-ohyb --
elseif (vysledky[1][:info] == "namáhání v krutu" && 
    vysledky[2][:info] == "namáhání v ohybu") ||
    (vysledky[1][:info] == "namáhání v ohybu" && 
    vysledky[2][:info] == "namáhání v krutu")
    namahanizkr = "krut-ohyb"
    namahani_info = "namáhání v krutu - ohybu"
    if vysledky[1][:info] == "namáhání v krutu" # první je krut
        vsldkKrut = vysledky[1]
        vsldkOhyb = vysledky[2]
    elseif vysledky[1][:info] == "namáhání v ohybu" # první je ohyb
        vsldkKrut = vysledky[2]
        vsldkOhyb = vysledky[1]
    end
else
    error("Kombinace namáhání $(vysledky[1][:info]) a 
        $(vysledky[2][:info]) není podporována.")
end
# ---------------------------------------------------------
# sběr napětí podle typu kombinace
# ---------------------------------------------------------
if namahanizkr == "tah-střih"
    sigmat = vsldkTah[:sigma]
    zatizenit = vsldkTah[:zatizeni]
    taus   = vsldkStrih[:tau]
    zatizenis = vsldkStrih[:zatizeni]
    zatizeni = ("$zatizenit-$zatizenis")
    if (haskey(vsldkTah, :Re) && vsldkTah[:Re] !== nothing) &&
       (haskey(vsldkStrih, :Re) && vsldkStrih[:Re] !== nothing)
        if vsldkTah[:Re] == vsldkStrih[:Re]
            Re = vsldkTah[:Re]
        else
            error("Hodnoty Re z namáhání $namahanizkr se liší. 
                tah: Re = $(vsldkTah[:Re]), střih: Re = $(vsldkStrih[:Re])")
        end
    end
elseif namahanizkr == "tlak-střih"
    sigmatl = vsldkTlak[:sigma]
    zatizenitl = vsldkTlak[:zatizeni]
    taus   = vsldkStrih[:tau]
    zatizenis = vsldkStrih[:zatizeni]
    zatizeni = ("$zatizenitl-$zatizenis")
    if (haskey(vsldkTlak, :Re) && vsldkTlak[:Re] !== nothing) &&
       (haskey(vsldkStrih, :Re) && vsldkStrih[:Re] !== nothing)
        if vsldkTlak[:Re] == vsldkStrih[:Re]
            Re = vsldkTlak[:Re]
        else
            error("Hodnoty Re z namáhání $namahanizkr se liší. 
                tlak: Re = $(vsldkTlak[:Re]), střih: Re = $(vsldkStrih[:Re])")
        end
    end
elseif namahanizkr == "tah-krut"
    sigmat = vsldkTah[:sigma]
    zatizenit = vsldkTah[:zatizeni]
    tauk   = vsldkKrut[:tau]
    zatizenik = vsldkKrut[:zatizeni]
    zatizeni = ("$zatizenit-$zatizenik")
    if (haskey(vsldkTah, :Re) && vsldkTah[:Re] !== nothing) &&
       (haskey(vsldkKrut, :Re) && vsldkKrut[:Re] !== nothing)
        if vsldkTah[:Re] == vsldkKrut[:Re]
            Re = vsldkTah[:Re]
        else
            error("Hodnoty Re z namáhání $namahanizkr se liší. 
                tah: Re = $(vsldkTah[:Re]), krut: Re = $(vsldkKrut[:Re])")
        end
    end
elseif namahanizkr == "tlak-krut"
    sigmatl = vsldkTlak[:sigma]
    zatizenitl = vsldkTlak[:zatizeni]
    tauk   = vsldkKrut[:tau]
    zatizenik = vsldkKrut[:zatizeni]
    zatizeni = ("$zatizenitl-$zatizenik")
    if (haskey(vsldkTlak, :Re) && vsldkTlak[:Re] !== nothing) &&
       (haskey(vsldkKrut, :Re) && vsldkKrut[:Re] !== nothing)
        if vsldkTlak[:Re] == vsldkKrut[:Re]
            Re = vsldkTlak[:Re]
        else
            error("Hodnoty Re z namáhání $namahanizkr se liší. 
                tlak: Re = $(vsldkTlak[:Re]), krut: Re = $(vsldkKrut[:Re])")
        end
    end
elseif namahanizkr == "tah-ohyb"
    sigmat = vsldkTah[:sigma]
    zatizenit = vsldkTah[:zatizeni]
    sigmao   = vsldkOhyb[:sigma]
    zatizenio = vsldkOhyb[:zatizeni]
    zatizeni = ("$zatizenit-$zatizenio")
    if (haskey(vsldkTah, :Re) && vsldkTah[:Re] !== nothing) &&
       (haskey(vsldkOhyb, :Re) && vsldkOhyb[:Re] !== nothing)
        if vsldkTah[:Re] == vsldkOhyb[:Re]
            Re = vsldkTah[:Re]
        else
            error("Hodnoty Re z namáhání $namahanizkr se liší. 
                tah: Re = $(vsldkTah[:Re]), ohyb: Re = $(vsldkOhyb[:Re])")
        end
    end
elseif namahanizkr == "tlak-ohyb"
    sigmatl = vsldkTlak[:sigma]
    zatizenitl = vsldkTlak[:zatizeni]
    sigmao   = vsldkOhyb[:sigma]
    zatizenio = vsldkOhyb[:zatizeni]
    zatizeni = ("$zatizenitl-$zatizenio")
    if (haskey(vsldkTlak, :Re) && vsldkTlak[:Re] !== nothing) &&
       (haskey(vsldkOhyb, :Re) && vsldkOhyb[:Re] !== nothing)
        if vsldkTlak[:Re] == vsldkOhyb[:Re]
            Re = vsldkTlak[:Re]
        else
            error("Hodnoty Re z namáhání $namahanizkr se liší. 
                tlak: Re = $(vsldkTlak[:Re]), ohyb: Re = $(vsldkOhyb[:Re])")
        end
    end
elseif namahanizkr == "střih-krut"
    taus = vsldkStrih[:tau]
    zatizenis = vsldkStrih[:zatizeni]
    tauk   = vsldkKrut[:tau]
    zatizenik = vsldkKrut[:zatizeni]
    zatizeni = ("$zatizenis-$zatizenik")
    if (haskey(vsldkStrih, :Re) && vsldkStrih[:Re] !== nothing) &&
       (haskey(vsldkKrut, :Re) && vsldkKrut[:Re] !== nothing)
        if vsldkStrih[:Re] == vsldkKrut[:Re]
            Re = vsldkStrih[:Re]
        else
            error("Hodnoty Re z namáhání $namahanizkr se liší. 
                střih: Re = $(vsldkStrih[:Re]), krut: Re = $(vsldkKrut[:Re])")
        end
    end
elseif namahanizkr == "střih-ohyb"
    taus = vsldkStrih[:tau]
    zatizenis = vsldkStrih[:zatizeni]
    sigmao   = vsldkOhyb[:sigma]
    zatizenio = vsldkOhyb[:zatizeni]
    zatizeni = ("$zatizenis-$zatizenio")
    if (haskey(vsldkStrih, :Re) && vsldkStrih[:Re] !== nothing) &&
       (haskey(vsldkOhyb, :Re) && vsldkOhyb[:Re] !== nothing)
        if vsldkStrih[:Re] == vsldkOhyb[:Re]
            Re = vsldkStrih[:Re]
        else
            error("Hodnoty Re z namáhání $namahanizkr se liší. 
                střih: Re = $(vsldkStrih[:Re]), ohyb: Re = $(vsldkOhyb[:Re])")
        end
    end
elseif namahanizkr == "krut-ohyb"
    tauk = vsldkKrut[:tau]
    zatizenik = vsldkKrut[:zatizeni]
    sigmao   = vsldkOhyb[:sigma]
    zatizenio = vsldkOhyb[:zatizeni]
    zatizeni = ("$zatizenik-$zatizenio")
    if (haskey(vsldkKrut, :Re) && vsldkKrut[:Re] !== nothing) &&
       (haskey(vsldkOhyb, :Re) && vsldkOhyb[:Re] !== nothing)
        if vsldkKrut[:Re] == vsldkOhyb[:Re]
            Re = vsldkKrut[:Re]
        else
            error("Hodnoty Re z namáhání $namahanizkr se liší. 
                krut: Re = $(vsldkKrut[:Re]), ohyb: Re = $(vsldkOhyb[:Re])")
        end
    end
else
    error("Kombinace $namahanizkr není implementována.")
end
# ---------------------------------------------------------
# dovolené napětí
# ---------------------------------------------------------
if sigmaD === nothing
    if Re === nothing
        error("Chybí sigmaD i Re - nelze stanovit bezpečnost.")
    end
    if !isdefined(Main, :dovoleneNapeti)
        error("Funkce dovoleneNapeti není definována.")
    end
    sigmaD = dovoleneNapeti(Re, namahanizkr, zatizeni)
end
if sigmaD !== nothing
    sigmaD = uconvert(u"MPa", sigmaD)
else
    error("Nenalezeno dovolené napětí: sigmaD = $sigmaD")
end
# ---------------------------------------------------------
# ekvivalentní napětí
# ---------------------------------------------------------
if namahanizkr == "tah-střih"
    sigmat = uconvert(u"MPa",sigmat)
    taus   = uconvert(u"MPa",taus)
    if kriterium === :HMH
        sigma_eq_str = "sqrt(sigmat^2 + 3*taus^2)"
        sigma_eq = sqrt(sigmat^2 + 3*taus^2)
    elseif kriterium === :Tresca
        sigma_eq_str = "sqrt(sigmat^2 + 4*taus^2)"
        sigma_eq = sqrt(sigmat^2 + 4*taus^2)
    else
        error("Neznámé kriterium: $kriterium")
    end
elseif namahanizkr == "tlak-střih"
    sigmatl = uconvert(u"MPa",sigmatl)
    taus   = uconvert(u"MPa",taus)
    if kriterium === :HMH
        sigma_eq_str = "sqrt(sigmatl^2 + 3*taus^2)"
        sigma_eq = sqrt(sigmatl^2 + 3*taus^2)
    elseif kriterium === :Tresca
        sigma_eq_str = "sqrt(sigmatl^2 + 4*taus^2)"
        sigma_eq = sqrt(sigmatl^2 + 4*taus^2)
    else
        error("Neznámé kriterium: $kriterium")
    end
elseif namahanizkr == "tah-krut"
    sigmat = uconvert(u"MPa",sigmat)
    tauk   = uconvert(u"MPa",tauk)
    if kriterium === :HMH
        sigma_eq_str = "sqrt(sigmat^2 + 3*tauk^2)"
        sigma_eq = sqrt(sigmat^2 + 3*tauk^2)
    elseif kriterium === :Tresca
        sigma_eq_str = "sqrt(sigmat^2 + 4*tauk^2)"
        sigma_eq = sqrt(sigmat^2 + 4*tauk^2)
    else
        error("Neznámé kriterium: $kriterium")
    end
elseif namahanizkr == "tlak-krut"
    sigmatl = uconvert(u"MPa",sigmatl)
    tauk   = uconvert(u"MPa",tauk)
    if kriterium === :HMH
        sigma_eq_str = "sqrt(sigmatl^2 + 3*tauk^2)"
        sigma_eq = sqrt(sigmatl^2 + 3*tauk^2)
    elseif kriterium === :Tresca
        sigma_eq_str = "sqrt(sigmatl^2 + 4*tauk^2)"
        sigma_eq = sqrt(sigmatl^2 + 4*tauk^2)
    else
        error("Neznámé kriterium: $kriterium")
    end
elseif namahanizkr == "tah-ohyb"
    sigmat = uconvert(u"MPa",sigmat)
    sigmao = uconvert(u"MPa",sigmao)
    if kriterium === :HMH
        sigma_eq_str = "sqrt(sigmat^2 - sigmat*sigmao + sigmao^2)"
        sigma_eq = sqrt(sigmat^2 - sigmat*sigmao + sigmao^2)
    else
        sigma_eq_str = "max(|sigmat|, |sigmao|, |sigmat - sigmao|)"
        sigma_eq = maximum(abs.([sigmat, sigmao, sigmat - sigmao]))
    end
elseif namahanizkr == "tlak-ohyb"
    sigmatl = uconvert(u"MPa",sigmatl)
    sigmao = uconvert(u"MPa",sigmao)
    if kriterium === :HMH
        sigma_eq_str = "sqrt(sigmatl^2 - sigmatl*sigmao + sigmao^2)"
        sigma_eq = sqrt(sigmatl^2 - sigmatl*sigmao + sigmao^2)
    elseif kriterium === :Tresca
        sigma_eq_str = "max(|sigmatl|, |sigmao|, |sigmatl - sigmao|)"
        sigma_eq = maximum(abs.([sigmatl, sigmao, sigmatl - sigmao]))
    else
        error("Neznámé kriterium: $kriterium")
    end
elseif namahanizkr == "střih-krut"
    taus = uconvert(u"MPa",taus)
    tauk   = uconvert(u"MPa",tauk)
    if kriterium === :HMH
        sigma_eq_str = "sqrt(3) * sqrt(taus^2 + tauk^2)"
        sigma_eq = sqrt(3) * sqrt(taus^2 + tauk^2)
    else
        error("Neznámé kriterium: $kriterium")
    end
elseif namahanizkr == "střih-ohyb"
    taus = uconvert(u"MPa",taus)
    sigmao = uconvert(u"MPa",sigmao)
    if kriterium === :HMH
    sigma_eq_str = "sqrt(sigmao^2 + 3*taus^2)"
    sigma_eq = sqrt(sigmao^2 + 3*taus^2)
    else
        error("Neznámé kriterium: $kriterium")
    end
elseif namahanizkr == "krut-ohyb"
    tauk = uconvert(u"MPa",tauk)
    sigmao = uconvert(u"MPa",sigmao)
    if kriterium === :HMH
        sigma_eq_str = "sqrt(sigmao^2 + 3*tauk^2)"
        sigma_eq = sqrt(sigmao^2 + 3*tauk^2)
    elseif kriterium === :Tresca
        sigma_eq_str = "sqrt(sigmao^2 + 4*tauk^2)"
        sigma_eq = sqrt(sigmao^2 + 4*tauk^2)
    else
        error("Neznámé kriterium: $kriterium")
    end
else
    error("Nenalezeno ekvivalentní napětí: $namahanizkr")
end
sigma_eq = uconvert(u"MPa",sigma_eq)
# ---------------------------------------------------------
# bezpečnost
# ---------------------------------------------------------
if namahanizkr in ["tah-střih", "tlak-střih"]
    k_str = "sigmaD / sigma_eq"
    k = sigmaD / sigma_eq
elseif namahanizkr in ["tah-krut", "tlak-krut"]
    k_str = "sigmaD / sigma_eq"
    k = sigmaD / sigma_eq
elseif namahanizkr in ["tah-ohyb", "tlak-ohyb"]
    k_str = "sigmaD / sigma_eq"
    k = sigmaD / sigma_eq
elseif namahanizkr in ["střih-krut", "střih-ohyb"]
    k_str = "sigmaD / sigma_eq"
    k = sigmaD / sigma_eq
elseif namahanizkr == "krut-ohyb"
    k_str = "sigmaD / sigma_eq"
    k = sigmaD / sigma_eq
else
    error("Nenalezeno bezpečnost: $namahanizkr")
end
if k_uziv === nothing
    verdict =   if k >= 1.5
                    "Součást je bezpečná"
                elseif k >= 1.0
                    "Součást je na hranici bezpečnosti"
                else
                    "Součást není bezpečná!"
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
# výstupní dict
# ---------------------------------------------------------
VV = Dict{Symbol,Any}()
VV[:info] = namahani_info
VV[:namahani] = namahanizkr
VV[:kriterium] = kriterium === :HMH ? "Huber-Mises-Hencky" : "Tresca"
VV[:kriterium_info] = "Kriterium pro posouzení dovoleného napětí"
VV[:zatizeni] = zatizeni
VV[:zatizeni_info] = "Typ zatížení"
if isa(k_uziv, Number)
    VV[:k] = k_uziv # uživatelský požadavek bezpečnosti
    VV[:k_info] = "Uživatelský požadavek bezpečnosti kombinovaného namáhání"
end
if @isdefined vsldkTah
    VV[:tah] = vsldkTah
    VV[:sigmat] = sigmat
    VV[:sigmat_info] = "Výsledné normálové napětí tahu"
end
if @isdefined vsldkTlak
    VV[:tlak] = vsldkTlak
    VV[:sigmatl] = sigmatl
    VV[:sigmatl_info] = "Výsledné normálové napětí v tlaku"
end
if @isdefined vsldkStrih
    VV[:strih] = vsldkStrih
    VV[:taus] = taus
    VV[:taus_info] = "Výsledné napětí ve střihu"
end
if @isdefined vsldkKrut
    VV[:krut] = vsldkKrut
    VV[:tauk] = tauk
    VV[:tauk_info] = "Výsledné napětí v krutu"
end
if @isdefined vsldkOhyb
    VV[:ohyb] = vsldkOhyb
    VV[:sigmao] = sigmao
    VV[:sigmao_info] = "Výsledné napětí v ohybu"
end
VV[:sigma_eq] = sigma_eq
VV[:sigma_eq_str] = sigma_eq_str
VV[:sigma_eq_info] = "Ekvivalentní napětí"
VV[:sigmaD] = sigmaD
VV[:sigmaD_info] = "Dovolené napětí"
VV[:bezpecnost] = k
VV[:bezpecnost_str] = k_str
VV[:bezpecnost_info] = "Součinitel bezpečnosti"
VV[:verdict] = verdict
VV[:verdict_info] = "Závěr posouzení"

if return_text
    return VV, StrojniSoucasti.namahanikombinovanetext(VV)
else
    return VV
end
end # konec funkce
