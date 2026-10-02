# ver: 2026-09-30
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
#using SQLite

"""
$(read(joinpath(@__DIR__, "..", "..", "docs", "src", "materialy", "materialyCSN.md"), String))
"""
function materialyCSN(db, name::AbstractString)::Union{Dict{String, Any},
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
    regex1 = r"^\s*(1[0-7]|19)\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$" # oceli (11-17, 19)
    m1 = match(regex1, name)
    dalsi_vlastnosti = Dict{String, Any}()
    if m1 !== nothing
        #oznaceni, index1, index2, poznamky = rozpoznej_materialCSN(name)
        # Označení materiálu
        oznaceni = m1.captures[1] * m1.captures[2]
        # Indexy
        index = m1.captures[3]
        index1 = nothing
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
            zamena = TOML.parsefile(joinpath(StrojniSoucasti.cesta_materialy, "materialy_poznamky.toml"))["zamena"]
            povolene_poznamky = collect(keys(zamena))
            for p in poznamky
                for (cil, varianty) in zamena
                    if p in varianty
                        p = cil
                        break
                    end
                end
                if (p in povolene_poznamky)
                    poznamkyD = isempty(poznamkyD) ? p : poznamkyD * ", " * p # oddělení poznámek čárkou
                    poznamkyD = join(sort(split(poznamkyD, ", ")), ", ") # seřadit poznámky oddělené čárkou podle abecedy
                end
            end
        end
        celeoznaceni = celeoznaceni * (isempty(poznamkyD) ? "" : " " * poznamkyD)
        tabulky = Set(row.name for row in DBInterface.execute(
            db, "SELECT name FROM sqlite_master WHERE type = 'table'"))
        if "ocel_velicina" in tabulky
            steel_result = DBInterface.execute(
                db,
                "SELECT id, name_CSN, znacka_EN, cislo_EN, norma_CSN, druh, stav, " *
                "zpracovani, vlastnosti, pouziti, svaritelnost, obrobitelnost, " *
                "k_cementovani, k_nitridovani, k_zuslechtovani, " *
                "k_povrchovemu_kaleni, korozivzdorna, obvykla_jakost " *
                "FROM ocel WHERE name_CSN = ? LIMIT 1", (celeoznaceni,))
            steel_rows = [NamedTuple(row) for row in steel_result]
            isempty(steel_rows) && return nothing
            steel = first(steel_rows)

            properties = Dict{Tuple{String, String}, Any}()
            for prop in DBInterface.execute(
                db,
                "SELECT v.kod, ov.varianta, ov.hodnota " *
                "FROM ocel_velicina ov " *
                "JOIN velicina v ON v.id = ov.velicina_id " *
                "WHERE ov.ocel_id = ? AND ov.rozsah_od_mm IS NULL " *
                "AND ov.rozsah_do_mm IS NULL", (steel.id,))
                properties[(prop.kod, prop.varianta)] = prop.hodnota
            end

            property = function (kod, varianta = "zakladni", zalozni = nothing)
                hodnota = get(properties, (kod, varianta), nothing)
                if (hodnota === nothing || ismissing(hodnota)) && zalozni !== nothing
                    hodnota = get(properties, (kod, zalozni), nothing)
                end
                hodnota === nothing || ismissing(hodnota) ? 0.0 : hodnota
            end
            textvalue = value -> ismissing(value) ? "" : value
            re_rozsahy = [
                (rozsah_od_mm = prop.rozsah_od_mm,
                    rozsah_do_mm = prop.rozsah_do_mm,
                    Re_min_MPa = prop.hodnota)
                for prop in DBInterface.execute(
                    db,
                    "SELECT ov.rozsah_od_mm, ov.rozsah_do_mm, ov.hodnota " *
                    "FROM ocel_velicina ov " *
                    "JOIN velicina v ON v.id = ov.velicina_id " *
                    "WHERE ov.ocel_id = ? AND v.kod = 'Re' " *
                    "AND ov.varianta = 'min' " *
                    "AND (ov.rozsah_od_mm IS NOT NULL OR ov.rozsah_do_mm IS NOT NULL) " *
                    "ORDER BY ov.rozsah_od_mm", (steel.id,))
            ]

            row = (
                name_CSN = steel.name_CSN,
                znacka_EN = ismissing(steel.znacka_EN) ? "" : steel.znacka_EN,
                cislo_EN = ismissing(steel.cislo_EN) ? "" : steel.cislo_EN,
                norma_CSN = ismissing(steel.norma_CSN) ? "" : steel.norma_CSN,
                druh = steel.druh,
                Re_MPa = property("Re", "zakladni"), # vrací hodnotu meze kluzu v MPa, pokud není k dispozici, vrací 0.0
                Re_min_MPa = property("Re", "min"),
                Rm_min_MPa = property("Rm", "min"),
                Rm_max_MPa = property("Rm", "max"),
                A_proc = property("A"),
                KV_J = property("KV"),
                T_KV_degC = property("T_KV"),
                svaritelnost = ismissing(steel.svaritelnost) ? "" : steel.svaritelnost,
                E_GPa = property("E"),
                G_GPa = property("G"),
                alfa_1_K = property("alfa"),
                ny = property("nu"),
                rho_kg_m3 = property("rho")
            )
            dalsi_vlastnosti = Dict{String, Any}(
                "stav" => textvalue(steel.stav),
                "zpracovani" => textvalue(steel.zpracovani),
                "vlastnosti" => textvalue(steel.vlastnosti),
                "pouziti" => textvalue(steel.pouziti),
                "obrobitelnost" => textvalue(steel.obrobitelnost),
                "k_cementovani" => textvalue(steel.k_cementovani),
                "k_nitridovani" => textvalue(steel.k_nitridovani),
                "k_zuslechtovani" => textvalue(steel.k_zuslechtovani),
                "k_povrchovemu_kaleni" => textvalue(steel.k_povrchovemu_kaleni),
                "korozivzdorna" => textvalue(steel.korozivzdorna),
                "obvykla_jakost" => textvalue(steel.obvykla_jakost),
                "Re_max" => property("Re", "max"),
                "Re_max_unit" => "MPa",
                "Rp0_2" => property("Rp0.2"),
                "Rp0_2_unit" => "MPa",
                "Rp0_1" => property("Rp0.1"),
                "Rp0_1_unit" => "MPa",
                "tvrdost_HB" => property("HB"),
                "tvrdost_HB_unit" => "HB",
                "tvrdost_HV" => property("HV"),
                "tvrdost_HV_unit" => "HV",
                "tvrdost_HRC" => property("HRC"),
                "tvrdost_HRC_unit" => "HRC",
                "Re_rozsahy" => re_rozsahy
            )
        end
        VV = Dict{String, Any}(
            "name_CSN" => row.name_CSN,
            "znacka_EN" => row.znacka_EN,
            "cislo_EN" => row.cislo_EN,
            "standard" => "ČSN", # hledáno z tabulky ČSN, proto je standard ČSN
            "norma" => row.norma_CSN,
            "druh" => row.druh,
            "Re" => row.Re_MPa,
            "Re_unit" => "MPa",
            "Re_min" => row.Re_min_MPa,
            "Re_min_unit" => "MPa",
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
            "G_unit" => "GPa",
            "alfa" => row.alfa_1_K,
            "alfa_unit" => "1/K",
            "ny" => row.ny,
            "ny_unit" => "-",
            "rho" => row.rho_kg_m3,
            "rho_unit" => "kg/m^3"
        )
        merge!(VV, dalsi_vlastnosti)

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

        litina_tabulky = Set(row.name for row in DBInterface.execute(
            db, "SELECT name FROM sqlite_master WHERE type = 'table'"))
        if "litina_velicina" in litina_tabulky
            result = DBInterface.execute(
                db,
                "SELECT id, name_CSN, norma_CSN, druh " *
                "FROM litina WHERE name_CSN = ? LIMIT 1", (oznaceni,))
            rows = [NamedTuple(row) for row in result]
            isempty(rows) && return nothing
            litina = first(rows)

            vlastnosti = Dict{Tuple{String, String}, Any}()
            for value in DBInterface.execute(
                db,
                "SELECT v.kod, lv.varianta, lv.hodnota " *
                "FROM litina_velicina lv " *
                "JOIN velicina v ON v.id = lv.velicina_id " *
                "WHERE lv.litina_id = ? AND lv.rozsah_od_mm IS NULL " *
                "AND lv.rozsah_do_mm IS NULL", (litina.id,))
                vlastnosti[(value.kod, value.varianta)] = value.hodnota
            end
            property_litina = function (kod, varianta = "zakladni")
                value = get(vlastnosti, (kod, varianta), 0.0)
                value === nothing || ismissing(value) ? 0.0 : value
            end

            row = (
                name_CSN = litina.name_CSN,
                norma_CSN = litina.norma_CSN,
                druh = litina.druh,
                Rm_tah_MPa = property_litina("Rm"),
                Rm_tlak_MPa = property_litina("Rm_tlak"),
                A_proc = property_litina("A"),
                HB_min = property_litina("HB", "min"),
                HB_max = property_litina("HB", "max"),
                E_GPa = property_litina("E"),
                G_GPa = property_litina("G"),
                alfa_1_K = property_litina("alfa"),
                ny = property_litina("nu"),
                rho_kg_m3 = property_litina("rho")
            )
        else
            result = DBInterface.execute(
                db,
                "SELECT name_CSN, norma_CSN, druh, Rm_tah_MPa, Rm_tlak_MPa, A_proc, 
                    HB_min, HB_max, E_GPa, G_GPa, ny, alfa_1_K, rho_kg_m3
                FROM litina WHERE name_CSN = ?", (oznaceni,))
            rows = [NamedTuple(row) for row in result]
            isempty(rows) && return nothing
            sqlite_row = first(rows)
            row = (
                name_CSN = sqlite_row.name_CSN,
                norma_CSN = sqlite_row.norma_CSN,
                druh = sqlite_row.druh,
                Rm_tah_MPa = sqlite_row.Rm_tah_MPa,
                Rm_tlak_MPa = sqlite_row.Rm_tlak_MPa,
                A_proc = sqlite_row.A_proc,
                HB_min = sqlite_row.HB_min,
                HB_max = sqlite_row.HB_max,
                E_GPa = sqlite_row.E_GPa,
                G_GPa = sqlite_row.G_GPa,
                alfa_1_K = sqlite_row.alfa_1_K,
                ny = sqlite_row.ny,
                rho_kg_m3 = sqlite_row.rho_kg_m3
            )
        end
        VV = Dict{String, Any}(
            "name_CSN" => row.name_CSN,
            "standard" => "ČSN",
            "norma" => row.norma_CSN,
            "druh" => row.druh,
            "Rm_tah" => row.Rm_tah_MPa,
            "Rm_tah_unit" => "MPa",
            "Rm_tlak" => row.Rm_tlak_MPa,
            "Rm_tlak_unit" => "MPa",
            "A" => row.A_proc,
            "A_unit" => "%",
            "HB_min" => row.HB_min,
            "HB_min_unit" => "HB",
            "HB_max" => row.HB_max,
            "HB_max_unit" => "HB",
            "E" => row.E_GPa,
            "E_unit" => "GPa",
            "G" => row.G_GPa,
            "G_unit" => "GPa",
            "alfa" => row.alfa_1_K,
            "alfa_unit" => "1/K",
            "ny" => row.ny,
            "ny_unit" => "-",
            "rho" => row.rho_kg_m3,
            "rho_unit" => "kg/m^3"
        )

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
