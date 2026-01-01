## Funkce Julia
###############################################################
## Popis funkce:
# Vrátí hodnotu dovoleného napětí materiálu.
# ver: 2025-12-25
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
function dovoleneNapeti(Re, N::AbstractString, Z::AbstractString="statický")
# Ověření jednotek Re
if !(Re isa Unitful.Quantity)
    error("Vstupní parametr Re musí mít jednotku (např. 250u\"MPa\").")
end
# Ověření druhu namáhání
povoleneN = ["tah", "tlak", "střih", "ohyb", "krut", "otlačení",
    "tah-střih", "tlak-střih", "tah-krut", "tlak-krut", 
    "ohyb-krut"]
povoleneZ = ["statický", "pulzní", "dynamický", "rázový",
    "statický-statický"]
if !(N in povoleneN)
    error("Neznámý druh namáhání: $N. Povolené hodnoty: $(join(povoleneN, ", ")).")
end
if !(Z in povoleneZ)
    error("Neznámý způsob zatížení: $Z. Povolené hodnoty: $(join(povoleneZ, ", ")).")
end
# Určení bezpečnostního faktoru gammaM podle typu zatížení a namáhání
gammaM = begin
    if Z == "statický-statický"
        if N in ["tah-střih", "střih-tah"]
            1.5
        elseif N in ["tlak-střih", "střih-tlak"]
            1.5
        elseif N in ["tah-krut", "krut-tah"]
            1.7
        elseif N in ["tlak-krut", "krut-tlak"]
            1.7
        elseif N in ["ohyb-krut", "krut-ohyb"]
            1.7
        else
            error("Neznámý druh namáhání: $N")
        end
    elseif Z == "statický-pulzní"
        if N == "tah-střih"
            1.5
        elseif N == "tlak-střih"
            1.5
        else
            error("Neznámý druh namáhání: $N")
        end
    elseif Z == "statický"
        if N in ["tah", "tlak"]
            1.3
        elseif N == "střih"
            1.5
        elseif N == "ohyb"
            1.5
        elseif N == "krut"
            1.7
        elseif N == "otlačení"
            0.8
        else
            error("Neznámý druh namáhání: $N")
        end
    elseif Z == "pulzní"
        if N in ["tah", "tlak"]
            1.7
        elseif N == "střih"
            2.0
        elseif N == "ohyb"
            2
        elseif N == "krut"
            2.2
        elseif N == "otlačení"
            1.0
        else
            error("Neznámý druh namáhání: $N")
        end
    elseif Z == "dynamický"
        if N in ["tah", "tlak"]
            2.0
        elseif N == "střih"
            2.5
        elseif N == "ohyb"
            2.5
        elseif N == "krut"
            2.7
        elseif N == "otlačení"
            1.2
        else
            error("Neznámý druh namáhání: $N")
        end
    elseif Z == "rázový"
        if N in ["tah", "tlak"]
            2.5
        elseif N == "střih"
            3.0
        elseif N == "ohyb"
            3
        elseif N == "krut"
            3.2
        elseif N == "otlačení"
            1.5
        else
            error("Neznámý druh namáhání: $N")
        end
    else
        error("Neznámý způsob zatížení: $Z")
    end
end

# Výpočet dovoleného napětí
sigma = if N in ["tah", "tlak", "ohyb"]
    Re / gammaM # Prostý dělič
elseif N in ["střih", "krut"]
    Re / sqrt(3) / gammaM # Von Misesův kriteriál
elseif N in ["tah-střih", "tlak-střih", "tah-krut", "tlak-krut", "ohyb-krut"]
    Re / gammaM
elseif N == "otlačení"
    Re * gammaM # Speciální případ pro otlačení
end

return sigma # Vrácení výsledku
end