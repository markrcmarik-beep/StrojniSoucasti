## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí hodnotu dovoleného napětí materiálu.
# ver: 2026-02-18
## Funkce: dovoleneNapeti()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/dovoleneNapeti.jl
#
## Vzor:
## sigma = dovoleneNapeti(Re, N::AbstractString, Z::AbstractString)
## Vstupní proměnné:
# Re - mez kluzu materiálu s jednotkou (např. 250u"MPa")
# N - druh namáhání jako řetězec: "tah", "tlak", "střih", "ohyb", "krut"
# Z - způsob zatížení jako řetězec: "statický", "pulzní", "dynamický", "rázový"
## Výstupní proměnné:
# sigma - dovolené napětí materiálu s jednotkou (MPa)
## Použité balíčky
# Unitful, TOML
## Použité uživatelské funkce:
#
## Příklad:
# dovoleneNapeti(250u"MPa", "tah", "statický")
#   vrátí dovolené napětí pro materiál s mezí kluzu 250 MPa při statickém tahu
#   => 192.3076923076923 MPa
# dovoleneNapeti(250u"MPa", "střih", "dynamický")
#   vrátí dovolené napětí pro materiál s mezí kluzu 250 MPa při dynamickém střihu
#   => 57.73502691896258 MPa

###############################################################
## Použité proměnné vnitřní:
#
using Unitful, TOML

# Načtení základní tabulky gammaM z externího TOML.
const GAMMA_M_BASE = begin
    raw = TOML.parsefile(joinpath(@__DIR__, "gammaM.toml"))
    base = Dict{Tuple{String,String},Float64}()
    z_values = String[]
    n_values = String[]

    for (Z, row_any) in raw
        row_any isa AbstractDict || error("Neplatná sekce '$Z' v gammaM.toml.")
        push!(z_values, String(Z))
        for (N, v_any) in row_any
            push!(n_values, String(N))
            base[(String(Z), String(N))] = Float64(v_any)
        end # konec for
    end # konec for

    unique_n = unique(n_values)
    for Z in unique(z_values), N in unique_n
        haskey(base, (Z, N)) || error("V gammaM.toml chybí hodnota pro Z='$Z', N='$N'.")
    end # konec for
    base
end # konec const GAMMA_M_BASE

const ZS = sort!(unique([z for (z, _) in keys(GAMMA_M_BASE)]))
const NS_SIMPLE = sort!(unique([n for (_, n) in keys(GAMMA_M_BASE)]))

# Určení bezpečnostního faktoru gammaM podle typu zatížení a namáhání.
const GAMMA_M = begin
    G = Dict{Tuple{String,String},Float64}()
    for ((Z, N), v) in GAMMA_M_BASE
        G[(Z, N)] = v
    end # konec for

    combo_factor = 1.15
    for Z1 in ZS, Z2 in ZS
        Zkey = string(Z1, "-", Z2)
        for N in NS_SIMPLE
            G[(Zkey, N)] = max(GAMMA_M_BASE[(Z1, N)], GAMMA_M_BASE[(Z2, N)])
        end # konec for
        for i in eachindex(NS_SIMPLE)
            for j in (i+1):lastindex(NS_SIMPLE)
                a = NS_SIMPLE[i]
                b = NS_SIMPLE[j]
                Nkey = string(a, "-", b)
                g_candidates = [GAMMA_M_BASE[(Z1, a)], GAMMA_M_BASE[(Z2, b)], GAMMA_M_BASE[(Z1, b)], GAMMA_M_BASE[(Z2, a)]]
                g = round(maximum(g_candidates) * combo_factor; digits=2)
                G[(Zkey, Nkey)] = g
                G[(Zkey, string(b, "-", a))] = g
            end # konec for
        end # konec for
    end # konec for
    G # Vrácení kompletního slovníku GAMMA_M s kombinacemi zatížení a namáhání
end # konec const GAMMA_M

const POVOLENE_N = sort!(unique([n for (_, n) in keys(GAMMA_M)]))
const POVOLENE_Z = sort!(unique([z for (z, _) in keys(GAMMA_M)]))

"""
    dovoleneNapeti(Re, N::AbstractString, Z::AbstractString="statický") -> Quantity

Vrátí dovolené napětí materiálu podle meze kluzu `Re`, druhu namáhání `N`
a způsobu zatížení `Z`.

Vstupy:
- `Re`: mez kluzu s jednotkou (např. `250u"MPa"`). Pokud je bez jednotky,
  jednotka MPa se doplní.
- `mat`: výstup z `materialy(...)`. Pokud není zadáno `Re`, použije se `mat.Re`.
- `N`: druh namáhání jako řetězec (např. `"tah"`, `"tlak"`, `"střih"`,
  `"ohyb"`, `"krut"`, kombinace jako `"tah-střih"`).
- `Z`: způsob zatížení jako řetězec (např. `"statický"`, `"pulzní"`,
  `"dynamický"`, `"rázový"`, kombinace jako `"statický-dynamický"`).

Výstup:
- `sigma`: dovolené napětí s jednotkou (MPa).

Příklad:
```julia
dovoleneNapeti(250u"MPa", "tah", "statický")
dovoleneNapeti(250u"MPa", "střih", "dynamický")
```
"""
function dovoleneNapeti(N::AbstractString, Z::AbstractString="statický"; Re=nothing, mat=nothing)
if Re === nothing && mat !== nothing
    if hasproperty(mat, :Re)
        Re = getproperty(mat, :Re)
    else
        Re = nothing
    end # konec if
elseif Re === nothing && mat === nothing
    error("Zadej Re= nebo mat=")
elseif Re !== nothing && mat !== nothing
    error("Příliš zadání. Zadej jen Re= nebo mat=")
end # konec if

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

gammaM = gammaM_funkce(Z, N)
# Výpočet dovoleného napětí
sigma = if N in ["tah", "tlak", "ohyb"]
            Re / gammaM # Prostý dělič
        elseif N in ["střih", "krut"]
            Re / sqrt(3) / gammaM # Von Misesův kriteriál
        elseif N in ["tah-střih", "tlak-střih", "tah-krut", "tlak-krut", 
                "tah-ohyb", "tlak-ohyb", "krut-ohyb"]
            Re / gammaM # Prostý dělič
        elseif N in ["střih-krut", "střih-ohyb"]
        Re / sqrt(3) / gammaM # Von Misesův kriteriál
        elseif N == "krut-ohyb"
            Re / sqrt(3) / gammaM # Von Misesův kriteriál
        elseif N == "otlačení"
            Re / gammaM # Speciální případ pro otlačení (rozdělení bezpečnostního faktoru)
        else # Pokud by se sem dostal, znamená to, že N není v povolených hodnotách, což by mělo být zachyceno dříve.
            error("Neznámé: $N")
        end # konec if

return sigma # Vrácení výsledku
else # Pokud Re není zadáno, vrátíme nothing (nebo případně můžeme zvolit jinou logiku, např. použít mat.Re, pokud je k dispozici).
    return nothing
end # konec if
end # konec funkce dovoleneNapeti

function gammaM_funkce(Z::AbstractString, N::AbstractString)
    # Pokud uživatel zadá jednosložkové zatížení (např. "statický")
    # a druh namáhání je kombinovaný (např. "tah-střih"),
    # zkusíme normalizovat Z na dvojici ve tvaru "Z-Z".
    key = (Z, N)
    if haskey(GAMMA_M, key)
        return GAMMA_M[key]
    end # konec if
    # Pokus o normalizaci: pokud je Z jednosložkové a N kombinované,
    # vyzkoušíme klíč ("Z-Z", N)
    if !occursin("-", Z) && occursin("-", N)
        key2 = (string(Z, "-", Z), N)
        if haskey(GAMMA_M, key2)
            return GAMMA_M[key2]
        end # konec if
    end # konec if
    # Pokud nebylo nalezeno, vypiš srozumitelnou chybu
    error("Neznámá kombinace zatížení: Z=$Z, N=$N")
end # konec funkce gammaM_funkce
