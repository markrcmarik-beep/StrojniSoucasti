# ver: 2026-08-07
## Funkce: tolerance()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/tolerance/tolerance.jl
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
#
###############################################################
## Použité proměnné vnitřní:
#
using TOML

const _tolerance_NAPOVEDA = read(
    joinpath(@__DIR__, "..", "..", "docs", "src", "tolerance", "tolerance.md"),
    String,
)
"""
$_tolerance_NAPOVEDA
"""
function tolerance(spec::AbstractString)
    s = replace(strip(spec), "," => ".") # nahrazení čárky tečkou pro desetinné číslo
    s = replace(s, " " => "") # odstranění mezer
    rx = r"^(\d+(?:\.\d+)?)([A-Za-z]+)(\d+)$" # regex pro rozdělení na jmenovitý rozměr, zónu a stupeň
    m = match(rx, s) # regex pro rozdělení na jmenovitý rozměr, zónu a stupeň

    if m !== nothing
        nominal = parse(Float64, m.captures[1]) # převod jmenovitého rozměru na Float64
        zone = m.captures[2] # zóna (např. "H" nebo "f")
        grade = m.captures[3] # stupeň
        VV = toleranceISOlicovani(nominal, zone, grade)
    else
        error("Neplatné označení tolerance: '$spec'")
    end

    return VV
end
