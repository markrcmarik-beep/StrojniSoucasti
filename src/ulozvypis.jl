## Funkce Julia
###############################################################
## Popis funkce:
#
# ver: 2025-12-29
## Funkce: ulozvypis()
#
## Vzor:
## vystupni_promenne = ulozvypis(vstupni_promenne)
## Vstupní proměnné:
#
## Výstupní proměnné:
#
## Použité balíčky
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#

###############################################################
## Funkce Julia
###############################################################
## Popis funkce:
# Uloží textový výstup výpočtu namáhání do souboru .txt
#
## Funkce: ulozVypisTxt()
#
## Vstup:
# text     - textový výstup (String), typicky Dispstr
# soubor   - název souboru bez nebo s příponou .txt
# cesta    - cesta k uložení (výchozí aktuální adresář)
#
## Výstup:
# fullpath - plná cesta k uloženému souboru
###############################################################

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
