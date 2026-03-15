## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Funkce pro výpočet tolerancí podle tabulek (ČSN/ISO).
# ver: 2026-03-15
## Funkce: nazev_funkce()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/tolerance.jl
#
## Vzor:
## vystupni_promenne = tolerance(vstupni_promenne)
## Vstupní proměnné:
# - `spec::AbstractString`: Zápis tolerance ve formátu "40H8" nebo "10f7".
# - `nominal::Real`: Jmenovitý rozměr v mm.
# - `zone::AbstractString`: Zóna tolerance (např. "H" pro díru, "f" pro hřídel).
# - `grade::Integer`: Stupeň tolerance (např. 7, 8, 9).
## Výstupní proměnné:
# - `nominal`: Jmenovitý rozměr v mm.
# - `zone`: Zóna tolerance.
# - `grade`: Stupeň tolerance.
# - `type`: Typ tolerance (:hole pro díru, :shaft pro hřídel).
# - `es`: Horní mez tolerance (v mm).
# - `ei`: Dolní mez tolerance (v mm).
# - `min`: Minimální rozměr (v mm).
# - `max`: Maximální rozměr (v mm).
# - `tol`: Tolerance (v mm).
# - `unit`: Jednotka (vždy "mm").
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
using TOML

const TOL_DB = TOML.parsefile(joinpath(@__DIR__, "tolerance_data.toml"))

"""
    tolerance(spec::AbstractString)

Vrátí toleranci podle zápisu např. "40H8" nebo "10f7".
"""
function tolerance(spec::AbstractString)
    s = replace(strip(spec), "," => ".") # nahrazení čárky tečkou pro desetinné číslo
    s = replace(s, " " => "") # odstranění mezer
    rx = r"^(\d+(?:\.\d+)?)([A-Za-z]+)(\d+)$" # regex pro rozdělení na jmenovitý rozměr, zónu a stupeň
    m = match(rx, s) # regex pro rozdělení na jmenovitý rozměr, zónu a stupeň
    m === nothing && error("Neplatné označení tolerance: '$spec'") # kontrola, zda regex odpovídá vstupu

    nominal = parse(Float64, m.captures[1]) # převod jmenovitého rozměru na Float64
    zone = m.captures[2] # zóna (např. "H" nebo "f")
    grade = parse(Int, m.captures[3]) # převod stupně na Int

    return tolerance(nominal, zone, grade)
end

"""
    tolerance(nominal::Real, zone::AbstractString, grade::Integer)

Vrátí toleranci pro zadaný jmenovitý rozměr, zónu a stupeň.
"""
function tolerance(nominal::Real, zone::AbstractString, grade::Integer)
    nominal = Float64(nominal) # převod jmenovitého rozměru na Float64
    zone = strip(zone) # odstranění mezer ze zóny

    is_hole = all(isuppercase, zone)
    is_shaft = all(islowercase, zone)
    (is_hole || is_shaft) || error("Zóna musí být velká (díra) nebo malá (hřídel).")

    size_key = find_size_key(nominal)

    it = get_it(size_key, grade)
    dev = get_fundamental_deviation(size_key, zone, it)

    ei = dev.ei
    es = dev.es

    minv = nominal + ei
    maxv = nominal + es

    return (
        nominal = nominal,
        zone = zone,
        grade = grade,
        type = is_hole ? :hole : :shaft,
        es = es,
        ei = ei,
        min = minv,
        max = maxv,
        tol = es - ei,
        unit = "mm"
    )
end

function find_size_key(nominal::Float64)
    for key in TOL_DB["sizes"]
        a, b = parse.(Float64, split(key, "-"))
        if nominal > a && nominal <= b
            return key
        end
    end
    error("Rozměr $(nominal) mm je mimo rozsah tabulky.")
end

function get_it(size_key::AbstractString, grade::Int)
    table = TOL_DB["IT"][size_key]
    key = string(grade)
    haskey(table, key) || error("IT$(grade) není v tabulce pro rozsah $(size_key).")
    return table[key]
end

function get_fundamental_deviation(size_key::AbstractString, zone::AbstractString, it::Float64)
    table = TOL_DB["fundamental"][size_key]
    haskey(table, zone) || error("Zóna $(zone) není v tabulce pro rozsah $(size_key).")
    row = table[zone]

    es = row["es"]
    ei = row["ei"]

    # Pokud jsou v tabulce uloženy relativní hodnoty (např. 0 a IT),
    # dovolíme symbolické hodnoty.
    if es == "IT"
        es = it
    elseif es == "-IT"
        es = -it
    end

    if ei == "IT"
        ei = it
    elseif ei == "-IT"
        ei = -it
    end

    return (es = es, ei = ei)
end
