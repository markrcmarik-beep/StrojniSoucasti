## Funkce Julia
###############################################################
## Popis funkce:
# Uloží textový výstup do souboru a vrátí plnou cestu k uloženému souboru.
# ver: 2025-07-26
## Funkce: ulozvypis()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/ulozvypis.jl
## Vzor:
## fullpath = ulozvypis(text, cesta=cesta, soubor=soubor, koncovka=koncovka)
## Vstupní proměnné:
# text - textový výstup. [String]
# cesta - cílová složka. [String] (výchozí výchozí pracovní cesta)
# soubor - název souboru (s nebo bez přípony). [String] (výchozí vypocet.txt)
# koncovka - přípona souboru. [String] (výchozí *.txt)
## Výstupní proměnné:
# fullpath - plná cesta k uloženému souboru.
## Použité balíčky
#
## Použité uživatelské funkce:
#
## Příklad:
# ulozvypis("vysledek", cesta=pwd(), soubor="vypocet")
###############################################################
## Použité proměnné vnitřní:
#

"""
    ulozvypis(text::AbstractString; cesta::AbstractString=pwd(),
        soubor::AbstractString="vypocet", koncovka::AbstractString=".txt") -> String

Uloží textový výstup do souboru a vrátí plnou cestu k uloženému souboru.

Vstupy:
- `text`: textový výstup.
- `cesta`: cílová složka.
- `soubor`: název souboru (s nebo bez přípony).
- `koncovka`: přípona souboru (výchozí `.txt`).

Výstup:
- plná cesta k uloženému souboru.

Příklad:
```julia
ulozvypis("vysledek", cesta=pwd(), soubor="vypocet")
```
"""
function ulozvypis(text::AbstractString;
    cesta::AbstractString = pwd(),
    soubor::AbstractString = "vypocet",
    koncovka::AbstractString = ".txt"
    )
    if koncovka == ".txt"
        # zajistit příponu .txt
        filename = endswith(lowercase(soubor), ".txt") ? soubor : soubor * ".txt"
        fullpath = joinpath(cesta, filename)
        open(fullpath, "w") do io
            write(io, text)
        end
    else
        error("Nepodporovaná koncovka: $koncovka")
    end

    return fullpath
end

# Podpora pro poziční volání: ulozvypis(text, cesta, soubor)
function ulozvypis(text::AbstractString, cesta::AbstractString, 
    soubor::AbstractString)
    return ulozvypis(text; cesta=cesta, soubor=soubor)
end

# Podpora pro poziční volání se specifickou koncovkou: ulozvypis(text, cesta, soubor, koncovka)
function ulozvypis(text::AbstractString, cesta::AbstractString, 
    soubor::AbstractString, koncovka::AbstractString)
    return ulozvypis(text; cesta=cesta, soubor=soubor, koncovka=koncovka)
end
