# ver: 2026-08-27
## Funkce: tolerance()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/tolerance/tolerance.jl
## Použité balíčky:
#
## Použité uživatelské funkce:
#
###############################################################
## Použité proměnné vnitřní:
#

const _tolerance_NAPOVEDA = read(
    joinpath(@__DIR__, "..", "..", "docs", "src", "tolerance", "tolerance.md"),
    String,
)
"""
$_tolerance_NAPOVEDA
"""
function tolerance(spec::AbstractString)
#---------------------------------------------------------------------
# pomocné funkce
#---------------------------------------------------------------------
# pomocné funkce konec
    s = replace(strip(spec), "," => ".") # nahrazení čárky tečkou pro desetinné číslo
    s = replace(s, " " => "") # odstranění mezer
    VV = StrojniSoucasti.toleranceISOlicovani(s)

    return VV

end
