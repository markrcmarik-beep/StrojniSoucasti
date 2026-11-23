# ver: 2026-11-20
## Funkce dovoleneNapeti()
## Autor: Martin
## Funkce Julia v1.13
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/materialy/dovoleneNapeti.jl
## Použité balíčky:
# Unitful
## Použité uživatelské funkce:
#
###############################################################
## Použité proměnné vnitřní:
#
using Unitful
"""
$(read(joinpath(@__DIR__, "..", "..", "docs", "src", "materialy", "dovoleneNapeti.md"), String))
"""
function dovoleneNapeti(N::AbstractString="tah", Z::AbstractString="statický"; 
    Re=nothing, Rm=nothing, Re0_1=nothing, Re0_2=nothing, 
    Re_min=nothing, Rm_min=nothing, Rm_tah=nothing, Rm_tlak=nothing, tau_lim=nothing, mat=nothing)
Re_zadan = Re !== nothing
if Re_zadan && mat !== nothing
    error("Příliš zadání. Zadej jen Re= nebo mat=")
end
# získat proměnné z mat, pokud je zadáno
if mat !== nothing
    if hasproperty(mat, :tabulka)
        tabulka = getproperty(mat, :tabulka)
        #if tabulka in ["ocel", "pryz", "litina", "nezelezne kovy", "plasty", "drevo"]
            if hasproperty(mat, :Re) && Re === nothing
                Re01 = getproperty(mat, :Re)
                if Re01 !== nothing
                    Re = Re01
                end
            end
            if hasproperty(mat, :Re_min) && Re_min === nothing
                Re_min01 = getproperty(mat, :Re_min)
                if Re_min01 !== nothing
                    Re_min = Re_min01
                end
            end
            if hasproperty(mat, :Rm) && Rm === nothing
                Rm01 = getproperty(mat, :Rm)
                if Rm01 !== nothing
                    Rm = Rm01
                end
            end
            if hasproperty(mat, :Rm_min) && Rm_min === nothing
                Rm_min01 = getproperty(mat, :Rm_min)
                if Rm_min01 !== nothing
                    Rm_min = Rm_min01
                end
            end
            if hasproperty(mat, :Rm_tah) && Rm_tah === nothing
                Rm_tah01 = getproperty(mat, :Rm_tah)
                if Rm_tah01 !== nothing
                    Rm_tah = Rm_tah01
                end
            end
            if hasproperty(mat, :Rm_tlak) && Rm_tlak === nothing
                Rm_tlak01 = getproperty(mat, :Rm_tlak)
                if Rm_tlak01 !== nothing
                    Rm_tlak = Rm_tlak01
                end
            end
            if hasproperty(mat, :Re0_1) && Re0_1 === nothing
                Re0_101 = getproperty(mat, :Re0_1)
                if Re0_101 !== nothing
                    Re0_1 = Re0_101
                end
            end
            if hasproperty(mat, :Re0_2) && Re0_2 === nothing
                Re0_201 = getproperty(mat, :Re0_2)
                if Re0_201 !== nothing
                    Re0_2 = Re0_201
                end
            end
        #else
        #    error("Nepodporovaný druh materiálu: $tabulka, proměnná :tabulka.")
        #end
    else
        error("Nerozpoznán druh materiálu neobsahuje proměnnou :tabulka. Výpis: \n$mat")
    end
end
#for i01 in [Re, Re_min, Rm, Rm_min, Rm_tah, Rm_tlak, Re0_1, Re0_2]
if Re !== nothing
    if Re isa Unitful.AbstractQuantity
        try
            Re = ustrip(u"MPa", Re)
        catch
            error("Re musí být napětí (např. 250u\"MPa\").")
        end
    elseif !(Re isa Number)
        error("Re musí být číslo nebo jednotková veličina.")
    end
end
#end
if Re === nothing && Re_min !== nothing
    Re = Re_min
end
if Rm === nothing && Rm_min !== nothing
    Rm = Rm_min
end

if Re === nothing && mat !== nothing
    if hasproperty(mat, :Re)
        Re = getproperty(mat, :Re)
    elseif hasproperty(mat, :Rm_tah) || hasproperty(mat, :Rm_tlak)
        if N == "tlak" && hasproperty(mat, :Rm_tlak)
            Re = getproperty(mat, :Rm_tlak)
        elseif hasproperty(mat, :Rm_tah)
            Re = getproperty(mat, :Rm_tah)
        elseif hasproperty(mat, :Rm_tlak)
            Re = getproperty(mat, :Rm_tlak)
        else
            Re = nothing
        end # konec if
    else
        Re = nothing
    end # konec if
elseif Re === nothing && mat === nothing
    error("Zadej Re= nebo mat=")
end # konec if

if mat !== nothing && hasproperty(mat, :tau_lim)
    tau_lim = getproperty(mat, :tau_lim)
    if tau_lim isa Unitful.Quantity
        tau_lim = uconvert(u"MPa", tau_lim)
    elseif tau_lim isa Number
        tau_lim = tau_lim * u"MPa"
    else
        tau_lim = nothing
    end
    if tau_lim !== nothing && (!isfinite(ustrip(tau_lim)) || ustrip(tau_lim) <= 0)
        tau_lim = nothing
    end
end

if Re !== nothing
# Ověření jednotek Re
if !(Re isa Unitful.Quantity)
    if Re isa Number
        Re = Re*u"MPa"
    else # Pokud Re není ani číslo, ani jednotková veličina
        return nothing
    end # konec if
    #error("Vstupní parametr Re musí mít jednotku (např. 250u\"MPa\").")
end # konec if
# Ověření druhu namáhání
if !(N in POVOLENE_N)
    error("Neznámý druh namáhání: $N. Povolené hodnoty: $(join(POVOLENE_N, ", ")).")
end # konec if
# Ověření způsobu zatížení
if !(Z in POVOLENE_Z)
    error("Neznámý způsob zatížení: $Z. Povolené hodnoty: $(join(POVOLENE_Z, ", ")).")
end # konec if
# Určení bezpečnostního faktoru gammaM podle typu zatížení a namáhání

gammaM_value = StrojniSoucasti.gammaM(Z, N)
# Výpočet dovoleného napětí
sigma = if N in ["tah", "tlak", "ohyb"]
            Re / gammaM_value # Prostý dělič
        elseif N in ["střih", "krut"]
            (tau_lim === nothing ? Re / sqrt(3) : tau_lim) / gammaM_value # Střih/krut: přednostně tau_lim
        elseif N in ["tah-střih", "tlak-střih", "tah-krut", "tlak-krut", 
                "tah-ohyb", "tlak-ohyb", "krut-ohyb"]
            Re / gammaM_value # Prostý dělič
        elseif N in ["střih-krut", "střih-ohyb"]
        (tau_lim === nothing ? Re / sqrt(3) : tau_lim) / gammaM_value # Střih/krut: přednostně tau_lim
        elseif N == "krut-ohyb"
            (tau_lim === nothing ? Re / sqrt(3) : tau_lim) / gammaM_value # Střih/krut: přednostně tau_lim
        elseif N == "otlačení"
            Re / gammaM_value # Speciální případ pro otlačení (rozdělení bezpečnostního faktoru)
        else # Pokud by se sem dostal, znamená to, že N není v povolených hodnotách, což by mělo být zachyceno dříve.
            error("Neznámé: $N")
        end # konec if

return sigma # Vrácení výsledku
else # Pokud Re není zadáno, vrátíme nothing (nebo případně můžeme zvolit jinou logiku, např. použít mat.Re, pokud je k dispozici).
    return nothing
end # konec if
end # konec funkce dovoleneNapeti
