# ver: 2026-10-11
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

"""
$(read(joinpath(@__DIR__, "..", "..", "docs", "src", "materialy", "materialy.md"), String))
"""
function materialy(name::AbstractString)

    include(joinpath(@__DIR__, "materialytypes.jl"))
    construct = (type, args...) -> Base.invokelatest(
        Base.invokelatest(getfield, @__MODULE__, type), args...)

    db_path = joinpath(StrojniSoucasti.cesta_materialy, "materialy.db")
    DB = SQLite.DB(db_path) # Načte databázi závitů, pokud ještě nebyla načtena
    # ------------------------------------------------------------
    # ČSN materiály
    VV = StrojniSoucasti.materialyCSN(DB, name)
    if VV !== nothing
        if get(VV, "druh", "") in ["konstrukční ocel", "ocel", "nástrojová ocel", 
            "nerezová ocel", "legovaná ocel", "uhlíková ocel", 
            "ocel pro tepelné zpracování", "ocel na odlitky", "ocel na pružiny", 
            "ocel na ložiska", "ocel na kolejnice", "ocel na dráty", "ocel na plechy", 
            "ocel na trubky", "ocel na tyče", "ocel na profily"]
            return construct(:MaterialOcel,
                get(VV, "name_CSN", name)::String, # název materiálu
                get(VV, "norma", "")::String, # norma (nepovinné)
                get(VV, "druh", "")::String, # norma (nepovinné)
                Float64(get(VV, "Re", 0)), # meze kluzu
                "MPa", # jednotka meze kluzu
                Float64(get(VV, "Rm_min", 0)), # meze pevnosti
                "MPa", # jednotka meze pevnosti
                Float64(get(VV, "Rm_max", 0)), # meze pevnosti max
                "MPa", # jednotka meze pevnosti max
                Float64(get(VV, "A", 0)), # prodloužení
                "%", # jednotka prodloužení
                Float64(get(VV, "KV", 0)), # houževnatost KV
                "J", # jednotka houževnatosti KV
                Float64(get(VV, "T_KV", 0)), # teplota KV
                "°C", # jednotka teploty KV
                get(VV, "svaritelnost", "")::String, # popis svařitelnosti
                Bool(get(VV, "weldable", false)), # svařitelnost
                Float64(get(VV, "thickness_max", 0)), # max tloušťka
                "mm", # jednotka max tloušťky
                Float64(get(VV, "E", 0)), # modul pružnosti
                "GPa", # jednotka modulu pružnosti
                Float64(get(VV, "G", 0)), # modul smyku
                "GPa", # jednotka modulu smyku
                Float64(get(VV, "ny", 0)), # Poissonovo číslo
                "-", # jednotka Poissonova čísla
                Float64(get(VV, "rho", 0)), # hustota
                "kg/m^3" # jednotka hustoty
            )
        elseif get(VV, "druh", "") in ["šedá litina", "litina", "tvárná litina", 
            "spheroidalní litina", "šedá litina s kuličkovým grafitem", 
            "tvárná litina s kuličkovým grafitem", "šedá litina s lamelárním grafitem", 
            "tvárná litina s lamelárním grafitem"]
            return construct(:MaterialLitina,
                get(VV, "name_CSN", name)::String, # název materiálu
                get(VV, "norma", "")::String, # norma (nepovinné)
                get(VV, "druh", "")::String, # typ litiny
                Float64(get(VV, "Rm_tah", 0)), # mez pevnosti v tahu
                "MPa", # jednotka meze pevnosti v tahu
                Float64(get(VV, "Rm_tlak", 0)), # mez pevnosti v tlaku
                "MPa", # jednotka meze pevnosti v tlaku
                Float64(get(VV, "tau_lim", 0.5 * Float64(get(VV, "Rm_tah", 0)))), # mez smykové pevnosti
                "MPa", # jednotka meze smykové pevnosti
                Float64(get(VV, "A", 0)), # prodloužení
                "%", # jednotka prodloužení
                Float64(get(VV, "HB_min", 0)), # tvrdost Brinell min
                "HB", # jednotka tvrdosti Brinell min
                Float64(get(VV, "HB_max", 0)), # tvrdost Brinell max
                "HB", # jednotka tvrdosti Brinell max
                Float64(get(VV, "E", 0)), # modul pružnosti
                "GPa", # jednotka modulu pružnosti
                Float64(get(VV, "G", 0)), # modul smyku
                "GPa", # jednotka modulu smyku
                Float64(get(VV, "ny", 0)), # Poissonovo číslo
                "-", # jednotka Poissonova čísla
                Float64(get(VV, "rho", 0)), # hustota
                "kg/m^3" # jednotka hustoty
            )
        elseif get(VV, "druh", "") in ["Slitina mědi", "Elektrolytická měď", "Měď", 
            "Slitina hliníku", "Hliník", "Slitina titanu", "Titan", "Slitina zinku", 
            "Zinek", "Slitina niklu", "Niklová slitina", "Slitina cínu", "Cín",
            "Slitina olova", "Olovo", "Slitina wolframu", "Wolfram", "Slitina kobaltu", 
            "Kobalt", "Slitina zirkonia",]
            return construct(:MaterialNezelezneKovy,
                String(strip(name)), # název materiálu
                get(VV, "standard", "")::String, # norma
                get(VV, "druh", "")::String, # druh kovu
                Float64(get(VV, "Rp0_2", 0)), # mez kluzu
                "MPa", # jednotka meze kluzu
                Float64(get(VV, "Rm_min", 0)), # minimální mez pevnosti
                "MPa", # jednotka minimální meze pevnosti
                Float64(get(VV, "Rm_max", 0)), # maximální mez pevnosti
                "MPa", # jednotka maximální meze pevnosti
                Float64(get(VV, "A", 0)), # prodloužení
                "%", # jednotka prodloužení
                Float64(get(VV, "E", 0)), # modul pružnosti
                "GPa", # jednotka modulu pružnosti
                Float64(get(VV, "G", 0)), # modul smyku
                "GPa", # jednotka modulu smyku
                Float64(get(VV, "ny", 0)), # Poissonovo číslo
                "-", # jednotka Poissonova čísla
                Float64(get(VV, "rho", 0)), # hustota
                "kg/m^3" # jednotka hustoty
            )
        elseif get(VV, "druh", "") in ["pryž", "guma", "kaučuk", "NBR", "EPDM", 
            "SBR", "NR", "CR", "IIR", "FPM", "VMQ"]
            return construct(:MaterialPryz,
                get(VV, "name_CSN", name)::String, # název materiálu
                get(VV, "norma", "")::String, # norma (nepovinné)
                get(VV, "druh", "")::String, # typ pryžového materiálu
                Float64(get(VV, "E", 0)), # modul pružnosti
                "GPa", # jednotka modulu pružnosti
                Float64(get(VV, "G", 0)), # modul smyku
                "GPa", # jednotka modulu smyku
                Float64(get(VV, "ny", 0)), # Poissonovo číslo
                "-", # jednotka Poissonova čísla
                Float64(get(VV, "rho", 0)), # hustota
                "kg/m^3" # jednotka hustoty
            )
        elseif get(VV, "druh", "") in ["plast", "polymer", "PE", "PP", "PVC", 
            "PS", "ABS", "PA", "POM", "PMMA", "PC"]
            return construct(:MaterialPlast,
                get(VV, "name_CSN", name)::String, # název materiálu
                get(VV, "norma", "")::String, # norma (nepovinné)
                get(VV, "druh", "")::String, # typ plastového materiálu
                Float64(get(VV, "E", 0)), # modul pružnosti
                "GPa", # jednotka modulu pružnosti
                Float64(get(VV, "G", 0)), # modul smyku
                "GPa", # jednotka modulu smyku
                Float64(get(VV, "ny", 0)), # Poissonovo číslo
                "-", # jednotka Poissonova čísla
                Float64(get(VV, "rho", 0)), # hustota
                "kg/m^3" # jednotka hustoty
            )
        else
            return nothing
        end
    end
    # ------------------------------------------------------------
    # Databáze materiálů
    MATERIALY_DB_OCEL_EN10025_2 = TOML.parsefile(joinpath(cesta_materialy, 
    "materialydatabaseOcelEN10025_2.toml"))
    MATERIALY_DB_PRYZ = TOML.parsefile(joinpath(cesta_materialy,
    "materialydatabasePryz.toml"))

    name = uppercase(strip(name)) # velká písmena
    name = replace(name, r"\s+" => "")   # odstranění všech mezer
    
    if haskey(MATERIALY_DB_OCEL_EN10025_2, name) # materiál existuje v databázi
    
        row = MATERIALY_DB_OCEL_EN10025_2[name]
        return construct(:MaterialOcel,
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
    elseif haskey(MATERIALY_DB_PRYZ, name) # materiál existuje v databázi pryží

        row = MATERIALY_DB_PRYZ[name]
        return construct(:MaterialPryz,
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
