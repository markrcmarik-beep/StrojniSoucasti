# ver: 2026-10-15
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

function _materialyNactiDB(db, name, celeoznaceni, standard, druh)

    # ---------------------------------------------------------------------
    # pomocné funkce
    jednotky = Dict{String,String}()
    for velicina in DBInterface.execute(db, "SELECT kod, jednotka FROM velicina")
        hodnota = ismissing(velicina.jednotka) ? "" : string(velicina.jednotka)
        jednotky[velicina.kod] = hodnota
    end
    jednotka = kod -> get(jednotky, kod, "")


    property = function (kod, varianta="zakladni", zalozni=nothing)
        hodnota = get(properties, (kod, varianta), nothing)
        if (hodnota === nothing || ismissing(hodnota)) && zalozni !== nothing
            hodnota = get(properties, (kod, zalozni), nothing)
        end
        hodnota === nothing || ismissing(hodnota) ? missing : hodnota
    end
    # ---------------------------------------------------------------------
    names = ["name", "name_ISO", "znacka_EN", "cislo_EN", "name_CSN", "name_DIN", "norma_CSN", "druh"]
    if druh == "ocel"
        namesOcel = ["stav", "zpracovani", "vlastnosti", "pouziti", "svaritelnost", "obrobitelnost",
            "k_cementovani", "k_nitridovani", "k_zuslechtovani", "k_povrchovemu_kaleni",
            "korozivzdorna", "obvykla_jakost"]
        dalsi_vlastnosti = Dict{String,Any}()
        tabulky = Set(row.name for row in DBInterface.execute(
            db, "SELECT name FROM sqlite_master WHERE type = 'table'"))
        if "ocel_velicina" in tabulky
            steel_result = DBInterface.execute(
                db,
                "SELECT " * join(vcat(["id"], names, namesOcel), ", ") *
                    " FROM ocel WHERE " * name * " = ? LIMIT 1", (celeoznaceni,))
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
                    Re_min_MPa=prop.hodnota,
                    Re_min_unit=jednotka("Re"))
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
                name=ismissing(steel.name) ? "" : steel.name,
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
                ny=property("ny"),
                rho_kg_m3=property("rho")
            )
            VVnames = Dict{String,Any}(
                "name" => name, # název materiálu
                "name_ISO" => row.name_ISO, # název ISO
                "znacka_EN" => row.znacka_EN, # název EN značka
                "cislo_EN" => row.cislo_EN, # název EN číslo
                "name_CSN" => row.name_CSN, # název ČSN
                "name_DIN" => row.name_DIN, # název DIN
                "standard" => standard, # hledáno z tabulky ČSN, proto je standard ČSN
                "norma_CSN" => row.norma_CSN,
                "druh" => row.druh
            )
            VVnamesOcel = Dict{String,Any}(
                "stav" => textvalue(steel.stav),
                "zpracovani" => textvalue(steel.zpracovani),
                "vlastnosti" => textvalue(steel.vlastnosti),
                "pouziti" => textvalue(steel.pouziti),
                "svaritelnost" => textvalue(steel.svaritelnost),
                "obrobitelnost" => textvalue(steel.obrobitelnost),
                "k_cementovani" => textvalue(steel.k_cementovani),
                "k_nitridovani" => textvalue(steel.k_nitridovani),
                "k_zuslechtovani" => textvalue(steel.k_zuslechtovani),
                "k_povrchovemu_kaleni" => textvalue(steel.k_povrchovemu_kaleni),
                "korozivzdorna" => textvalue(steel.korozivzdorna),
                "obvykla_jakost" => textvalue(steel.obvykla_jakost)
            )
            VVvelicina = Dict{String,Any}(
                "Re" => property("Re", "zakladni"),
                "Re_unit" => jednotka("Re"),
                "Re_min" => property("Re", "min"),
                "Re_min_unit" => jednotka("Re"),
                "Re_max" => property("Re", "max"),
                "Re_max_unit" => jednotka("Re"),
                "Rm" => property("Rm", "zakladni"),
                "Rm_unit" => jednotka("Rm"),
                "Rm_min" => property("Rm", "min"),
                "Rm_min_unit" => jednotka("Rm"),
                "Rm_max" => property("Rm", "max"),
                "Rm_max_unit" => jednotka("Rm"),
                "Rp0_2" => property("Rp0_2", "zakladni"),
                "Rp0_2_unit" => jednotka("Rp0_2"),
                "Rp0_1" => property("Rp0_1", "zakladni"),
                "Rp0_1_unit" => jednotka("Rp0_1"),
                "A" => property("A"),
                "A_unit" => jednotka("A"),
                "KV" => property("KV"),
                "KV_unit" => jednotka("KV"),
                "T_KV" => property("T_KV"),
                "T_KV_unit" => jednotka("T_KV"),
                "E" => property("E"),
                "E_unit" => jednotka("E"),
                "G" => property("G"),
                "G_unit" => jednotka("G"),
                "alfa" => property("alfa"),
                "alfa_unit" => jednotka("alfa"),
                "ny" => property("ny"),
                "ny_unit" => jednotka("ny"),
                "rho" => property("rho"),
                "rho_unit" => jednotka("rho")
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
                "Re_max_unit" => jednotka("Re"),
                "Rp0_2" => property("Rp0.2"),
                "Rp0_2_unit" => jednotka("Rp0.2"),
                "Rp0_1" => property("Rp0.1"),
                "Rp0_1_unit" => jednotka("Rp0.1"),
                "tvrdost_HB" => property("HB"),
                "tvrdost_HB_unit" => jednotka("HB"),
                "tvrdost_HV" => property("HV"),
                "tvrdost_HV_unit" => jednotka("HV"),
                "tvrdost_HRC" => property("HRC"),
                "tvrdost_HRC_unit" => jednotka("HRC"),
                "Re_rozsahy" => re_rozsahy
            )
        end
        VV = Dict{String,Any}(
            "name" => row.name, # název materiálu
            "name_ISO" => row.name_ISO,
            "znacka_EN" => row.znacka_EN,
            "cislo_EN" => row.cislo_EN,
            "name_CSN" => row.name_CSN,
            "name_DIN" => row.name_DIN,
            "standard" => standard, # hledáno z tabulky ČSN, proto je standard ČSN
            "norma_CSN" => row.norma_CSN,
            "druh" => row.druh,
            "Re" => row.Re_MPa,
            "Re_unit" => jednotka("Re"),
            "Re_min" => row.Re_min_MPa,
            "Re_min_unit" => jednotka("Re"),
            "Rm_min" => row.Rm_min_MPa,
            "Rm_min_unit" => jednotka("Rm"),
            "Rm_max" => row.Rm_max_MPa,
            "Rm_max_unit" => jednotka("Rm"),
            "A" => row.A_proc,
            "A_unit" => jednotka("A"),
            "KV" => row.KV_J,
            "KV_unit" => jednotka("KV"),
            "T_KV" => row.T_KV_degC,
            "T_KV_unit" => jednotka("T_KV"),
            "svaritelnost" => row.svaritelnost,
            "E" => row.E_GPa,
            "E_unit" => jednotka("E"),
            "G" => row.G_GPa,
            "G_unit" => jednotka("G"),
            "alfa" => row.alfa_1_K,
            "alfa_unit" => jednotka("alfa"),
            "ny" => row.ny,
            "ny_unit" => jednotka("ny"),
            "rho" => row.rho_kg_m3,
            "rho_unit" => jednotka("rho")
        )
        merge!(VV, dalsi_vlastnosti)
        if VV !== nothing
            return VV
        else
            return nothing
        end
    elseif druh == "litina"
        namesLitina = ["stav", "zpracovani", "vlastnosti", "pouziti", "svaritelnost",
            "obrobitelnost", "korozivzdorna"]
        tabulky = Set(row.name for row in DBInterface.execute(
            db, "SELECT name FROM sqlite_master WHERE type = 'table'"))
        if "litina_velicina" in tabulky
            result = DBInterface.execute(
                db,
                "SELECT " * join(vcat(["id"], names, namesLitina), ", ") *
                    " FROM litina WHERE " * name * " = ? LIMIT 1", (celeoznaceni,))
            rows = [NamedTuple(row) for row in result]
            isempty(rows) && return nothing
            litina = first(rows)

            vlastnosti = Dict{Tuple{String,String},Any}()
            for value in DBInterface.execute(
                db,
                "SELECT v.kod, lv.varianta, lv.hodnota " *
                    "FROM litina_velicina lv " *
                    "JOIN velicina v ON v.id = lv.velicina_id " *
                    "WHERE lv.litina_id = ? AND lv.rozsah_od_mm IS NULL " *
                    "AND lv.rozsah_do_mm IS NULL", (litina.id,))
                vlastnosti[(value.kod, value.varianta)] = value.hodnota
            end
            property_litina = function (kod, varianta="zakladni")
                value = get(vlastnosti, (kod, varianta), 0.0)
                value === nothing || ismissing(value) ? 0.0 : value
            end

            row = (
                name_ISO=ismissing(litina.name_ISO) ? "" : litina.name_ISO,
                znacka_EN=ismissing(litina.znacka_EN) ? "" : litina.znacka_EN,
                cislo_EN=ismissing(litina.cislo_EN) ? "" : litina.cislo_EN,
                name_CSN=ismissing(litina.name_CSN) ? "" : litina.name_CSN,
                name_DIN=ismissing(litina.name_DIN) ? "" : litina.name_DIN,
                norma_CSN=litina.norma_CSN,
                druh=litina.druh,
                Rm_tah_MPa=property_litina("Rm"),
                Rm_tlak_MPa=property_litina("Rm_tlak"),
                A_proc=property_litina("A"),
                HB_min=property_litina("HB", "min"),
                HB_max=property_litina("HB", "max"),
                E_GPa=property_litina("E"),
                G_GPa=property_litina("G"),
                alfa_1_K=property_litina("alfa"),
                ny=property_litina("ny"),
                rho_kg_m3=property_litina("rho")
            )
        end
        VV = Dict{String,Any}(
            "name_ISO" => row.name_ISO,
            "znacka_EN" => row.znacka_EN,
            "cislo_EN" => row.cislo_EN,
            "name_CSN" => row.name_CSN,
            "name_DIN" => row.name_DIN,
            "standard" => standard,
            "norma_CSN" => row.norma_CSN,
            "druh" => row.druh,
            "Rm_tah" => row.Rm_tah_MPa,
            "Rm_tah_unit" => jednotka("Rm"),
            "Rm_tlak" => row.Rm_tlak_MPa,
            "Rm_tlak_unit" => jednotka("Rm_tlak"),
            "A" => row.A_proc,
            "A_unit" => jednotka("A"),
            "HB_min" => row.HB_min,
            "HB_min_unit" => jednotka("HB"),
            "HB_max" => row.HB_max,
            "HB_max_unit" => jednotka("HB"),
            "E" => row.E_GPa,
            "E_unit" => jednotka("E"),
            "G" => row.G_GPa,
            "G_unit" => jednotka("G"),
            "alfa" => row.alfa_1_K,
            "alfa_unit" => jednotka("alfa"),
            "ny" => row.ny,
            "ny_unit" => jednotka("ny"),
            "rho" => row.rho_kg_m3,
            "rho_unit" => jednotka("rho")
        )
        if VV !== nothing
            return VV
        else
            return nothing
        end
    elseif druh == "pryz"
        namesPryz = ["stav", "zpracovani", "vlastnosti", "pouziti", "odolnost_olej", 
            "odolnost_ozon", "odolnost_oder"]
        result = DBInterface.execute(
            db,
            "SELECT " * join(vcat(["id"], names, namesPryz), ", ") *
                " FROM pryz WHERE " * name * " = ? LIMIT 1",
            (celeoznaceni,))
        rows = [NamedTuple(row) for row in result]
        isempty(rows) && return nothing
        pryz = first(rows)

        properties = Dict{Tuple{String,String},Any}()
        for value in DBInterface.execute(
            db,
            "SELECT v.kod, pv.varianta, pv.hodnota " *
                "FROM pryz_velicina pv " *
                "JOIN velicina v ON v.id = pv.velicina_id " *
                "WHERE pv.pryz_id = ? AND pv.rozsah_od_mm IS NULL " *
                "AND pv.rozsah_do_mm IS NULL", (pryz.id,))
            properties[(value.kod, value.varianta)] = value.hodnota
        end
        property_pryz = function (kod, varianta="zakladni", zalozni=nothing)
            hodnota = get(properties, (kod, varianta), nothing)
            if (hodnota === nothing || ismissing(hodnota)) && zalozni !== nothing
                hodnota = get(properties, (kod, zalozni), nothing)
            end
            hodnota === nothing || ismissing(hodnota) ? 0.0 : hodnota
        end
        textvalue = value -> ismissing(value) ? "" : value
        VV = Dict{String,Any}(
            "name_ISO" => textvalue(pryz.name_ISO),
            "znacka_EN" => textvalue(pryz.znacka_EN),
            "cislo_EN" => textvalue(pryz.cislo_EN),
            "name_CSN" => textvalue(pryz.name_CSN),
            "name_DIN" => textvalue(pryz.name_DIN),
            "standard" => standard,
            "norma" => textvalue(pryz.norma_CSN),
            "druh" => textvalue(pryz.druh),
            "hardness" => property_pryz("tvrdost_ShA"),
            "hardness_unit" => jednotka("tvrdost_ShA"),
            "E" => property_pryz("E"),
            "E_unit" => jednotka("E"),
            "G" => property_pryz("G"),
            "G_unit" => jednotka("G"),
            "ny" => property_pryz("ny"),
            "ny_unit" => jednotka("ny"),
            "rho" => property_pryz("rho"),
            "rho_unit" => jednotka("rho"),
            "stav" => textvalue(pryz.stav),
            "zpracovani" => textvalue(pryz.zpracovani),
            "vlastnosti" => textvalue(pryz.vlastnosti),
            "pouziti" => textvalue(pryz.pouziti),
            "odolnost_olej" => textvalue(pryz.odolnost_olej),
            "odolnost_ozon" => textvalue(pryz.odolnost_ozon),
            "odolnost_oder" => textvalue(pryz.odolnost_oder)
        )
        if VV !== nothing
            return VV
        else
            return nothing
        end
    elseif druh == "nezelezne kovy"
        namesNezelezneKovy = ["stav", "zpracovani", "vlastnosti", "pouziti", "svaritelnost",
            "obrobitelnost", "korozivzdorna"]
        result = DBInterface.execute(
            db,
            "SELECT " * join(vcat(["id"], names, namesNezelezneKovy), ", ") *
                " FROM nezelezne_kovy WHERE " * name * " = ? LIMIT 1",
            (celeoznaceni,))
        rows = [NamedTuple(row) for row in result]
        isempty(rows) && return nothing
        kov = first(rows)

        properties = Dict{Tuple{String,String},Any}()
        for value in DBInterface.execute(
            db,
            "SELECT v.kod, nkv.varianta, nkv.hodnota " *
                "FROM nezelezne_kovy_velicina nkv " *
                "JOIN velicina v ON v.id = nkv.velicina_id " *
                "WHERE nkv.nezelezne_kovy_id = ? AND nkv.rozsah_od_mm IS NULL " *
                "AND nkv.rozsah_do_mm IS NULL", (kov.id,))
            properties[(value.kod, value.varianta)] = value.hodnota
        end
        property_kov = function (kod, varianta="zakladni", zalozni=nothing)
            hodnota = get(properties, (kod, varianta), nothing)
            if (hodnota === nothing || ismissing(hodnota)) && zalozni !== nothing
                hodnota = get(properties, (kod, zalozni), nothing)
            end
            hodnota === nothing || ismissing(hodnota) ? 0.0 : hodnota
        end
        textvalue = value -> ismissing(value) ? "" : value
        VV = Dict{String,Any}(
            "name_ISO" => textvalue(kov.name_ISO),
            "znacka_EN" => textvalue(kov.znacka_EN),
            "cislo_EN" => textvalue(kov.cislo_EN),
            "name_CSN" => textvalue(kov.name_CSN),
            "name_DIN" => textvalue(kov.name_DIN),
            "standard" => standard,
            "norma" => textvalue(kov.norma_CSN),
            "druh" => textvalue(kov.druh),
            "Rp0_2" => property_kov("Rp0.2", "min"),
            "Rp0_2_unit" => jednotka("Rp0.2"),
            "Rp0_2_max" => property_kov("Rp0.2", "max"),
            "Rp0_2_max_unit" => jednotka("Rp0.2"),
            "Rm_min" => property_kov("Rm", "min"),
            "Rm_min_unit" => jednotka("Rm"),
            "Rm_max" => property_kov("Rm", "max"),
            "Rm_max_unit" => jednotka("Rm"),
            "A" => property_kov("A", "min"),
            "A_unit" => jednotka("A"),
            "E" => property_kov("E"),
            "E_unit" => jednotka("E"),
            "G" => property_kov("G"),
            "G_unit" => jednotka("G"),
            "alfa" => property_kov("alfa"),
            "alfa_unit" => jednotka("alfa"),
            "ny" => property_kov("ny"),
            "ny_unit" => jednotka("ny"),
            "rho" => property_kov("rho"),
            "rho_unit" => jednotka("rho"),
            "stav" => textvalue(kov.stav),
            "zpracovani" => textvalue(kov.zpracovani),
            "vlastnosti" => textvalue(kov.vlastnosti),
            "pouziti" => textvalue(kov.pouziti),
            "svaritelnost" => textvalue(kov.svaritelnost),
            "obrobitelnost" => textvalue(kov.obrobitelnost),
            "korozivzdorna" => textvalue(kov.korozivzdorna)
        )
        if VV !== nothing
            return VV
        else
            return nothing
        end
    elseif druh == "plasty"
        namesPlasty = ["stav", "skupina", "zpracovani", "vlastnosti", "pouziti",
            "chemicka_odolnost", "odolnost_uv", "horlavost"]
        result = DBInterface.execute(
            db,
            "SELECT " * join(vcat(["id"], names, namesPlasty), ", ") *
                " FROM plasty WHERE " * name * " = ? LIMIT 1",
            (celeoznaceni,))
        rows = [NamedTuple(row) for row in result]
        isempty(rows) && return nothing
        plast = first(rows)

        properties = Dict{Tuple{String,String},Any}()
        for value in DBInterface.execute(
            db,
            "SELECT v.kod, pv.varianta, pv.hodnota " *
                "FROM plasty_velicina pv " *
                "JOIN velicina v ON v.id = pv.velicina_id " *
                "WHERE pv.plasty_id = ? AND pv.rozsah_od_mm IS NULL " *
                "AND pv.rozsah_do_mm IS NULL", (plast.id,))
            properties[(value.kod, value.varianta)] = value.hodnota
        end
        property_plast = function (kod, varianta="zakladni", zalozni=nothing)
            hodnota = get(properties, (kod, varianta), nothing)
            if (hodnota === nothing || ismissing(hodnota)) && zalozni !== nothing
                hodnota = get(properties, (kod, zalozni), nothing)
            end
            hodnota === nothing || ismissing(hodnota) ? 0.0 : hodnota
        end
        textvalue = value -> ismissing(value) ? "" : value
        VV = Dict{String,Any}(
            "name_ISO" => textvalue(plast.name_ISO),
            "znacka_EN" => textvalue(plast.znacka_EN),
            "cislo_EN" => textvalue(plast.cislo_EN),
            "name_CSN" => textvalue(plast.name_CSN),
            "name_DIN" => textvalue(plast.name_DIN),
            "standard" => standard,
            "norma" => textvalue(plast.norma_CSN),
            "druh" => textvalue(plast.druh),
            "E" => property_plast("E"),
            "E_unit" => jednotka("E"),
            "G" => property_plast("G"),
            "G_unit" => jednotka("G"),
            "alfa" => property_plast("alfa"),
            "alfa_unit" => jednotka("alfa"),
            "ny" => property_plast("ny"),
            "ny_unit" => jednotka("ny"),
            "rho" => property_plast("rho"),
            "rho_unit" => jednotka("rho"),
            "stav" => textvalue(plast.stav),
            "skupina" => textvalue(plast.skupina),
            "zpracovani" => textvalue(plast.zpracovani),
            "vlastnosti" => textvalue(plast.vlastnosti),
            "pouziti" => textvalue(plast.pouziti),
            "chemicka_odolnost" => textvalue(plast.chemicka_odolnost),
            "odolnost_uv" => textvalue(plast.odolnost_uv),
            "horlavost" => textvalue(plast.horlavost)
        )
    else
        error("Unsupported material type: $druh")
    end

end
