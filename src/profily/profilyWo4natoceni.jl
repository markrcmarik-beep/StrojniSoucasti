## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet průřezového modulu pro ohyb Wo pro dané natočení profilu
# z jeho kvadratických momentů Ix, Iy a Ixy.
# ver: 2026-06-20
## Funkce: profilyWo4natoceni()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profilyWo4natoceni.jl
#
## Vzor:
## vystupni_promenne = profilyWo4natoceni(vstupni_promenne)
## Vstupní proměnné:
# Ix – kvadratický moment pro osu x [mm⁴]
# Iy – kvadratický moment pro osu y [mm⁴]
# Ixy – kvadratický moment součinitele [mm⁴] (volitelný, výchozí hodnota 0)
# natoceni – úhel natočení profilu [rad] (volitelný, výchozí hodnota 0)
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
function profilyWo4natoceni(Ix=nothing, Iy=nothing, Ixy=nothing, Wx=nothing, Wy=nothing, natoceni=0, text::Bool=false)
    if Ix === nothing || Iy === nothing || Ixy === nothing
        error("Musí být zadány hodnoty Ix, Iy a Ixy.")
    end
    angle = mod(natoceni, 2*pi) # Normalizace natočení do rozsahu [0, 2π)
    Wo = - (Ix - Iy)/2 * sin(2*angle) + Ixy * cos(2*angle) # chybný vzorec, správně by mělo být Wo = Ialfa / c, kde c je vzdálenost od neutrální osy k okraji profilu
    #Wo =
    if text
        vzorec = "- (Ix - Iy)/2 * sin(2*angle) + Ixy * cos(2*angle)"
        return nothing, vzorec
    else
        return Wo
    end
end
