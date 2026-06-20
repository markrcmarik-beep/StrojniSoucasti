## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet minimálního a maximálního kvadratického momentu Ialfa pro dané natočení profilu 
# z jeho kvadratických momentů Ix, Iy a Ixy.
# ver: 2026-06-20
## Funkce: profilyIminmax4natoceni()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profilyIminmax4natoceni.jl
#
## Vzor:
## vystupni_promenne = profilyIminmax4natoceni(vstupni_promenne)
## Vstupní proměnné:
# Ix – kvadratický moment pro osu x [mm⁴]
# Iy – kvadratický moment pro osu y [mm⁴]
# Ixy – kvadratický moment součinitele [mm⁴] (volitelný, výchozí hodnota 0)
# natoceni – úhel natočení profilu [rad] (volitelný, výchozí hodnota 0)
# text – boolean, zda vrátit i vzorec jako text (volitelný, výchozí hodnota false)
## Výstupní proměnné:
# Imin – minimální kvadratický moment pro dané natočení [mm⁴]
# Imax – maximální kvadratický moment pro dané natočení [mm⁴]
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
function profilyIminmax4natoceni(Ix=nothing, Iy=nothing, Ixy=nothing, natoceni=0, text::Bool=false)
    if Ix === nothing || Iy === nothing || Ixy === nothing
        error("Musí být zadány hodnoty Ix, Iy, Ixy.")
    end
    angle = mod(natoceni, 2*pi) # Normalizace natočení do rozsahu [0, 2π)
    Imin = (Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ) * cos(2*angle) + Ixy * sin(2*angle)
    Imax = (Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ) * cos(2*angle) - Ixy * sin(2*angle)
    if text
        vzorecmin = "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ) * cos(2*angle) + Ixy * sin(2*angle)"
        vzorecmax = "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ) * cos(2*angle) - Ixy * sin(2*angle)"
        return Imin, Imax, vzorecmin, vzorecmax
    else
        return Imin, Imax
    end
end
