## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet kvadratického momentu Ialfa pro dané natočení profilu 
# z jeho kvadratických momentů Ix, Iy a Ixy.
# ver: 2026-06-15
## Funkce: profilyIx2Ialfa()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profilyIx2Ialfa.jl
#
## Vzor:
## vystupni_promenne = profilyIx2Ialfa(vstupni_promenne)
## Vstupní proměnné:
# Ix – kvadratický moment pro osu x [mm⁴]
# Iy – kvadratický moment pro osu y [mm⁴]
# Ixy – kvadratický moment součinitele [mm⁴] (volitelný, výchozí hodnota 0)
# natoceni – úhel natočení profilu [rad] (volitelný, výchozí hodnota 0)
## Výstupní proměnné:
# Ialfa – kvadratický moment pro dané natočení [mm⁴]
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
function profilyIx2Ialfa(Ix=nothing, Iy=nothing, Ixy=0, natoceni=0)
    if Ix === nothing || Iy === nothing
        error("Musí být zadány hodnoty Ix a Iy.")
    end
    angle = mod(natoceni, 2*pi) # Normalizace natočení do rozsahu [0, 2π)
    Ialfa = (Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ) * cos(2*angle) + Ixy * sin(2*angle)
    vzorec = "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 ) * cos(2*natoceni) + Ixy * sin(2*natoceni)"
    return Ialfa, vzorec
end
