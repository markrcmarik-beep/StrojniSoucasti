# ver: 2026-08-31
## Funkce: materialyCSN()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/materialy/materialyCSN.jl
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
# materialytypes.jl, materialydatabase.toml
###############################################################
## Použité proměnné vnitřní:
#
using TOML
include("materialytypes.jl")

const _materialy_NAPOVEDA = read(
    joinpath(@__DIR__, "..", "..", "docs", "src", "materialy", "materialy.md"),
    String,
)
"""
$_materialy_NAPOVEDA
"""
function materialyCSN(name::AbstractString)::Union{MaterialOcel,
    MaterialKovy,
    MaterialLitina,
    MaterialPryz,
    Nothing}
# ---------------------------------------------------------------------
# pomocné funkce
# ---------------------------------------------------------------------
function rozpoznej_materialCSNocel(text::String)

    regex = r"^\s*(\d{2})\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$"
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
    
    if rozpoznej_materialCSNocel(name) !== nothing
        oznaceni, index1, index2, poznamky = rozpoznej_materialCSNocel(name)
        MATERIALY_DB_CSNocel = TOML.parsefile(joinpath(@__DIR__, 
        "materialyCSNocel.toml"))
        row = MATERIALY_DB_CSNocel[name]
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
    end
    return nothing
end
