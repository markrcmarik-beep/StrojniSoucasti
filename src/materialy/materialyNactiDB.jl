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
using DBInterface

function materialyNactiDB(db, name, celeoznaceni, standard, druh)

    property = function (kod, varianta="zakladni", zalozni=nothing)
        hodnota = get(properties, (kod, varianta), nothing)
        if (hodnota === nothing || ismissing(hodnota)) && zalozni !== nothing
            hodnota = get(properties, (kod, zalozni), nothing)
        end
        hodnota === nothing || ismissing(hodnota) ? 0.0 : hodnota
    end

if druh == "ocel"
    dalsi_vlastnosti = Dict{String, Any}()
    tabulky = Set(row.name for row in DBInterface.execute(
        db, "SELECT name FROM sqlite_master WHERE type = 'table'"))
    if "ocel_velicina" in tabulky
        steel_result = DBInterface.execute(
            db,
            "SELECT id, name_ISO, znacka_EN, cislo_EN, name_CSN, name_DIN, norma_CSN, " *
            "druh, stav, zpracovani, vlastnosti, pouziti, svaritelnost, obrobitelnost, " *
            "k_cementovani, k_nitridovani, k_zuslechtovani, " *
            "k_povrchovemu_kaleni, korozivzdorna, obvykla_jakost " *
            "FROM ocel WHERE " * name * " = ? LIMIT 1", (celeoznaceni,))
        steel_rows = [NamedTuple(row) for row in steel_result]
        isempty(steel_rows) && return nothing
        steel = first(steel_rows)

        properties = Dict{Tuple{String,String},Any}()
        for prop in DBInterface.execute(
            db,
            "SELECT v.kod, ov.varianta, ov.hodnota " *
            "FROM ocel_velicina ov " *
            "JOIN velicina v ON v.id = ov.velicina_id " *
            "WHERE ov.ocel_id = ? AND ov.rozsah_od_mm IS NULL " *
            "AND ov.rozsah_do_mm IS NULL", (steel.id,))
            properties[(prop.kod, prop.varianta)] = prop.hodnota
        end

        textvalue = value -> ismissing(value) ? "" : value
        re_rozsahy = [
            (rozsah_od_mm=prop.rozsah_od_mm,
                rozsah_do_mm=prop.rozsah_do_mm,
                Re_min_MPa=prop.hodnota)
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
            name_ISO=ismissing(steel.name_ISO) ? "" : steel.name_ISO,
            znacka_EN=ismissing(steel.znacka_EN) ? "" : steel.znacka_EN,
            cislo_EN=ismissing(steel.cislo_EN) ? "" : steel.cislo_EN,
            name_CSN=ismissing(steel.name_CSN) ? "" : steel.name_CSN,
            name_DIN=ismissing(steel.name_DIN) ? "" : steel.name_DIN,
            norma_CSN=ismissing(steel.norma_CSN) ? "" : steel.norma_CSN,
            druh=steel.druh,
            Re_MPa=property("Re", "zakladni"), # vrací hodnotu meze kluzu v MPa, pokud není k dispozici, vrací 0.0
            Re_min_MPa=property("Re", "min"),
            Rm_min_MPa=property("Rm", "min"),
            Rm_max_MPa=property("Rm", "max"),
            A_proc=property("A"),
            KV_J=property("KV"),
            T_KV_degC=property("T_KV"),
            svaritelnost=ismissing(steel.svaritelnost) ? "" : steel.svaritelnost,
            E_GPa=property("E"),
            G_GPa=property("G"),
            alfa_1_K=property("alfa"),
            ny=property("nu"),
            rho_kg_m3=property("rho")
        )
        dalsi_vlastnosti = Dict{String,Any}(
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
    VV = Dict{String,Any}(
        "name_ISO" => row.name_ISO,
        "znacka_EN" => row.znacka_EN,
        "cislo_EN" => row.cislo_EN,
        "name_CSN" => row.name_CSN,
        "name_DIN" => row.name_DIN,
        "standard" => standard, # hledáno z tabulky ČSN, proto je standard ČSN
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
    else
        return nothing
    end
elseif druh == "litina"
        tabulky = Set(row.name for row in DBInterface.execute(
            db, "SELECT name FROM sqlite_master WHERE type = 'table'"))
        if "litina_velicina" in tabulky
            result = DBInterface.execute(
                db,
                "SELECT id, name_ISO, oznaceni_EN, cislo_EN, name_CSN, name_DIN, norma_CSN, druh " *
                "FROM litina WHERE " * name * " = ? LIMIT 1", (celeoznaceni,))
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
                name_ISO = ismissing(litina.name_ISO) ? "" : litina.name_ISO,
                znacka_EN = ismissing(litina.oznaceni_EN) ? "" : litina.oznaceni_EN,
                cislo_EN = ismissing(litina.cislo_EN) ? "" : litina.cislo_EN,
                name_CSN = ismissing(litina.name_CSN) ? "" : litina.name_CSN,
                name_DIN = ismissing(litina.name_DIN) ? "" : litina.name_DIN,
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
        end
        VV = Dict{String, Any}(
            "name_ISO" => row.name_ISO,
            "znacka_EN" => row.znacka_EN,
            "cislo_EN" => row.cislo_EN,
            "name_CSN" => row.name_CSN,
            "name_DIN" => row.name_DIN,
            "standard" => standard,
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
    else
        return nothing
    end
else
    error("Unsupported material type: $druh")    
end

end