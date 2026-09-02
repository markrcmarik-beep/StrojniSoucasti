# ver: 2026-08-27
## Funkce: materialy()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/materialy/materialy.jl
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
# materialytypes.jl, materialydatabase.toml
###############################################################
## Použité proměnné vnitřní:
#
using TOML

const _materialy_NAPOVEDA = read(
    joinpath(@__DIR__, "..", "..", "docs", "src", "materialy", "materialy.md"),
    String,
)
"""
$_materialy_NAPOVEDA
"""
function materialy(name::AbstractString)::Union{MaterialOcel,
    MaterialKovy,
    MaterialLitina,
    MaterialPryz,
    Nothing}

    MATERIALY_DB_OCEL_EN10025_2 = TOML.parsefile(joinpath(@__DIR__, 
    "materialydatabaseOcelEN10025_2.toml"))
    MATERIALY_DB_OCEL_CSN = TOML.parsefile(joinpath(@__DIR__, 
    "materialydatabaseOcelCSN.toml"))
    MATERIALY_DB_KOVY_CSN = TOML.parsefile(joinpath(@__DIR__, 
    "materialydatabaseKovyCSN.toml"))
    MATERIALY_DB_LITINA_CSN = TOML.parsefile(joinpath(@__DIR__,
    "materialydatabaseLitinaCSN.toml"))
    MATERIALY_DB_PRYZ = TOML.parsefile(joinpath(@__DIR__,
    "materialydatabasePryz.toml"))

    name = uppercase(strip(name)) # velká písmena
    name = replace(name, r"\s+" => "")   # odstranění všech mezer
    
    if haskey(MATERIALY_DB_OCEL_EN10025_2, name) # materiál existuje v databázi
    
        row = MATERIALY_DB_OCEL_EN10025_2[name]
        return MaterialOcel(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
        get(row, "druh", "")::String, # norma (nepovinné)
        Float64(get(row, "Re", 0)), # meze kluzu
        "MPa", # jednotka meze kluzu
        Float64(get(row, "Rm_min", 0)), # meze pevnosti
        "MPa", # jednotka meze pevnosti
        Float64(get(row, "Rm_max", 0)), # meze pevnosti max
        "MPa", # jednotka meze pevnosti max
        Float64(get(row, "A", 0)), # prodloužení
        "%", # jednotka prodloužení
        Float64(get(row, "KV", 0)), # houževnatost KV
        "J", # jednotka houževnatosti KV
        Float64(get(row, "T_KV", 0)), # teplota KV
        "°C", # jednotka teploty KV
        get(row, "svaritelnost", "")::String, # popis svařitelnosti
        Bool(get(row, "weldable", false)), # svařitelnost
        Float64(get(row, "thickness_max", 0)), # max tloušťka
        "mm", # jednotka max tloušťky
        Float64(get(row, "E", 0)), # modul pružnosti
        "GPa", # jednotka modulu pružnosti
        Float64(get(row, "G", 0)), # modul smyku
        "GPa", # jednotka modulu smyku
        Float64(get(row, "ny", 0)), # Poissonovo číslo
        "-", # jednotka Poissonova čísla
        Float64(get(row, "rho", 0)), # hustota
        "kg/m^3" # jednotka hustoty
    )
    elseif haskey(MATERIALY_DB_OCEL_CSN, name) # materiál existuje v databázi ČSN ocelí
        
        row = MATERIALY_DB_OCEL_CSN[name]
        return MaterialOcel(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
        get(row, "druh", "")::String, # norma (nepovinné)
        Float64(get(row, "Re", 0)), # meze kluzu
        "MPa", # jednotka meze kluzu
        Float64(get(row, "Rm_min", 0)), # meze pevnosti
        "MPa", # jednotka meze pevnosti
        Float64(get(row, "Rm_max", 0)), # meze pevnosti max
        "MPa", # jednotka meze pevnosti max
        Float64(get(row, "A", 0)), # prodloužení
        "%", # jednotka prodloužení
        Float64(get(row, "KV", 0)), # houževnatost KV
        "J", # jednotka houževnatosti KV
        Float64(get(row, "T_KV", 0)), # teplota KV
        "°C", # jednotka teploty KV
        get(row, "svaritelnost", "")::String, # popis svařitelnosti
        Bool(get(row, "weldable", false)), # svařitelnost
        Float64(get(row, "thickness_max", 0)), # max tloušťka
        "mm", # jednotka max tloušťky
        Float64(get(row, "E", 0)), # modul pružnosti
        "GPa", # jednotka modulu pružnosti
        Float64(get(row, "G", 0)), # modul smyku
        "GPa", # jednotka modulu smyku
        Float64(get(row, "ny", 0)), # Poissonovo číslo
        "-", # jednotka Poissonova čísla
        Float64(get(row, "rho", 0)), # hustota
        "kg/m^3" # jednotka hustoty
    )
    elseif haskey(MATERIALY_DB_KOVY_CSN, name) # materiál existuje v databázi ČSN kovů
        
        row = MATERIALY_DB_KOVY_CSN[name]
        return MaterialKovy(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
        get(row, "druh", "")::String, # norma (nepovinné)
        Float64(get(row, "Re", 0)), # meze kluzu
        "MPa", # jednotka meze kluzu
        Float64(get(row, "Rm_min", 0)), # meze pevnosti
        "MPa", # jednotka meze pevnosti
        Float64(get(row, "Rm_max", 0)), # meze pevnosti max
        "MPa", # jednotka meze pevnosti max
        Float64(get(row, "A", 0)), # prodloužení
        "%", # jednotka prodloužení
        Float64(get(row, "E", 0)), # modul pružnosti
        "GPa", # jednotka modulu pružnosti
        Float64(get(row, "G", 0)), # modul smyku
        "GPa", # jednotka modulu smyku
        Float64(get(row, "ny", 0)), # Poissonovo číslo
        "-", # jednotka Poissonova čísla
        Float64(get(row, "rho", 0)), # hustota
        "kg/m^3" # jednotka hustoty
    )
    elseif haskey(MATERIALY_DB_LITINA_CSN, name) # materiál existuje v databázi ČSN litin

        row = MATERIALY_DB_LITINA_CSN[name]
        return MaterialLitina(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
        get(row, "druh", "")::String, # typ litiny
        Float64(get(row, "Rm_tah", 0)), # mez pevnosti v tahu
        "MPa", # jednotka meze pevnosti v tahu
        Float64(get(row, "Rm_tlak", 0)), # mez pevnosti v tlaku
        "MPa", # jednotka meze pevnosti v tlaku
        Float64(get(row, "tau_lim", 0.5 * Float64(get(row, "Rm_tah", 0)))), # mez smykové pevnosti
        "MPa", # jednotka meze smykové pevnosti
        Float64(get(row, "A", 0)), # prodloužení
        "%", # jednotka prodloužení
        Float64(get(row, "HB_min", 0)), # tvrdost Brinell min
        "HB", # jednotka tvrdosti Brinell min
        Float64(get(row, "HB_max", 0)), # tvrdost Brinell max
        "HB", # jednotka tvrdosti Brinell max
        Float64(get(row, "E", 0)), # modul pružnosti
        "GPa", # jednotka modulu pružnosti
        Float64(get(row, "G", 0)), # modul smyku
        "GPa", # jednotka modulu smyku
        Float64(get(row, "ny", 0)), # Poissonovo číslo
        "-", # jednotka Poissonova čísla
        Float64(get(row, "rho", 0)), # hustota
        "kg/m^3" # jednotka hustoty
    )
    elseif haskey(MATERIALY_DB_PRYZ, name) # materiál existuje v databázi pryží

        row = MATERIALY_DB_PRYZ[name]
        return MaterialPryz(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
        get(row, "druh", "")::String, # druh pryže
        Float64(get(row, "hardness", 0)), # tvrdost
        "ShA", # jednotka tvrdosti
        Float64(get(row, "E", 0)), # modul pružnosti
        "MPa", # jednotka modulu pružnosti
        Float64(get(row, "G", 0)), # modul smyku
        "MPa", # jednotka modulu smyku
        Float64(get(row, "ny", 0)), # Poissonovo číslo
        "-", # jednotka Poissonova čísla
        Float64(get(row, "rho", 0)), # hustota
        "kg/m^3" # jednotka hustoty
    )
    #else
    #    return nothing
    end
    return nothing
end
