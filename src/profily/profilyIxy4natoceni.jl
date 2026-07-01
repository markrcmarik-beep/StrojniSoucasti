## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet kvadratického momentu Ialfa pro dané natočení profilu 
# z jeho kvadratických momentů Ix, Iy a Ixy.
# ver: 2026-07-01
## Funkce: profilyIxy4natoceni()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profilyIxy4natoceni.jl
#
## Vzor:
## vystupni_promenne = profilyIxy4natoceni(vstupni_promenne)
## Vstupní proměnné:
# Ix – kvadratický moment pro osu x [mm⁴]
# Iy – kvadratický moment pro osu y [mm⁴]
# Ixy – kvadratický moment součinitele [mm⁴] (volitelný, výchozí hodnota 0)
# natoceni – úhel natočení profilu [rad] (volitelný, výchozí hodnota 0)
# text – boolean, zda vrátit i vzorec jako text (volitelný, výchozí hodnota false)
## Výstupní proměnné:
# Ixyalfa – kvadratický moment Ixy pro dané natočení [mm⁴]
# vzorec – string s použitým vzorcem pro výpočet
# text – boolean, zda vrátit i vzorec jako text (volitelný, výchozí hodnota false)
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
function profilyIxy4natoceni(Ix=nothing, Iy=nothing, Ixy=nothing, natoceni=0, text::Bool=false)
    if Ix === nothing || Iy === nothing || Ixy === nothing
        error("Musí být zadány hodnoty Ix, Iy a Ixy.")
    end
    angle = mod(natoceni, 2*pi) # Normalizace natočení do rozsahu [0, 2π)
    Ixyalfa = (Ix - Iy)/2 * sin(2*angle) + Ixy * cos(2*angle)
    if text
        vzorec = "(Ix - Iy)/2 * sin(2*angle) + Ixy * cos(2*angle)"
        return Ixyalfa, vzorec
    else
        return Ixyalfa
    end
end
