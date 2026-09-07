# ver: 2026-09-07
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
function _materialy_nacist(druh::String, args...)::Union{MaterialOcel,
    MaterialLitina,
    MaterialKovy,
    Nothing}
    VV = nothing
        if haskey(MATERIALY_DB_CSNocel, oznaceni) # materiál existuje v databázi
            skupina = MATERIALY_DB_CSNocel[oznaceni]
            if haskey(MATERIALY_DB_CSNocel, "vychozi "*oznaceni)
                oznacenivychozi = MATERIALY_DB_CSNocel["vychozi "*oznaceni]
            else
                oznacenivychozi = Dict{String, Any}()
            end
            if haskey(MATERIALY_DB_CSNocel, "vychozi")
                vychozi = MATERIALY_DB_CSNocel["vychozi"]
            else
                vychozi = Dict{String, Any}()
            end
            if haskey(MATERIALY_DB_VYCHOZI, "MaterialOcel")
                DBvychozi = MATERIALY_DB_VYCHOZI["MaterialOcel"]
            else
                DBvychozi = Dict{String, Any}()
            end
            if haskey(skupina, celeoznaceni)
                row = skupina[celeoznaceni]
            if druh == "ocel"
        VV = MaterialOcel(
        get(row, "name", (get(oznacenivychozi, "name", (get(vychozi, "name", (get(DBvychozi, "name", "")))))))::String, # název materiálu
        get(row, "standard", (get(oznacenivychozi, "standard", (get(vychozi, "standard", (get(DBvychozi, "standard", "")))))))::String, # norma (nepovinné)
        get(row, "druh", (get(oznacenivychozi, "druh", (get(vychozi, "druh", (get(DBvychozi, "druh", "")))))))::String, # druh materiálu
        Float64(get(row, "Re", (get(oznacenivychozi, "Re", (get(vychozi, "Re", (get(DBvychozi, "Re", 0)))))))), # meze kluzu
        get(row, "Re_unit", (get(oznacenivychozi, "Re_unit", (get(vychozi, "Re_unit", (get(DBvychozi, "Re_unit", "")))))))::String, # jednotka meze kluzu
        Float64(get(row, "Rm_min", (get(oznacenivychozi, "Rm_min", (get(vychozi, "Rm_min", (get(DBvychozi, "Rm_min", 0)))))))), # meze pevnosti
        get(row, "Rm_min_unit", (get(oznacenivychozi, "Rm_min_unit", (get(vychozi, "Rm_min_unit", (get(DBvychozi, "Rm_min_unit", "")))))))::String, # jednotka meze pevnosti
        Float64(get(row, "Rm_max", (get(oznacenivychozi, "Rm_max", (get(vychozi, "Rm_max", (get(DBvychozi, "Rm_max", 0)))))))), # meze pevnosti max
        get(row, "Rm_max_unit", (get(oznacenivychozi, "Rm_max_unit", (get(vychozi, "Rm_max_unit", (get(DBvychozi, "Rm_max_unit", "")))))))::String, # jednotka meze pevnosti max
        Float64(get(row, "A", (get(oznacenivychozi, "A", (get(vychozi, "A", (get(DBvychozi, "A", 0)))))))), # prodloužení
        get(row, "A_unit", (get(oznacenivychozi, "A_unit", (get(vychozi, "A_unit", (get(DBvychozi, "A_unit", "")))))))::String, # jednotka prodloužení
        Float64(get(row, "KV", (get(oznacenivychozi, "KV", (get(vychozi, "KV", (get(DBvychozi, "KV", 0)))))))), # houževnatost KV
        get(row, "KV_unit", (get(oznacenivychozi, "KV_unit", (get(vychozi, "KV_unit", (get(DBvychozi, "KV_unit", "")))))))::String, # jednotka houževnatosti KV
        Float64(get(row, "T_KV", (get(oznacenivychozi, "T_KV", (get(vychozi, "T_KV", (get(DBvychozi, "T_KV", 0)))))))), # teplota KV
        get(row, "T_KV_unit", (get(oznacenivychozi, "T_KV_unit", (get(vychozi, "T_KV_unit", (get(DBvychozi, "T_KV_unit", "")))))))::String, # jednotka teploty KV
        get(row, "svaritelnost", (get(oznacenivychozi, "svaritelnost", (get(vychozi, "svaritelnost", (get(DBvychozi, "svaritelnost", "")))))))::String, # popis svařitelnosti
        Bool(get(row, "weldable", (get(oznacenivychozi, "weldable", (get(vychozi, "weldable", (get(DBvychozi, "weldable", false)))))))), # svařitelnost
        Float64(get(row, "thickness_max", (get(oznacenivychozi, "thickness_max", (get(vychozi, "thickness_max", (get(DBvychozi, "thickness_max", 0)))))))), # max tloušťka
        get(row, "thickness_max_unit", (get(oznacenivychozi, "thickness_max_unit", (get(vychozi, "thickness_max_unit", (get(DBvychozi, "thickness_max_unit", "")))))))::String, # jednotka max tloušťky
        Float64(get(row, "E", (get(oznacenivychozi, "E", (get(vychozi, "E", (get(DBvychozi, "E", 0)))))))), # modul pružnosti
        get(row, "E_unit", (get(oznacenivychozi, "E_unit", (get(vychozi, "E_unit", (get(DBvychozi, "E_unit", "")))))))::String, # jednotka modulu pružnosti
        Float64(get(row, "G", (get(oznacenivychozi, "G", (get(vychozi, "G", (get(DBvychozi, "G", 0)))))))), # modul smyku
        get(row, "G_unit", (get(oznacenivychozi, "G_unit", (get(vychozi, "G_unit", (get(DBvychozi, "G_unit", "")))))))::String, # jednotka modulu smyku
        Float64(get(row, "ny", (get(oznacenivychozi, "ny", (get(vychozi, "ny", (get(DBvychozi, "ny", 0)))))))), # Poissonovo číslo
        get(row, "ny_unit", (get(oznacenivychozi, "ny_unit", (get(vychozi, "ny_unit", (get(DBvychozi, "ny_unit", "")))))))::String, # jednotka Poissonova čísla
        Float64(get(row, "rho", (get(oznacenivychozi, "rho", (get(vychozi, "rho", (get(DBvychozi, "rho", 0)))))))), # hustota
        get(row, "rho_unit", (get(oznacenivychozi, "rho_unit", (get(vychozi, "rho_unit", (get(DBvychozi, "rho_unit", "")))))))::String # jednotka hustoty
        )
            elseif druh == "litina"
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
            elseif druh == "kovy"
        return _materialy_nacist_kovy(args...)
            else
                return nothing
            end
        return VV
            end
        end
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
        #VV = _materialy_nacist("ocel", {MATERIALY_DB_CSNocel, oznaceni, celeoznaceni}, {MATERIALY_DB_CSNocel, "vychozi"}, {MATERIALY_DB_VYCHOZI, "MaterialOcel"})
        #if VV !== nothing
        #   return VV
        #end
        if haskey(MATERIALY_DB_CSNocel, oznaceni) # materiál existuje v databázi
            skupina = MATERIALY_DB_CSNocel[oznaceni]
            if haskey(MATERIALY_DB_CSNocel, "vychozi "*oznaceni)
                oznacenivychozi = MATERIALY_DB_CSNocel["vychozi "*oznaceni]
            else
                oznacenivychozi = Dict{String, Any}()
            end
            if haskey(MATERIALY_DB_CSNocel, "vychozi")
                vychozi = MATERIALY_DB_CSNocel["vychozi"]
            else
                vychozi = Dict{String, Any}()
            end
            if haskey(MATERIALY_DB_VYCHOZI, "MaterialOcel")
                DBvychozi = MATERIALY_DB_VYCHOZI["MaterialOcel"]
            else
                DBvychozi = Dict{String, Any}()
            end
            if haskey(skupina, celeoznaceni)
                row = skupina[celeoznaceni]
        VV = MaterialOcel(
        get(row, "name", (get(oznacenivychozi, "name", (get(vychozi, "name", (get(DBvychozi, "name", "")))))))::String, # název materiálu
        get(row, "standard", (get(oznacenivychozi, "standard", (get(vychozi, "standard", (get(DBvychozi, "standard", "")))))))::String, # norma (nepovinné)
        get(row, "druh", (get(oznacenivychozi, "druh", (get(vychozi, "druh", (get(DBvychozi, "druh", "")))))))::String, # druh materiálu
        Float64(get(row, "Re", (get(oznacenivychozi, "Re", (get(vychozi, "Re", (get(DBvychozi, "Re", 0)))))))), # meze kluzu
        get(row, "Re_unit", (get(oznacenivychozi, "Re_unit", (get(vychozi, "Re_unit", (get(DBvychozi, "Re_unit", "")))))))::String, # jednotka meze kluzu
        Float64(get(row, "Rm_min", (get(oznacenivychozi, "Rm_min", (get(vychozi, "Rm_min", (get(DBvychozi, "Rm_min", 0)))))))), # meze pevnosti
        get(row, "Rm_min_unit", (get(oznacenivychozi, "Rm_min_unit", (get(vychozi, "Rm_min_unit", (get(DBvychozi, "Rm_min_unit", "")))))))::String, # jednotka meze pevnosti
        Float64(get(row, "Rm_max", (get(oznacenivychozi, "Rm_max", (get(vychozi, "Rm_max", (get(DBvychozi, "Rm_max", 0)))))))), # meze pevnosti max
        get(row, "Rm_max_unit", (get(oznacenivychozi, "Rm_max_unit", (get(vychozi, "Rm_max_unit", (get(DBvychozi, "Rm_max_unit", "")))))))::String, # jednotka meze pevnosti max
        Float64(get(row, "A", (get(oznacenivychozi, "A", (get(vychozi, "A", (get(DBvychozi, "A", 0)))))))), # prodloužení
        get(row, "A_unit", (get(oznacenivychozi, "A_unit", (get(vychozi, "A_unit", (get(DBvychozi, "A_unit", "")))))))::String, # jednotka prodloužení
        Float64(get(row, "KV", (get(oznacenivychozi, "KV", (get(vychozi, "KV", (get(DBvychozi, "KV", 0)))))))), # houževnatost KV
        get(row, "KV_unit", (get(oznacenivychozi, "KV_unit", (get(vychozi, "KV_unit", (get(DBvychozi, "KV_unit", "")))))))::String, # jednotka houževnatosti KV
        Float64(get(row, "T_KV", (get(oznacenivychozi, "T_KV", (get(vychozi, "T_KV", (get(DBvychozi, "T_KV", 0)))))))), # teplota KV
        get(row, "T_KV_unit", (get(oznacenivychozi, "T_KV_unit", (get(vychozi, "T_KV_unit", (get(DBvychozi, "T_KV_unit", "")))))))::String, # jednotka teploty KV
        get(row, "svaritelnost", (get(oznacenivychozi, "svaritelnost", (get(vychozi, "svaritelnost", (get(DBvychozi, "svaritelnost", "")))))))::String, # popis svařitelnosti
        Bool(get(row, "weldable", (get(oznacenivychozi, "weldable", (get(vychozi, "weldable", (get(DBvychozi, "weldable", false)))))))), # svařitelnost
        Float64(get(row, "thickness_max", (get(oznacenivychozi, "thickness_max", (get(vychozi, "thickness_max", (get(DBvychozi, "thickness_max", 0)))))))), # max tloušťka
        get(row, "thickness_max_unit", (get(oznacenivychozi, "thickness_max_unit", (get(vychozi, "thickness_max_unit", (get(DBvychozi, "thickness_max_unit", "")))))))::String, # jednotka max tloušťky
        Float64(get(row, "E", (get(oznacenivychozi, "E", (get(vychozi, "E", (get(DBvychozi, "E", 0)))))))), # modul pružnosti
        get(row, "E_unit", (get(oznacenivychozi, "E_unit", (get(vychozi, "E_unit", (get(DBvychozi, "E_unit", "")))))))::String, # jednotka modulu pružnosti
        Float64(get(row, "G", (get(oznacenivychozi, "G", (get(vychozi, "G", (get(DBvychozi, "G", 0)))))))), # modul smyku
        get(row, "G_unit", (get(oznacenivychozi, "G_unit", (get(vychozi, "G_unit", (get(DBvychozi, "G_unit", "")))))))::String, # jednotka modulu smyku
        Float64(get(row, "ny", (get(oznacenivychozi, "ny", (get(vychozi, "ny", (get(DBvychozi, "ny", 0)))))))), # Poissonovo číslo
        get(row, "ny_unit", (get(oznacenivychozi, "ny_unit", (get(vychozi, "ny_unit", (get(DBvychozi, "ny_unit", "")))))))::String, # jednotka Poissonova čísla
        Float64(get(row, "rho", (get(oznacenivychozi, "rho", (get(vychozi, "rho", (get(DBvychozi, "rho", 0)))))))), # hustota
        get(row, "rho_unit", (get(oznacenivychozi, "rho_unit", (get(vychozi, "rho_unit", (get(DBvychozi, "rho_unit", "")))))))::String # jednotka hustoty
        )
        return VV
            end
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
