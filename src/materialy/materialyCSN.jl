# ver: 2026-09-09
## Funkce: materialyCSN()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/materialy/materialyCSN.jl
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
# materialytypes.jl, materialyCSNocel.toml
###############################################################
## Použité proměnné vnitřní:
#
using TOML

const _materialyCSN_NAPOVEDA = read(
    joinpath(@__DIR__, "..", "..", "docs", "src", "materialy", "materialyCSN.md"),
    String,
)
"""
$_materialyCSN_NAPOVEDA
"""
function materialyCSN(name::AbstractString)::Union{MaterialOcel,
    MaterialLitina,
    MaterialKovy,
    Nothing}
# ---------------------------------------------------------------------
# pomocné funkce
# ---------------------------------------------------------------------
function rozpoznej_materialCSN(text::String)

    regex = r"^\s*(\d{2})\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$"
    #regex = r"^\s*(1[1-6])\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$"
    #regex = r"^\s*(1[1-7]|19)\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$"
    m = match(regex, text)
    # Označení nebylo rozpoznáno
    m === nothing && return nothing
    # Označení materiálu
    oznaceni = m.captures[1] * m.captures[2]
    # Indexy
    index = m.captures[3]
    index1 = nothing
    index2 = nothing
    if index !== nothing
        index1 = parse(Int, index[1])

        if length(index) == 2
            index2 = parse(Int, index[2])
        end
    end
    # Poznámky
    poznamky = String[]

    if m.captures[4] !== nothing
        poznamky = [
            strip(p)
            for p in split(m.captures[4], ",")
            if !isempty(strip(p))
        ]
    end

    return (
        oznaceni = oznaceni,
        index1 = index1,
        index2 = index2,
        poznamky = poznamky
    )
end
#VV = _materialy_nacist("ocel", (MATERIALY_DB_CSNocel, oznaceni, celeoznaceni), (MATERIALY_DB_CSNocel, "vychozi"), (MATERIALY_DB_VYCHOZI, "MaterialOcel"))
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
            elseif druh == "pryz"
        VV = MaterialPryz(
        get(row, "name", name)::String, # název materiálu
        get(row, "standard", "")::String, # norma (nepovinné)
        get(row, "druh", "")::String, # norma (nepovinné)
        Float64(get(row, "hardness", 0)), # tvrdost
        "Shore", # jednotka tvrdosti
        Float64(get(row, "E", 0)), # modul pružnosti
        "MPa", # jednotka modulu pružnosti
        Float64(get(row, "G", 0)), # modul smyku
        "MPa", # jednotka modulu smyku
        Float64(get(row, "ny", 0)), # Poissonovo číslo
        "-", # jednotka Poissonova čísla
        Float64(get(row, "rho", 0)), # hustota
        "kg/m^3" # jednotka hustoty
        )
            else
                return nothing
            end
        end
        return VV
end
# ---------------------------------------------------------------------
# pomocné funkce konec
# ---------------------------------------------------------------------
    MATERIALY_DB_OCEL_EN10025_2 = TOML.parsefile(joinpath(@__DIR__, 
    "materialydatabaseOcelEN10025_2.toml"))
    
    MATERIALY_DB_KOVY_CSN = TOML.parsefile(joinpath(@__DIR__, 
    "materialydatabaseKovyCSN.toml"))
    MATERIALY_DB_LITINA_CSN = TOML.parsefile(joinpath(@__DIR__,
    "materialydatabaseLitinaCSN.toml"))
    MATERIALY_DB_PRYZ = TOML.parsefile(joinpath(@__DIR__,
    "materialydatabasePryz.toml"))
    MATERIALY_DB_VYCHOZI = TOML.parsefile(joinpath(@__DIR__,
    "materialyvychozi.toml"))
    regex1 = r"^\s*(1[0-7]|19)\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$" # oceli
    m1 = match(regex1, name)
    if m1 !== nothing
        #oznaceni, index1, index2, poznamky = rozpoznej_materialCSN(name)
        # Označení materiálu
        oznaceni = m1.captures[1] * m1.captures[2]
        # Indexy
        index = m1.captures[3]
        index1 = nothing
        index2 = nothing
        if index !== nothing
            index1 = parse(Int, index[1])
            if length(index) == 2
                index2 = parse(Int, index[2])
            end
        end
        # Poznámky
        poznamky = String[]
        if m1.captures[4] !== nothing
            poznamky = [
                strip(p)
                for p in split(m1.captures[4], ",")
                if !isempty(strip(p))
            ]
        end
        celeoznaceni = oznaceni *
        (index === nothing ? "" : "." * index) *
        (isempty(poznamky) ? "" : " " * join(poznamky, ", "))
        MATERIALY_DB_CSNocel = TOML.parsefile(joinpath(@__DIR__, 
            "materialyCSNocel.toml"))
        VV = _materialy_nacist("ocel", (MATERIALY_DB_CSNocel, oznaceni, celeoznaceni), (MATERIALY_DB_CSNocel, "vychozi "*oznaceni), (MATERIALY_DB_CSNocel, "vychozi"), (MATERIALY_DB_VYCHOZI, "MaterialOcel"))
        if VV !== nothing
           return VV
        end
    end
    regex2 = r"^\s*(42)\s?(\d{4})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$"
    m2 = match(regex2, name)
    if m2 !== nothing
        #oznaceni, index1, index2, poznamky = rozpoznej_materialCSN(name)
        # Označení materiálu
        oznaceni = m2.captures[1] * m2.captures[2]
        # Indexy
        index = m2.captures[3]
        index1 = nothing
        index2 = nothing
        if index !== nothing
            index1 = parse(Int, index[1])
            if length(index) == 2
                index2 = parse(Int, index[2])
            end
        end
        MATERIALY_DB_CSNlitina = TOML.parsefile(joinpath(@__DIR__, 
        "materialyCSNlitina.toml"))
        if haskey(MATERIALY_DB_CSNlitina, oznaceni)
            row = MATERIALY_DB_CSNlitina[oznaceni]
            if haskey(MATERIALY_DB_CSNlitina, "vychozi")
                vychozi = MATERIALY_DB_CSNlitina["vychozi"]
            else
                vychozi = Dict{String, Any}()
            end
        VV = MaterialLitina(
        get(row, "name", (get(vychozi, "name", name)))::String, # název materiálu
        get(row, "standard", (get(vychozi, "standard", "")))::String, # norma (nepovinné)
        get(row, "druh", (get(vychozi, "druh", "")))::String, # typ litiny
        Float64(get(row, "Rm_tah", (get(vychozi, "Rm_tah", 0)))), # mez pevnosti v tahu
        "MPa", # jednotka meze pevnosti v tahu
        Float64(get(row, "Rm_tlak", (get(vychozi, "Rm_tlak", 0)))), # mez pevnosti v tlaku
        "MPa", # jednotka meze pevnosti v tlaku
        Float64(get(row, "tau_lim", (get(vychozi, "tau_lim", 0.5 * Float64(get(row, "Rm_tah", 0)))))), # mez smykové pevnosti
        "MPa", # jednotka meze smykové pevnosti
        Float64(get(row, "A", (get(vychozi, "A", 0)))), # prodloužení
        "%", # jednotka prodloužení
        Float64(get(row, "HB_min", (get(vychozi, "HB_min", 0)))), # tvrdost Brinell min
        "HB", # jednotka tvrdosti Brinell min
        Float64(get(row, "HB_max", (get(vychozi, "HB_max", 0)))), # tvrdost Brinell max
        "HB", # jednotka tvrdosti Brinell max
        Float64(get(row, "E", (get(vychozi, "E", 0)))), # modul pružnosti
        "GPa", # jednotka modulu pružnosti
        Float64(get(row, "G", (get(vychozi, "G", 0)))), # modul smyku
        "GPa", # jednotka modulu smyku
        Float64(get(row, "ny", (get(vychozi, "ny", 0)))), # Poissonovo číslo
        "-", # jednotka Poissonova čísla
        Float64(get(row, "rho", (get(vychozi, "rho", 0)))), # hustota
        "kg/m^3" # jednotka hustoty
        )
        return VV
        end
    end
    regex3 = r"^\s*(42)\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$"
    m3 = match(regex3, name)
    if m3 !== nothing
        oznaceni, index1, index2, poznamky = rozpoznej_materialCSN(name)
        MATERIALY_DB_CSNkovy = TOML.parsefile(joinpath(@__DIR__, 
        "materialyCSNkovy.toml"))
        row = MATERIALY_DB_CSNkovy[oznaceni]
        VV = MaterialKovy(
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
        return VV
    end
    return nothing
end
