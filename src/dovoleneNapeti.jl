## Funkce Julia
###############################################################
## Popis funkce:
# Vrátí hodnotu dovoleného napětí materiálu.
# ver: 2026-01-19
## Funkce: dovoleneNapeti()
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
# Unitful
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
using Unitful

# Určení bezpečnostního faktoru gammaM podle typu zatížení a namáhání
# GENERÁTOR: vytvoří konzistentní a symetrickou tabulku hodnot podle
# standardních pravidel: pro kombinace se použije konzervativní maximum
# a pro kombinované namáhání aplikujeme mírný násobící faktor.
const GAMMA_M = begin
    Zs = ["statický","pulzní","dynamický","rázový"]
    Ns_simple = ["tah","tlak","střih","krut","ohyb","otlačení"]

    # Základní (jednoduché) hodnoty - upravené tak, aby byly konzistentní
    base = Dict{Tuple{String,String},Float64}()
    base[("statický","tah")] = 1.3
    base[("statický","tlak")] = 1.3
    base[("statický","střih")] = 1.5
    base[("statický","krut")] = 1.7
    base[("statický","ohyb")] = 1.5
    base[("statický","otlačení")] = 1.0

    base[("pulzní","tah")] = 1.7
    base[("pulzní","tlak")] = 1.7
    base[("pulzní","střih")] = 2.0
    base[("pulzní","krut")] = 2.2
    base[("pulzní","ohyb")] = 2.0
    base[("pulzní","otlačení")] = 1.2

    base[("dynamický","tah")] = 2.0
    base[("dynamický","tlak")] = 2.0
    base[("dynamický","střih")] = 2.5
    base[("dynamický","krut")] = 2.7
    base[("dynamický","ohyb")] = 2.5
    base[("dynamický","otlačení")] = 1.3

    base[("rázový","tah")] = 2.5
    base[("rázový","tlak")] = 2.5
    base[("rázový","střih")] = 3.0
    base[("rázový","krut")] = 3.2
    base[("rázový","ohyb")] = 3.0
    base[("rázový","otlačení")] = 1.5

    G = Dict{Tuple{String,String},Float64}()
    # Přidej jednoduché případy
    for ((Z,N),v) in base
        G[(Z,N)] = v
    end
    # Funkce pro vytvoření všech kombinací Z1-Z2 a N kombinací
    combo_factor = 1.15
    for Z1 in Zs, Z2 in Zs
        Zkey = string(Z1, "-", Z2)
        # jednoduché namáhání pro kombinace zatížení: bereme konzervativní maximum
        for N in Ns_simple
            G[(Zkey,N)] = max(base[(Z1,N)], base[(Z2,N)])
        end
        # kombinované druhy namáhání (všechny dvojice z Ns_simple)
        for i in eachindex(Ns_simple)
            for j in (i+1):lastindex(Ns_simple)
                a = Ns_simple[i]
                b = Ns_simple[j]
                Nkey = string(a, "-", b)
                # vezmeme nejhorší kombinaci obou režimů a aplikujeme faktor
                g_candidates = [base[(Z1,a)], base[(Z2,b)], base[(Z1,b)], base[(Z2,a)]]
                g = maximum(g_candidates) * combo_factor
                # nepropadejme pod maximum komponent
                g = max(g, maximum(g_candidates))
                g = round(g; digits=2)
                G[(Zkey,Nkey)] = g
                G[(Zkey,string(b, "-", a))] = g
            end
        end
    end
    G
end

function dovoleneNapeti(Re, N::AbstractString, Z::AbstractString="statický")
# Ověření jednotek Re
if !(Re isa Unitful.Quantity)
   Re = Re*u"MPa"
    #error("Vstupní parametr Re musí mít jednotku (např. 250u\"MPa\").")
end
# Ověření druhu namáhání
povoleneN = ["tah", "tlak", "střih", "krut", "ohyb", "otlačení",
    "tah-střih", "tlak-střih", "tah-krut", "tlak-krut", "tah-ohyb", "tlak-ohyb",
    "střih-krut", "střih-ohyb", "krut-ohyb"] # kombinované druhy namáhání
povoleneZ = ["statický", "pulzní", "dynamický", "rázový",
    "statický-statický", "statický-pulzní", "pulzní-statický", 
    "pulzní-pulzní", "statický-dynamický", "pulzní-dynamický", "dynamický-dynamický",
    "statický-rázový", "pulzní-rázový", "dynamický-rázový", "rázový-rázový"] # kombinované způsoby zatížení
if !(N in povoleneN)
    error("Neznámý druh namáhání: $N. Povolené hodnoty: $(join(povoleneN, ", ")).")
end
if !(Z in povoleneZ)
    error("Neznámý způsob zatížení: $Z. Povolené hodnoty: $(join(povoleneZ, ", ")).")
end
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
        else
            error("Neznámé: $N")
        end

return sigma # Vrácení výsledku
end

function gammaM_funkce(Z::AbstractString, N::AbstractString)
    # Pokud uživatel zadá jednosložkové zatížení (např. "statický")
    # a druh namáhání je kombinovaný (např. "tah-střih"),
    # zkusíme normalizovat Z na dvojici ve tvaru "Z-Z".
    key = (Z, N)
    if haskey(GAMMA_M, key)
        return GAMMA_M[key]
    end
    # Pokus o normalizaci: pokud je Z jednosložkové a N kombinované,
    # vyzkoušíme klíč ("Z-Z", N)
    if !occursin("-", Z) && occursin("-", N)
        key2 = (string(Z, "-", Z), N)
        if haskey(GAMMA_M, key2)
            return GAMMA_M[key2]
        end
    end
    # Pokud nebylo nalezeno, vypiš srozumitelnou chybu
    error("Neznámá kombinace zatížení: Z=$Z, N=$N")
end
