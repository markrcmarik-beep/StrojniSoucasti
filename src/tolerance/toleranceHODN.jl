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

const TOL_IT = TOML.parsefile(joinpath(@__DIR__, "toleranceIT.toml"))
const TOL_POLE = TOML.parsefile(joinpath(@__DIR__, "tolerancePOLE1.toml"))

function toleranceHODN(nominal::Real, zone::AbstractString, grade::AbstractString)
    nominal = Float64(nominal) # převod jmenovitého rozměru na Float64
    zone = strip(zone) # odstranění mezer ze zóny
    grade_str = strip(grade) # odstraneni mezer z grade stringu
    grade_int = parse(Int, grade_str) # převod stupně na Int

    if all(isuppercase, zone)
        druh = "hole"
    elseif all(islowercase, zone)
        druh = "shaft"
    else
        error("Zóna musí být velká (díra) nebo malá (hřídel).")
    end
    # Vyhledání klíče rozsahu (size_key) pro jmenovitý rozměr
    size_key = ""
    found_size_key = false
    for key in TOL_IT["sizesIT"]
        parts = split(key, "-")
        a = parse(Float64, parts[1])
        b = parse(Float64, parts[2])
        if nominal > a && nominal <= b
            size_key = key
            found_size_key = true
            break
        end
    end
    !found_size_key && error("Rozměr $(nominal) mm je mimo rozsah tabulky IT.")
    # Získání hodnoty IT na základě size_key a grade
    table = TOL_IT[size_key]
    it_key_str = string(grade_int)
    haskey(table, it_key_str) || error("IT$(grade_int) není v tabulce pro rozsah $(size_key).")
    it_value = table[it_key_str] # Získání hodnoty IT z tabulky

    # Prozatím vrátíme it_value pro ověření, později se zde budou počítat odchylky
    println(it_value)
    return it_value
end
