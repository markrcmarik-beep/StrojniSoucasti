## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet průřezového modulu pro ohyb Wo pro dané natočení profilu
# z kvadratického momentu I, vzdálenosti nejvzdálenějšího vlákna od neutrální osy eo.
# ver: 2026-06-20
## Funkce: profilyWo4natoceni()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profilyWo4natoceni.jl
#
## Vzor:
## vystupni_promenne = profilyWo4natoceni(I, eo, text=false)
## Vstupní proměnné:
# I - kvadratický moment profilu pro dané natočení [mm^4]
# eo - vzdálenost nejvzdálenějšího vlákna od neutrální osy pro dané natočení [mm]
# text – boolean, zda vrátit i vzorec jako text (volitelný, výchozí hodnota false)
## Výstupní proměnné:
# Wo – průřezový modul pro ohyb pro dané natočení [mm³]
# vzorec – string s použitým vzorcem pro výpočet
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
function profilyWo4natoceni(I=nothing, eo=nothing, text::Bool=false)
    if I === nothing || eo === nothing
        error("Musí být zadány hodnoty I a eo.")
    end
    Wo = I / eo # průřezový modul pro ohyb dle natoceni
    if text
        vzorec = "I / eo"
        return Wo, vzorec
    else
        return Wo
    end
end
