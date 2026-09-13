## Funkce Julia v1.12
###############################################################
## Popis funkce:
#
# ver: 2026-09-10
## Funkce: _materialy_nacist()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/materialy/_materialy_nacist.jl
#
## Vzor:
## vystupni_promenne = _materialy_nacist(vstupni_promenne)
## Vstupní proměnné:
#
## Výstupní proměnné:
#
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
function _materialy_nacist(druh::String, args...)::Union{MaterialOcel,
    MaterialLitina,
    MaterialKovy,
    Nothing}
    delka = length(args)
    VV = nothing
    tabl = false
    if delka == 4
    argum1 = args[1]
    if length(argum1) == 2
        if !(argum1 isa Tuple{Dict{String, Any}, String})
            error("První argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String}.")
        end
        MATERIALY_DB_01, oznaceni01 = argum1
        if haskey(MATERIALY_DB_01, oznaceni01) # materiál existuje v databázi
            row01 = MATERIALY_DB_01[oznaceni01]
            tabl = true
        end
    elseif length(argum1) ==3
        if !(argum1 isa Tuple{Dict{String, Any}, String, String})
            error("První argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String, String}.")
        end
        MATERIALY_DB_01, oznaceni01, oznaceni01_2 = argum1
        if haskey(MATERIALY_DB_01, oznaceni01) # materiál existuje v databázi
            skupina01 = MATERIALY_DB_01[oznaceni01]
            if haskey(skupina01, oznaceni01_2)
                row01 = skupina01[oznaceni01_2]
                tabl = true
            end
        end
    else
        error("První argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String} Tuple{Dict{String, Any}, String, String}.")
    end
    argum2 = args[2]
    if length(argum2) == 2
        if !(argum2 isa Tuple{Dict{String, Any}, String})
            error("Druhý argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String}.")
        end
        MATERIALY_DB_02, oznaceni02 = argum2
        if haskey(MATERIALY_DB_02, oznaceni02)
            row02 = MATERIALY_DB_02[oznaceni02]
        else
            row02 = Dict{String, Any}()
        end
    end
    argum3 = args[3]
    if length(argum3) == 2
        if !(argum3 isa Tuple{Dict{String, Any}, String})
            error("Třetí argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String}.")
        end
    MATERIALY_DB_03, oznaceni03 = argum3
        if haskey(MATERIALY_DB_03, oznaceni03)
            row03 = MATERIALY_DB_03[oznaceni03]
        else
            row03 = Dict{String, Any}()
        end
    end
    argum4 = args[4]
    if length(argum4) == 2
        if !(argum4 isa Tuple{Dict{String, Any}, String})
            error("Čtvrtý argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String}.")
        end
        MATERIALY_DB_04, oznaceni04 = argum4
        if haskey(MATERIALY_DB_04, oznaceni04)
            row04 = MATERIALY_DB_04[oznaceni04]
        else
            row04 = Dict{String, Any}()
        end
    end
    elseif delka == 3
    argum1 = args[1]
    if length(argum1) == 2
        if !(argum1 isa Tuple{Dict{String, Any}, String})
            error("První argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String}.")
        end
        MATERIALY_DB_01, oznaceni01 = argum1
        if haskey(MATERIALY_DB_01, oznaceni01) # materiál existuje v databázi
            row01 = MATERIALY_DB_01[oznaceni01]
            tabl = true
        end
    elseif length(argum1) ==3
        if !(argum1 isa Tuple{Dict{String, Any}, String, String})
            error("První argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String, String}.")
        end
        MATERIALY_DB_01, oznaceni01, oznaceni01_2 = argum1
        if haskey(MATERIALY_DB_01, oznaceni01) # materiál existuje v databázi
            skupina01 = MATERIALY_DB_01[oznaceni01]
            if haskey(skupina01, oznaceni01_2)
                row01 = skupina01[oznaceni01_2]
                tabl = true
            end
        end
    else
        error("První argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String} Tuple{Dict{String, Any}, String, String}.")
    end
    argum2 = args[2]
    if length(argum2) == 2
        if !(argum2 isa Tuple{Dict{String, Any}, String})
            error("Druhý argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String}.")
        end
        MATERIALY_DB_02, oznaceni02 = argum2
        if haskey(MATERIALY_DB_02, oznaceni02)
            row02 = MATERIALY_DB_02[oznaceni02]
        else
            row02 = Dict{String, Any}()
        end
    end
    argum3 = args[3]
    if length(argum3) == 2
        if !(argum3 isa Tuple{Dict{String, Any}, String})
            error("Třetí argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String}.")
        end
    MATERIALY_DB_03, oznaceni03 = argum3
        if haskey(MATERIALY_DB_03, oznaceni03)
            row03 = MATERIALY_DB_03[oznaceni03]
        else
            row03 = Dict{String, Any}()
        end
    end
    row04 = Dict{String, Any}()
    elseif delka == 2
    argum1 = args[1]
    if length(argum1) == 2
        if !(argum1 isa Tuple{Dict{String, Any}, String})
            error("První argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String}.")
        end
        MATERIALY_DB_01, oznaceni01 = argum1
        if haskey(MATERIALY_DB_01, oznaceni01) # materiál existuje v databázi
            row01 = MATERIALY_DB_01[oznaceni01]
            tabl = true
        end
    elseif length(argum1) ==3
        if !(argum1 isa Tuple{Dict{String, Any}, String, String})
            error("První argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String, String}.")
        end
        MATERIALY_DB_01, oznaceni01, oznaceni01_2 = argum1
        if haskey(MATERIALY_DB_01, oznaceni01) # materiál existuje v databázi
            skupina01 = MATERIALY_DB_01[oznaceni01]
            if haskey(skupina01, oznaceni01_2)
                row01 = skupina01[oznaceni01_2]
                tabl = true
            end
        end
    else
        error("První argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String} Tuple{Dict{String, Any}, String, String}.")
    end
    argum2 = args[2]
    if length(argum2) == 2
        if !(argum2 isa Tuple{Dict{String, Any}, String})
            error("Druhý argument pro _materialy_nacist musí být typu Tuple{Dict{String, Any}, String}.")
        end
        MATERIALY_DB_02, oznaceni02 = argum2
        if haskey(MATERIALY_DB_02, oznaceni02)
            row02 = MATERIALY_DB_02[oznaceni02]
        else
            row02 = Dict{String, Any}()
        end
    end
    row03 = Dict{String, Any}()
    row04 = Dict{String, Any}()
    else
        error("Nesprávný počet argumentů pro _materialy_nacist. Očekává se 3, ale bylo poskytnuto $delka.")
    end
        if tabl
            if druh == "ocel"
        VV = MaterialOcel(
        get(row01, "name", (get(row02, "name", (get(row03, "name", (get(row04, "name", "")))))))::String, # název materiálu
        get(row01, "standard", (get(row02, "standard", (get(row03, "standard", (get(row04, "standard", "")))))))::String, # norma (nepovinné)
        get(row01, "druh", (get(row02, "druh", (get(row03, "druh", (get(row04, "druh", "")))))))::String, # druh materiálu
        Float64(get(row01, "Re", (get(row02, "Re", (get(row03, "Re", (get(row04, "Re", 0)))))))), # meze kluzu
        get(row01, "Re_unit", (get(row02, "Re_unit", (get(row03, "Re_unit", (get(row04, "Re_unit", "")))))))::String, # jednotka meze kluzu
        Float64(get(row01, "Rm_min", (get(row02, "Rm_min", (get(row03, "Rm_min", (get(row04, "Rm_min", 0)))))))), # meze pevnosti
        get(row01, "Rm_min_unit", (get(row02, "Rm_min_unit", (get(row03, "Rm_min_unit", (get(row04, "Rm_min_unit", "")))))))::String, # jednotka meze pevnosti
        Float64(get(row01, "Rm_max", (get(row02, "Rm_max", (get(row03, "Rm_max", (get(row04, "Rm_max", 0)))))))), # meze pevnosti max
        get(row01, "Rm_max_unit", (get(row02, "Rm_max_unit", (get(row03, "Rm_max_unit", (get(row04, "Rm_max_unit", "")))))))::String, # jednotka meze pevnosti max
        Float64(get(row01, "A", (get(row02, "A", (get(row03, "A", (get(row04, "A", 0)))))))), # prodloužení
        get(row01, "A_unit", (get(row02, "A_unit", (get(row03, "A_unit", (get(row04, "A_unit", "")))))))::String, # jednotka prodloužení
        Float64(get(row01, "KV", (get(row02, "KV", (get(row03, "KV", (get(row04, "KV", 0)))))))), # houževnatost KV
        get(row01, "KV_unit", (get(row02, "KV_unit", (get(row03, "KV_unit", (get(row04, "KV_unit", "")))))))::String, # jednotka houževnatosti KV
        Float64(get(row01, "T_KV", (get(row02, "T_KV", (get(row03, "T_KV", (get(row04, "T_KV", 0)))))))), # teplota KV
        get(row01, "T_KV_unit", (get(row02, "T_KV_unit", (get(row03, "T_KV_unit", (get(row04, "T_KV_unit", "")))))))::String, # jednotka teploty KV
        get(row01, "svaritelnost", (get(row02, "svaritelnost", (get(row03, "svaritelnost", (get(row04, "svaritelnost", "")))))))::String, # popis svařitelnosti
        Bool(get(row01, "weldable", (get(row02, "weldable", (get(row03, "weldable", (get(row04, "weldable", false)))))))), # svařitelnost
        Float64(get(row01, "thickness_max", (get(row02, "thickness_max", (get(row03, "thickness_max", (get(row04, "thickness_max", 0)))))))), # max tloušťka
        get(row01, "thickness_max_unit", (get(row02, "thickness_max_unit", (get(row03, "thickness_max_unit", (get(row04, "thickness_max_unit", "")))))))::String, # jednotka max tloušťky
        Float64(get(row01, "E", (get(row02, "E", (get(row03, "E", (get(row04, "E", 0)))))))), # modul pružnosti
        get(row01, "E_unit", (get(row02, "E_unit", (get(row03, "E_unit", (get(row04, "E_unit", "")))))))::String, # jednotka modulu pružnosti
        Float64(get(row01, "G", (get(row02, "G", (get(row03, "G", (get(row04, "G", 0)))))))), # modul smyku
        get(row01, "G_unit", (get(row02, "G_unit", (get(row03, "G_unit", (get(row04, "G_unit", "")))))))::String, # jednotka modulu smyku
        Float64(get(row01, "ny", (get(row02, "ny", (get(row03, "ny", (get(row04, "ny", 0)))))))), # Poissonovo číslo
        get(row01, "ny_unit", (get(row02, "ny_unit", (get(row03, "ny_unit", (get(row04, "ny_unit", "")))))))::String, # jednotka Poissonova čísla
        Float64(get(row01, "rho", (get(row02, "rho", (get(row03, "rho", (get(row04, "rho", 0)))))))), # hustota
        get(row01, "rho_unit", (get(row02, "rho_unit", (get(row03, "rho_unit", (get(row04, "rho_unit", "")))))))::String # jednotka hustoty
        )
            elseif druh == "litina"
        VV = MaterialLitina(
        get(row01, "name", (get(row02, "name", (get(row03, "name", (get(row04, "name", "")))))))::String, # název materiálu
        get(row01, "standard", (get(row02, "standard", (get(row03, "standard", (get(row04, "standard", "")))))))::String, # norma (nepovinné)
        get(row01, "druh", (get(row02, "druh", (get(row03, "druh", (get(row04, "druh", "")))))))::String, # typ litiny
        Float64(get(row01, "Rm_tah", (get(row02, "Rm_tah", (get(row03, "Rm_tah", (get(row04, "Rm_tah", 0)))))))), # mez pevnosti v tahu
        get(row01, "Rm_tah_unit", (get(row02, "Rm_tah_unit", (get(row03, "Rm_tah_unit", (get(row04, "Rm_tah_unit", "")))))))::String, # jednotka meze pevnosti v tahu
        Float64(get(row01, "Rm_tlak", (get(row02, "Rm_tlak", (get(row03, "Rm_tlak", (get(row04, "Rm_tlak", 0)))))))), # mez pevnosti v tlaku
        get(row01, "Rm_tlak_unit", (get(row02, "Rm_tlak_unit", (get(row03, "Rm_tlak_unit", (get(row04, "Rm_tlak_unit", "")))))))::String, # jednotka meze pevnosti v tlaku
        Float64(get(row01, "tau_lim", (get(row02, "tau_lim", (get(row03, "tau_lim", (get(row04, "tau_lim", 0.5 * Float64(get(row01, "Rm_tah", 0)))))))))), # mez smykové pevnosti
        get(row01, "tau_lim_unit", (get(row02, "tau_lim_unit", (get(row03, "tau_lim_unit", (get(row04, "tau_lim_unit", "")))))))::String, # jednotka meze smykové pevnosti
        Float64(get(row01, "A", (get(row02, "A", (get(row03, "A", (get(row04, "A", 0)))))))), # prodloužení
        get(row01, "A_unit", (get(row02, "A_unit", (get(row03, "A_unit", (get(row04, "A_unit", "")))))))::String, # jednotka prodloužení
        Float64(get(row01, "HB_min", (get(row02, "HB_min", (get(row03, "HB_min", (get(row04, "HB_min", 0)))))))), # tvrdost Brinell min
        get(row01, "HB_min_unit", (get(row02, "HB_min_unit", (get(row03, "HB_min_unit", (get(row04, "HB_min_unit", "")))))))::String, # jednotka tvrdosti Brinell min
        Float64(get(row01, "HB_max", (get(row02, "HB_max", (get(row03, "HB_max", (get(row04, "HB_max", 0)))))))), # tvrdost Brinell max
        get(row01, "HB_max_unit", (get(row02, "HB_max_unit", (get(row03, "HB_max_unit", (get(row04, "HB_max_unit", "")))))))::String, # jednotka tvrdosti Brinell max
        Float64(get(row01, "E", (get(row02, "E", (get(row03, "E", (get(row04, "E", 0)))))))), # modul pružnosti
        get(row01, "E_unit", (get(row02, "E_unit", (get(row03, "E_unit", (get(row04, "E_unit", "")))))))::String, # jednotka modulu pružnosti
        Float64(get(row01, "G", (get(row02, "G", (get(row03, "G", (get(row04, "G", 0)))))))), # modul smyku
        get(row01, "G_unit", (get(row02, "G_unit", (get(row03, "G_unit", (get(row04, "G_unit", "")))))))::String, # jednotka modulu smyku
        Float64(get(row01, "ny", (get(row02, "ny", (get(row03, "ny", (get(row04, "ny", 0)))))))), # Poissonovo číslo
        get(row01, "ny_unit", (get(row02, "ny_unit", (get(row03, "ny_unit", (get(row04, "ny_unit", "")))))))::String, # jednotka Poissonova čísla
        Float64(get(row01, "rho", (get(row02, "rho", (get(row03, "rho", (get(row04, "rho", 0)))))))), # hustota
        get(row01, "rho_unit", (get(row02, "rho_unit", (get(row03, "rho_unit", (get(row04, "rho_unit", "")))))))::String # jednotka hustoty
        )
            elseif druh == "kovy"
        VV = MaterialKovy(
        get(row01, "name", (get(row02, "name", (get(row03, "name", (get(row04, "name", "")))))))::String, # název materiálu
        get(row01, "standard", (get(row02, "standard", (get(row03, "standard", (get(row04, "standard", "")))))))::String, # norma (nepovinné)
        get(row01, "druh", (get(row02, "druh", (get(row03, "druh", (get(row04, "druh", "")))))))::String, # norma (nepovinné)
        Float64(get(row01, "Re", (get(row02, "Re", (get(row03, "Re", (get(row04, "Re", 0)))))))), # meze kluzu
        get(row01, "Re_unit", (get(row02, "Re_unit", (get(row03, "Re_unit", (get(row04, "Re_unit", "")))))))::String, # jednotka meze kluzu
        Float64(get(row01, "Rm_min", (get(row02, "Rm_min", (get(row03, "Rm_min", (get(row04, "Rm_min", 0)))))))), # meze pevnosti
        get(row01, "Rm_min_unit", (get(row02, "Rm_min_unit", (get(row03, "Rm_min_unit", (get(row04, "Rm_min_unit", "")))))))::String, # jednotka meze pevnosti
        Float64(get(row01, "Rm_max", (get(row02, "Rm_max", (get(row03, "Rm_max", (get(row04, "Rm_max", 0)))))))), # meze pevnosti max
        get(row01, "Rm_max_unit", (get(row02, "Rm_max_unit", (get(row03, "Rm_max_unit", (get(row04, "Rm_max_unit", "")))))))::String, # jednotka meze pevnosti max
        Float64(get(row01, "A", (get(row02, "A", (get(row03, "A", (get(row04, "A", 0)))))))), # prodloužení
        get(row01, "A_unit", (get(row02, "A_unit", (get(row03, "A_unit", (get(row04, "A_unit", "")))))))::String, # jednotka prodloužení
        Float64(get(row01, "E", (get(row02, "E", (get(row03, "E", (get(row04, "E", 0)))))))), # modul pružnosti
        get(row01, "E_unit", (get(row02, "E_unit", (get(row03, "E_unit", (get(row04, "E_unit", "")))))))::String, # jednotka modulu pružnosti
        Float64(get(row01, "G", (get(row02, "G", (get(row03, "G", (get(row04, "G", 0)))))))), # modul smyku
        get(row01, "G_unit", (get(row02, "G_unit", (get(row03, "G_unit", (get(row04, "G_unit", "")))))))::String, # jednotka modulu smyku
        Float64(get(row01, "ny", (get(row02, "ny", (get(row03, "ny", (get(row04, "ny", 0)))))))), # Poissonovo číslo
        "-", # jednotka Poissonova čísla
        Float64(get(row01, "rho", (get(row02, "rho", (get(row03, "rho", (get(row04, "rho", 0)))))))), # hustota
        "kg/m^3" # jednotka hustoty
        )
            elseif druh == "pryz"
        VV = MaterialPryz(
        get(row01, "name", (get(row02, "name", (get(row03, "name", (get(row04, "name", "")))))))::String, # název materiálu
        get(row01, "standard", (get(row02, "standard", (get(row03, "standard", (get(row04, "standard", "")))))))::String, # norma (nepovinné)
        get(row01, "druh", (get(row02, "druh", (get(row03, "druh", (get(row04, "druh", "")))))))::String, # norma (nepovinné)
        Float64(get(row01, "hardness", (get(row02, "hardness", (get(row03, "hardness", (get(row04, "hardness", 0)))))))), # tvrdost
        "Shore", # jednotka tvrdosti
        Float64(get(row01, "E", (get(row02, "E", (get(row03, "E", (get(row04, "E", 0)))))))), # modul pružnosti
        "MPa", # jednotka modulu pružnosti
        Float64(get(row01, "G", (get(row02, "G", (get(row03, "G", (get(row04, "G", 0)))))))), # modul smyku
        "MPa", # jednotka modulu smyku
        Float64(get(row01, "ny", (get(row02, "ny", (get(row03, "ny", (get(row04, "ny", 0)))))))), # Poissonovo číslo
        "-", # jednotka Poissonova čísla
        Float64(get(row01, "rho", (get(row02, "rho", (get(row03, "rho", (get(row04, "rho", 0)))))))), # hustota
        "kg/m^3" # jednotka hustoty
        )
            else
                return nothing
            end
        end
        return VV
end
