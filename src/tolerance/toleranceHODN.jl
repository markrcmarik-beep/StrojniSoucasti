# ver: 2026-08-14
## Funkce: tolerance()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/tolerance/toleranceHODN.jl
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
#
###############################################################
## Použité proměnné vnitřní:
#
using TOML

#const TOL_IT = TOML.parsefile(joinpath(@__DIR__, "toleranceIT.toml"))
#const TOL_POLE = TOML.parsefile(joinpath(@__DIR__, "tolerancePOLE1.toml"))

function toleranceHODN(nominal::Real, zone::AbstractString, grade::AbstractString)
    nominal = Float64(nominal) # převod jmenovitého rozměru na Float64
    zone = strip(zone) # odstranění mezer ze zóny
    grade_str = strip(grade) # odstraneni mezer z grade stringu
    grade_int = parse(Int, grade_str) # převod stupně na Int
    TOL_IT = TOML.parsefile(joinpath(@__DIR__, "toleranceIT.toml"))

    if all(isuppercase, zone)
        druh = "díra"
    elseif all(islowercase, zone)
        druh = "hřídel"
    else
        error("Zóna musí být velká (díra) nebo malá (hřídel).")
    end
    # Vyhledání klíče rozsahu (size_key) pro jmenovitý rozměr
    size_keyIT = ""
    found_size_keyIT = false
    for keyIT in TOL_IT["sizesIT"]
        parts = split(keyIT, "-")
        a = parse(Float64, parts[1])
        b = parse(Float64, parts[2])
        if nominal > a && nominal <= b
            size_keyIT = keyIT
            found_size_keyIT = true
            break
        end
    end
    !found_size_keyIT && error("Rozměr $(nominal) mm je mimo rozsah tabulky IT.")
    # Získání hodnoty IT na základě sizeIT_key a grade
    table = TOL_IT[size_keyIT]
    it_key_str = string(grade_int)
    haskey(table, it_key_str) || error("IT$(grade_int) není v tabulce pro rozsah $(size_key).")
    it_value = table[it_key_str] # Získání hodnoty IT z tabulky

    TOL_POLE = TOML.parsefile(joinpath(@__DIR__, "tolerancePOLE1.toml"))
    # Vyhledání klíče rozsahu (size_key) pro jmenovitý rozměr
    size_keyPOLE = ""
    found_size_keyPOLE = false
    for keyPOLE in TOL_POLE["sizesPOLE"]
        parts = split(keyPOLE, "-")
        a = parse(Float64, parts[1])
        b = parse(Float64, parts[2])
        if nominal > a && nominal <= b
            size_keyPOLE = keyPOLE
            found_size_keyPOLE = true
            break
        end
    end
    #println("size_keyPOLE: ", size_keyPOLE)
    !found_size_keyPOLE && error("Rozměr $(nominal) mm je mimo rozsah tabulky POLE.")
    # Získání hodnoty z tabulky POLE na základě sizePOLE_key a zone
    table_pole = TOL_POLE[size_keyPOLE]
    #println("table_pole: ", table_pole)
    haskey(table_pole, zone) || error("Zóna $(zone) není v tabulce pro rozsah $(size_keyPOLE).")
    zone_value = table_pole[zone] # Získání hodnoty z tabulky POLE z tabulky
    println("zone_value: ", zone_value)
    # Výpočet tolerance

    VV = Dict{Symbol,Any}(
        :druh => druh,
        :druh_info => "druh tolerance (díra/hřídel)",
        :rozsah => size_keyIT,
        :rozsah_info => "rozsah jmenovitého rozměru",
        :stupen => grade_int,
        :stupen_info => "stupeň tolerance",
        :it => it_value,
        :it_info => "hodnota IT pro daný rozsah a stupeň",
        :nominal => nominal,
        :nominal_info => "jmenovitý rozměr",
        :zone => zone,
        :zone_info => "zóna tolerance (velká/malá)"
    )
    println("VV: ", VV)
    return it_value
end
