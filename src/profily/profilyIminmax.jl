## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet minimálního a maximálního kvadratického momentu Ialfa pro dané natočení profilu 
# z jeho kvadratických momentů Ix, Iy a Ixy.
# ver: 2026-06-22
## Funkce: profilyIminmax()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profilyIminmax.jl
#
## Vzor:
## vystupni_promenne = profilyIminmax(vstupni_promenne)
## Vstupní proměnné:
# Ix – kvadratický moment pro osu x [mm⁴]
# Iy – kvadratický moment pro osu y [mm⁴]
# Ixy – kvadratický moment součinitele [mm⁴] (volitelný, výchozí hodnota 0)
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
# Ix = 1000.0
# Iy = 500.0
# Ixy = 200.0
# Imin, Imax, vzorecmin, vzorecmax = profilyIminmax(Ix, Iy, Ixy, true)
# println("Imin: ", Imin, " mm^4, Imax: ", Imax, " mm^4")
# println("Vzorec pro Imin: ", vzorecmin)
# println("Vzorec pro Imax: ", vzorecmax)
#
###############################################################
## Použité proměnné vnitřní:
#
function profilyIminmax(Ix=nothing, Iy=nothing, Ixy=nothing, text::Bool=false)
    if Ix === nothing || Iy === nothing || Ixy === nothing
        error("Musí být zadány hodnoty Ix, Iy, Ixy.")
    end
    #angle = mod(natoceni, 2*pi) # Normalizace natočení do rozsahu [0, 2π)
    Imin = (Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )
    Imax = (Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )
    if text
        vzorecmin = "(Ix + Iy)/2 - sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        vzorecmax = "(Ix + Iy)/2 + sqrt( ((Ix - Iy)/2)^2 + Ixy^2 )"
        return Imin, Imax, vzorecmin, vzorecmax
    else
        return Imin, Imax
    end
end
