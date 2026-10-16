# ver: 2026-10-16
## Funkce: materialy()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/materialy/materialy.jl
## Použité balíčky:
# SQLite
## Použité uživatelské funkce:
# materialytypes.jl, materialy.db
###############################################################
## Použité proměnné vnitřní:
#
using SQLite

"""
$(read(joinpath(@__DIR__, "..", "..", "docs", "src", "materialy", "materialy.md"), String))
"""
function materialy(name::AbstractString)

    include(joinpath(@__DIR__, "materialytypes.jl"))
    construct = (type, args...) -> Base.invokelatest(
        Base.invokelatest(getfield, @__MODULE__, type), args...)
    tofloat = value -> ismissing(value) ? missing : Float64(value)

    db_path = joinpath(StrojniSoucasti.cesta_materialy, "materialy.db")
    DB = SQLite.DB(db_path) # Načte databázi
    # ------------------------------------------------------------
    nalez = false
    VVdruh = "-"
    if nalez == false
        VV = StrojniSoucasti.materialyCSN(DB, name)
        if VV !== nothing
            nalez = true
            VVdruh = "ČSN"
        end
    end

    if nalez == false
        VV = StrojniSoucasti.materialyEN(DB, name)
        if VV !== nothing
            nalez = true
            VVdruh = "EN"
        end
    end

    if nalez == false
        VV = StrojniSoucasti.materialyDIN(DB, name)
        if VV !== nothing
            nalez = true
            VVdruh = "DIN"
        end
    end

    if nalez == false
        VV = StrojniSoucasti.materialyISO(DB, name)
        if VV !== nothing
            nalez = true
            VVdruh = "ISO"
        end
    end

    if nalez == false
        VV = StrojniSoucasti.materialyObecne(DB, name)
        if VV !== nothing
            nalez = true
            VVdruh = "Obecné"
        end
    end

    if VV !== nothing
        if get(VV, "druh", "") in ["konstrukční ocel", "ocel", "nástrojová ocel", 
            "nerezová ocel", "legovaná ocel", "uhlíková ocel", 
            "ocel pro tepelné zpracování", "ocel na odlitky", "ocel na pružiny", 
            "ocel na ložiska", "ocel na kolejnice", "ocel na dráty", "ocel na plechy", 
            "ocel na trubky", "ocel na tyče", "ocel na profily"]
            return construct(:MaterialOcel,
                VVdruh == "ČSN" ? get(VV, "name_CSN", name)::String : 
                VVdruh == "EN" ? get(VV, "name_EN", name)::String : 
                VVdruh == "DIN" ? get(VV, "name_DIN", name)::String : 
                VVdruh == "ISO" ? get(VV, "name_ISO", name)::String : 
                VVdruh == "Obecné" ? get(VV, "name", name)::String : name::String, # název materiálu
                get(VV, "name", "")::String, # název materiálu
                get(VV, "name_ISO", "")::String, # název materiálu
                get(VV, "name_CSN", "")::String, # název materiálu
                get(VV, "name_DIN", "")::String, # název materiálu DIN
                get(VV, "cislo_EN", "")::String, # název materiálu EN
                get(VV, "znacka_EN", "")::String, # název materiálu DIN
                get(VV, "norma_CSN", "")::String, # norma (nepovinné)
                get(VV, "druh", "")::String, # norma (nepovinné)
                tofloat(get(VV, "Re", 0)), # meze kluzu
                "MPa", # jednotka meze kluzu
                tofloat(get(VV, "Rm_min", 0)), # meze pevnosti
                "MPa", # jednotka meze pevnosti
                tofloat(get(VV, "Rm_max", 0)), # meze pevnosti max
                "MPa", # jednotka meze pevnosti max
                tofloat(get(VV, "A", 0)), # prodloužení
                "%", # jednotka prodloužení
                tofloat(get(VV, "KV", 0)), # houževnatost KV
                "J", # jednotka houževnatosti KV
                tofloat(get(VV, "T_KV", 0)), # teplota KV
                "°C", # jednotka teploty KV
                get(VV, "svaritelnost", "")::String, # popis svařitelnosti
                Bool(get(VV, "weldable", false)), # svařitelnost
                tofloat(get(VV, "thickness_max", 0)), # max tloušťka
                "mm", # jednotka max tloušťky
                tofloat(get(VV, "E", 0)), # modul pružnosti
                "GPa", # jednotka modulu pružnosti
                tofloat(get(VV, "G", 0)), # modul smyku
                "GPa", # jednotka modulu smyku
                tofloat(get(VV, "ny", 0)), # Poissonovo číslo
                "-", # jednotka Poissonova čísla
                tofloat(get(VV, "rho", 0)), # hustota
                "kg/m^3" # jednotka hustoty
            )
        elseif get(VV, "druh", "") in ["šedá litina", "litina", "tvárná litina", 
            "spheroidalní litina", "šedá litina s kuličkovým grafitem", 
            "tvárná litina s kuličkovým grafitem", "šedá litina s lamelárním grafitem", 
            "tvárná litina s lamelárním grafitem"]
            return construct(:MaterialLitina,
                VVdruh == "ČSN" ? get(VV, "name_CSN", name)::String : 
                VVdruh == "EN" ? get(VV, "name_EN", name)::String : 
                VVdruh == "DIN" ? get(VV, "name_DIN", name)::String : 
                VVdruh == "ISO" ? get(VV, "name_ISO", name)::String : 
                VVdruh == "Obecné" ? get(VV, "name", name)::String : name::String, # název materiálu
                get(VV, "name", name)::String, # název materiálu
                get(VV, "name_ISO", name)::String, # název materiálu
                get(VV, "name_CSN", name)::String, # název materiálu
                get(VV, "name_DIN", "")::String, # název materiálu DIN
                get(VV, "cislo_EN", "")::String, # název materiálu EN
                get(VV, "znacka_EN", "")::String, # název materiálu DIN
                get(VV, "norma_CSN", "")::String, # norma (nepovinné)
                get(VV, "druh", "")::String, # typ litiny
                tofloat(get(VV, "Rm_tah", 0)), # mez pevnosti v tahu
                "MPa", # jednotka meze pevnosti v tahu
                tofloat(get(VV, "Rm_tlak", 0)), # mez pevnosti v tlaku
                "MPa", # jednotka meze pevnosti v tlaku
                tofloat(get(VV, "tau_lim", 0.5 * tofloat(get(VV, "Rm_tah", 0)))), # mez smykové pevnosti
                "MPa", # jednotka meze smykové pevnosti
                tofloat(get(VV, "A", 0)), # prodloužení
                "%", # jednotka prodloužení
                tofloat(get(VV, "HB_min", 0)), # tvrdost Brinell min
                "HB", # jednotka tvrdosti Brinell min
                tofloat(get(VV, "HB_max", 0)), # tvrdost Brinell max
                "HB", # jednotka tvrdosti Brinell max
                tofloat(get(VV, "E", 0)), # modul pružnosti
                "GPa", # jednotka modulu pružnosti
                tofloat(get(VV, "G", 0)), # modul smyku
                "GPa", # jednotka modulu smyku
                tofloat(get(VV, "ny", 0)), # Poissonovo číslo
                "-", # jednotka Poissonova čísla
                tofloat(get(VV, "rho", 0)), # hustota
                "kg/m^3" # jednotka hustoty
            )
        elseif get(VV, "druh", "") in ["Slitina mědi", "Elektrolytická měď", "Měď", 
            "Slitina hliníku", "Hliník", "Slitina titanu", "Titan", "Slitina zinku", 
            "Zinek", "Slitina niklu", "Niklová slitina", "Slitina cínu", "Cín",
            "Slitina olova", "Olovo", "Slitina wolframu", "Wolfram", "Slitina kobaltu", 
            "Kobalt", "Slitina zirkonia",]
            return construct(:MaterialNezelezneKovy,
                VVdruh == "ČSN" ? get(VV, "name_CSN", name)::String : 
                VVdruh == "EN" ? get(VV, "name_EN", name)::String : 
                VVdruh == "DIN" ? get(VV, "name_DIN", name)::String : 
                VVdruh == "ISO" ? get(VV, "name_ISO", name)::String : 
                VVdruh == "Obecné" ? get(VV, "name", name)::String : name::String, # název materiálu
                get(VV, "name", name)::String, # název materiálu
                get(VV, "name_ISO", name)::String, # název materiálu
                get(VV, "name_CSN", name)::String, # název materiálu
                get(VV, "name_DIN", "")::String, # název materiálu DIN
                get(VV, "cislo_EN", "")::String, # název materiálu EN
                get(VV, "znacka_EN", "")::String, # název materiálu DIN
                get(VV, "standard", "")::String, # norma
                get(VV, "druh", "")::String, # druh kovu
                tofloat(get(VV, "Rp0_2", 0)), # mez kluzu
                "MPa", # jednotka meze kluzu
                tofloat(get(VV, "Rm_min", 0)), # minimální mez pevnosti
                "MPa", # jednotka minimální meze pevnosti
                tofloat(get(VV, "Rm_max", 0)), # maximální mez pevnosti
                "MPa", # jednotka maximální meze pevnosti
                tofloat(get(VV, "A", 0)), # prodloužení
                "%", # jednotka prodloužení
                tofloat(get(VV, "E", 0)), # modul pružnosti
                "GPa", # jednotka modulu pružnosti
                tofloat(get(VV, "G", 0)), # modul smyku
                "GPa", # jednotka modulu smyku
                tofloat(get(VV, "ny", 0)), # Poissonovo číslo
                "-", # jednotka Poissonova čísla
                tofloat(get(VV, "rho", 0)), # hustota
                "kg/m^3" # jednotka hustoty
            )
        elseif get(VV, "druh", "") in ["pryž", "guma", "kaučuk", "NBR", "EPDM", 
            "SBR", "NR", "CR", "IIR", "FPM", "VMQ"]
            return construct(:MaterialPryz,
                VVdruh == "ČSN" ? get(VV, "name_CSN", name)::String : 
                VVdruh == "EN" ? get(VV, "name_EN", name)::String : 
                VVdruh == "DIN" ? get(VV, "name_DIN", name)::String : 
                VVdruh == "ISO" ? get(VV, "name_ISO", name)::String : 
                VVdruh == "Obecné" ? get(VV, "name", name)::String : name::String, # název materiálu
                get(VV, "name", name)::String, # název materiálu
                get(VV, "name_ISO", name)::String, # název materiálu
                get(VV, "name_CSN", name)::String, # název materiálu
                get(VV, "name_DIN", "")::String, # název materiálu DIN
                get(VV, "cislo_EN", "")::String, # název materiálu EN
                get(VV, "znacka_EN", "")::String, # název materiálu DIN
                get(VV, "norma_CSN", "")::String, # norma (nepovinné)
                get(VV, "druh", "")::String, # typ pryžového materiálu
                tofloat(get(VV, "hardness", 0)), # tvrdost Shore A
                get(VV, "hardness_unit", "ShA")::String, # jednotka tvrdosti
                tofloat(get(VV, "E", 0)), # modul pružnosti
                get(VV, "E_unit", "GPa")::String, # jednotka modulu pružnosti
                tofloat(get(VV, "G", 0)), # modul smyku
                get(VV, "G_unit", "GPa")::String, # jednotka modulu smyku
                tofloat(get(VV, "ny", 0)), # Poissonovo číslo
                get(VV, "ny_unit", "-")::String, # jednotka Poissonova čísla
                tofloat(get(VV, "rho", 0)), # hustota
                get(VV, "rho_unit", "kg/m^3")::String # jednotka hustoty
            )
        elseif get(VV, "druh", "") in ["plast", "polymer", "PE", "PP", "PVC", 
            "PS", "ABS", "PA", "POM", "PMMA", "PC"]
            return construct(:MaterialPlast,
                VVdruh == "ČSN" ? get(VV, "name_CSN", name)::String : 
                VVdruh == "EN" ? get(VV, "name_EN", name)::String : 
                VVdruh == "DIN" ? get(VV, "name_DIN", name)::String : 
                VVdruh == "ISO" ? get(VV, "name_ISO", name)::String : 
                VVdruh == "Obecné" ? get(VV, "name", name)::String : name::String, # název materiálu
                get(VV, "name", name)::String, # název materiálu
                get(VV, "name_ISO", name)::String, # název materiálu
                get(VV, "name_CSN", name)::String, # název materiálu
                get(VV, "name_DIN", "")::String, # název materiálu DIN
                get(VV, "cislo_EN", "")::String, # název materiálu EN
                get(VV, "znacka_EN", "")::String, # název materiálu DIN
                get(VV, "norma_CSN", "")::String, # norma (nepovinné)
                get(VV, "druh", "")::String, # typ plastového materiálu
                tofloat(get(VV, "E", 0)), # modul pružnosti
                "GPa", # jednotka modulu pružnosti
                tofloat(get(VV, "G", 0)), # modul smyku
                "GPa", # jednotka modulu smyku
                tofloat(get(VV, "ny", 0)), # Poissonovo číslo
                "-", # jednotka Poissonova čísla
                tofloat(get(VV, "rho", 0)), # hustota
                "kg/m^3" # jednotka hustoty
            )
        else
            return nothing
        end
    end
    SQLite.close(DB)
    # ------------------------------------------------------------
    return nothing
end
