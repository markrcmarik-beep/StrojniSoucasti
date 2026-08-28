# ver: 2026-08-27
## Funkce: toleranceISOlicovani()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/tolerance/toleranceISOlicovani.jl
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
#
###############################################################
## Použité proměnné vnitřní:
#
using TOML

"""
toleranceISOlicovani
"""
function toleranceISOlicovani(spec::AbstractString)
#---------------------------------------------------------------------
# pomocné funkce
function zarazeni(VV1, VV2)
    VV = Dict{Symbol,Any}(
        :druh1 => VV1[:druh],
        :druh1_info => "druh tolerance (díra/hřídel)",
        :rozsahIT1 => VV1[:rozsahIT],
        :rozsahIT1_info => "rozsah jmenovitého rozměru dle IT",
        :rozsahPOLE1 => VV1[:rozsahPOLE],
        :rozsahPOLE1_info => "rozsah jmenovitého rozměru dle POLE",
        :stupen1 => VV1[:stupen],
        :stupen1_info => "stupeň tolerance",
        :IT1 => VV1[:IT],
        :I1T_info => "hodnota IT pro daný rozsah a stupeň",
        :nominal1 => VV1[:nominal],
        :nominal1_info => "jmenovitý rozměr",
        :zone1 => VV1[:zone],
        :zone1_info => "zóna tolerance (velká/malá)",
        :min1 => VV1[:min],
        :min1_info => "průměr min",
        :max1 => VV1[:max],
        :max1_info => "průměr max",
        :ES1 => VV1[:ES],
        :EI1 => VV1[:EI],
        :es1 => nothing,
        :ei1 => nothing,
        :druh2 => VV2[:druh],
        :druh2_info => "druh tolerance (díra/hřídel)"
    )
    return VV
end
#---------------------------------------------------------------------
# pomocné funkce konec
    s = replace(strip(spec), "," => ".") # nahrazení čárky tečkou pro desetinné číslo
    s = replace(s, " " => "") # odstranění mezer
    rx = r"(\d+(?:\.\d+)?)([A-Za-z]+)(\d+)" # regex pro rozdělení na jmenovitý rozměr, zónu a stupeň
    m1 = match(Regex("\\A" * rx.pattern * "\\z"), s) # regex pro rozdělení na jmenovitý rozměr, zónu a stupeň
    m2 = match(Regex("\\A" * rx.pattern * "/" * rx.pattern * "\\z"), s)
    m3 = match(Regex("\\A" * rx.pattern * "/([A-Za-z]+)(\\d+)\\z"), s)

    if m1 !== nothing
        m = m1
        nominal = parse(Float64, m.captures[1]) # převod jmenovitého rozměru na Float64
        zone = m.captures[2] # zóna (např. "H" nebo "f")
        grade = m.captures[3] # stupeň
        VV = StrojniSoucasti.toleranceISOulozeni(nominal, zone, grade)
    elseif m2 !== nothing
        m = m2
        if length(m) == 6
            nominal1 = parse(Float64, m.captures[1]) # převod jmenovitého rozměru na Float64
            zone1 = m.captures[2] # zóna (např. "H" nebo "f")
            grade1 = m.captures[3] # stupeň
            VV_1 = StrojniSoucasti.toleranceISOulozeni(nominal1, zone1, grade1)
            nominal2 = parse(Float64, m.captures[4]) # převod jmenovitého rozměru na Float64
            zone2 = m.captures[5] # zóna (např. "H" nebo "f")
            grade2 = m.captures[6] # stupeň
            VV_2 = StrojniSoucasti.toleranceISOulozeni(nominal2, zone2, grade2)
            if (VV_1[:druh] == "díra") && (VV_2[:druh] == "hřídel")
                VV1 = VV_1
                VV2 = VV_2
            elseif (VV_1[:druh] == "hřídel") && (VV_2[:druh] == "díra")
                VV1 = VV_2
                VV2 = VV_1
            end
    
        end
        VV = zarazeni(VV1, VV2)
    elseif m3 !== nothing
        m = m3
        nominal1 = parse(Float64, m.captures[1])
        zone1 = m.captures[2]
        grade1 = m.captures[3]
        VV_1 = StrojniSoucasti.toleranceISOulozeni(nominal1, zone1, grade1)
        zone2 = m.captures[4]
        grade2 = m.captures[5]
        VV_2 = StrojniSoucasti.toleranceISOulozeni(nominal1, zone2, grade2)
        if (VV_1[:druh] == "díra") && (VV_2[:druh] == "hřídel")
            VV1 = VV_1
            VV2 = VV_2
        elseif (VV_1[:druh] == "hřídel") && (VV_2[:druh] == "díra")
            VV1 = VV_2
            VV2 = VV_1
        end
        VV = zarazeni(VV1, VV2)
    else
        error("Neplatné označení tolerance: '$spec'")
    end
    return VV

end
