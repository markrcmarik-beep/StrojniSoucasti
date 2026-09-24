# ver: 2026-09-22
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
using DBInterface
using SQLite

"""
$(read(joinpath(@__DIR__, "..", "..", "docs", "src", "materialy", "materialyCSN.md"), String))
"""
function materialyCSN(name::AbstractString)::Union{Dict{String, Any}, MaterialOcel,
    MaterialLitina,
    MaterialKovy,
    Nothing}
# ---------------------------------------------------------------------
# pomocné funkce
# ---------------------------------------------------------------------
function rozpoznej_materialCSN(text::String)

    regex = r"^\s*(\d{2})\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$" # regex pro rozpoznání materiálu podle ČSN
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
    poznamky = String[] # prázdný seznam poznámek
    if m.captures[4] !== nothing
        poznamky = [
            strip(p)
            for p in split(m.captures[4], ",")
            if !isempty(strip(p))
        ] # odstranění prázdných poznámek
    end

    return (
        oznaceni = oznaceni,
        index1 = index1,
        index2 = index2,
        poznamky = poznamky
    )
end
#VV = _materialy_nacist("ocel", (MATERIALY_DB_CSNocel, oznaceni, celeoznaceni), (MATERIALY_DB_CSNocel, "vychozi"), (MATERIALY_DB_VYCHOZI, "MaterialOcel"))

# ---------------------------------------------------------------------
# pomocné funkce konec
# ---------------------------------------------------------------------
    MATERIALY_DB_OCEL_EN10025_2 = TOML.parsefile(joinpath(cesta_materialy, 
    "materialydatabaseOcelEN10025_2.toml"))
    
    MATERIALY_DB_KOVY_CSN = TOML.parsefile(joinpath(cesta_materialy, 
    "materialydatabaseKovyCSN.toml"))
    MATERIALY_DB_LITINA_CSN = TOML.parsefile(joinpath(cesta_materialy,
    "materialydatabaseLitinaCSN.toml"))
    MATERIALY_DB_PRYZ = TOML.parsefile(joinpath(cesta_materialy,
    "materialydatabasePryz.toml"))
    MATERIALY_DB_VYCHOZI = TOML.parsefile(joinpath(cesta_materialy,
    "materialyvychozi.toml"))
    regex1 = r"^\s*(1[0-7]|19)\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$" # oceli (11-17, 19)
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
        (index === nothing ? "" : "." * index)
        poznamkyD = ""
        if !isempty(poznamky)
            povolene_poznamky = ["žíhaný", "tvářený za studena", "tvářený za tepla", "zušlechtěno", "nitridovat", "cementovat"]
            for p in poznamky
                if (p in povolene_poznamky)
                    poznamkyD = isempty(poznamkyD) ? p : poznamkyD * ", " * p # oddělení poznámek čárkou
                    poznamkyD = join(sort(split(poznamkyD, ", ")), ", ") # seřadit poznámky oddělené čárkou podle abecedy
                end
            end
        end
        celeoznaceni = celeoznaceni * (isempty(poznamkyD) ? "" : " " * poznamkyD)
        db_path = joinpath(cesta_materialy, "materialy.db")
        #MATERIALY_DB_CSNocel = TOML.parsefile(joinpath(cesta_materialy, 
        #    "materialyCSNocel.toml"))

        #VV = _materialy_nacist("ocel", (MATERIALY_DB_CSNocel, oznaceni, celeoznaceni), (MATERIALY_DB_CSNocel, "vychozi "*oznaceni), (MATERIALY_DB_CSNocel, "vychozi"), (MATERIALY_DB_VYCHOZI, "MaterialOcel"))
        db = SQLite.DB(db_path) # Načte databázi závitů, pokud ještě nebyla načtena
        result = DBInterface.execute(
            db,
            "SELECT name_CSN, standard, druh, Re_MPa, Rm_min_MPa, Rm_max_MPa, 
                A_proc, KV_J, T_KV_degC, svaritelnost, E_GPa, G_GPa, ny, rho_kg_m3
            FROM ocel WHERE name_CSN = ?", (celeoznaceni,)
            )
        rows = [NamedTuple(row) for row in result]
        SQLite.close(db)
        isempty(rows) && return nothing
        sqlite_row = first(rows)
        row = (
            name_CSN = sqlite_row.name_CSN,
            standard = sqlite_row.standard,
            druh = sqlite_row.druh,
            Re_MPa = sqlite_row.Re_MPa,
            Rm_min_MPa = sqlite_row.Rm_min_MPa,
            Rm_max_MPa = sqlite_row.Rm_max_MPa,
            A_proc = sqlite_row.A_proc,
            KV_J = sqlite_row.KV_J,
            T_KV_degC = sqlite_row.T_KV_degC,
            svaritelnost = sqlite_row.svaritelnost,
            E_GPa = sqlite_row.E_GPa,
            G_GPa = sqlite_row.G_GPa,
            ny = sqlite_row.ny,
            rho_kg_m3 = sqlite_row.rho_kg_m3
        )
        VV = Dict{String, Any}(
            "name" => row.name_CSN,
            "standard" => row.standard,
            "druh" => row.druh,
            "Re" => row.Re_MPa,
            "Re_unit" => "MPa",
            "Rm_min" => row.Rm_min_MPa,
            "Rm_min_unit" => "MPa",
            "Rm_max" => row.Rm_max_MPa,
            "Rm_max_unit" => "MPa",
            "A" => row.A_proc,
            "A_unit" => "%",
            "KV" => row.KV_J,
            "KV_unit" => "J",
            "T_KV" => row.T_KV_degC,
            "T_KV_unit" => "°C",
            "svaritelnost" => row.svaritelnost,
            "E" => row.E_GPa,
            "E_unit" => "GPa",
            "G" => row.G_GPa,
            "G_uni" => "GPa",
            "ny" => row.ny,
            "ny_unit" => "-",
            "rho" => row.rho_kg_m3,
            "rho_unit" => "kg/m^3"
        )
        println(VV)
        if VV !== nothing
           return VV
        end
    end
    regex2 = r"^\s*(42)\s?(\d{4})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$" # litiny
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
        MATERIALY_DB_CSNlitina = TOML.parsefile(joinpath(cesta_materialy, 
        "materialyCSNlitina.toml"))
        VV = _materialy_nacist("litina", (MATERIALY_DB_CSNlitina, oznaceni), (MATERIALY_DB_CSNlitina, "vychozi"), (MATERIALY_DB_VYCHOZI, "MaterialLitina"))
        if VV !== nothing
           return VV
        end
    end
    regex3a = r"^\s*(42)\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$" # kovy
    m3a = match(regex3a, name)
    regex3b = r"^\s*(1[0-7]|19)\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$"
    m3b = match(regex3b, name)
    if m3a !== nothing 
        oznaceni, index1, index2, poznamky = rozpoznej_materialCSN(name) # rozpoznání materiálu podle ČSN
        MATERIALY_DB_CSNkovy = TOML.parsefile(joinpath(cesta_materialy, 
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
