## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet kvadratického momentu Ialfa pro dané natočení profilu 
# z jeho kvadratických momentů Ix, Iy a Ixy.
# ver: 2026-07-01
## Funkce: profilyI4natoceni()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profilyI4natoceni.jl
#
## Vzor:
## vystupni_promenne = profilyI4natoceni(vstupni_promenne)
## Vstupní proměnné:
# Ix – kvadratický moment pro osu x [mm⁴]
# Iy – kvadratický moment pro osu y [mm⁴]
# Ixy – kvadratický moment součinitele [mm⁴] (volitelný, výchozí hodnota 0)
# natoceni – úhel natočení profilu [rad] (volitelný, výchozí hodnota 0)
# text – boolean, zda vrátit i vzorec jako text (volitelný, výchozí hodnota false)
## Výstupní proměnné:
# Ialfa – kvadratický moment pro dané natočení [mm⁴]
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
function profilyI4natoceni(Ix=nothing, Iy=nothing, Ixy=nothing, natoceni=0, text::Bool=false)
    if Ix === nothing || Iy === nothing || Ixy === nothing
        error("Musí být zadány hodnoty Ix, Iy, Ixy.")
    end
    angle = mod(natoceni, 2*pi) # Normalizace natočení do rozsahu [0, 2π)
    Ialfa = (Ix + Iy)/2 + (Ix - Iy)/2 * cos(2*angle) + Ixy * sin(2*angle)
    if text
        vzorec = "(Ix + Iy)/2 + (Ix - Iy)/2 * cos(2*angle) + Ixy * sin(2*angle)"
        return Ialfa, vzorec
    else
        return Ialfa
    end
end
