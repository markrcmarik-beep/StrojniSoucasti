# ver: 2026-08-25
## Funkce: parse_numeric_smart()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/parse_numeric_smart.jl
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
#
###############################################################
## Použité proměnné vnitřní:
#
function parse_numeric_smart(s::AbstractString)
    s = replace(s, "," => ".")
    f_val = parse(Float64, s)
    if isinteger(f_val)
        return Int(f_val)
    else
        return f_val
    end
end
