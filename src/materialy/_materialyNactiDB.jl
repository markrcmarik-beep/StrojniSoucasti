# ver: 2026-10-19
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

function _materialyNactiDB(db, name, celeoznaceni, VVnormy, VVdruh)

    # ---------------------------------------------------------------------
    # pomocné funkce
    jednotky = Dict{String,String}()
    for velicina in DBInterface.execute(db, "SELECT kod, jednotka FROM velicina")
        hodnota = ismissing(velicina.jednotka) ? "" : string(velicina.jednotka)
        jednotky[velicina.kod] = hodnota
    end
    jednotka = kod -> get(jednotky, kod, "")
    textvalue = value -> ismissing(value) ? "" : value

    VVvstup = Dict{String,Any}(
        "VVnormy" => VVnormy, # doplněno
        "VVdruh" => VVdruh # doplněno
    )
    property = function (kod, varianta="zakladni", zalozni=nothing)
        hodnota = get(properties, (kod, varianta), nothing)
        if (hodnota === nothing || ismissing(hodnota)) && zalozni !== nothing
            hodnota = get(properties, (kod, zalozni), nothing)
        end
        hodnota === nothing || ismissing(hodnota) ? missing : hodnota
    end
    # ---------------------------------------------------------------------
    names = ["name", "name_ISO", "znacka_EN", "cislo_EN", "name_CSN", "name_DIN", "norma_CSN", "druh"]
    if VVdruh == "ocel"
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
                druh=textvalue(steel.druh)
            )
            VVnames = Dict{String,Any}(
                "name" => row.name, # název materiálu
                "name_ISO" => row.name_ISO, # název ISO
                "znacka_EN" => row.znacka_EN, # název EN značka
                "cislo_EN" => row.cislo_EN, # název EN číslo
                "name_CSN" => row.name_CSN, # název ČSN
                "name_DIN" => row.name_DIN, # název DIN
                "norma_CSN" => row.norma_CSN,
                "druh" => row.druh,
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
                "Rp0_1" => property("Rp0.1", "zakladni"),
                "Rp0_1_unit" => jednotka("Rp0.1"),
                "Rp0_2" => property("Rp0.2", "zakladni", "min"),
                "Rp0_2_unit" => jednotka("Rp0.2"),
                "A" => property("A", "zakladni", "min"),
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
                "rho_unit" => jednotka("rho"),
                "tvrdost_HB" => property("HB"),
                "tvrdost_HB_unit" => jednotka("HB"),
                "tvrdost_HB_min" => property("HB", "min"),
                "tvrdost_HB_min_unit" => jednotka("HB"),
                "tvrdost_HB_max" => property("HB", "max"),
                "tvrdost_HB_max_unit" => jednotka("HB"),
                "tvrdost_HV" => property("HV"),
                "tvrdost_HV_unit" => jednotka("HV"),
                "tvrdost_HRC" => property("HRC"),
                "tvrdost_HRC_unit" => jednotka("HRC"),
                "Rm_tlak" => property("Rm_tlak"),
                "Rm_tlak_unit" => jednotka("Rm_tlak"),
                "M100" => property("M100"),
                "M100_unit" => jednotka("M100"),
                "TS" => property("TS"),
                "TS_unit" => jednotka("TS"),
                "tvrdost_ShA" => property("tvrdost_ShA"),
                "tvrdost_ShA_unit" => jednotka("tvrdost_ShA"),
                "T_min" => property("T_min"),
                "T_min_unit" => jednotka("T_min"),
                "T_max" => property("T_max"),
                "T_max_unit" => jednotka("T_max"),
                "compression_set" => property("compression_set"),
                "compression_set_unit" => jednotka("compression_set"),
                "A_break" => property("A_break"),
                "A_break_unit" => jednotka("A_break"),
                "E_tah" => property("E_tah"),
                "E_tah_unit" => jednotka("E_tah"),
                "Rm_tlak_1" => property("Rm_tlak_1"),
                "Rm_tlak_1_unit" => jednotka("Rm_tlak_1"),
                "Rm_tlak_2" => property("Rm_tlak_2"),
                "Rm_tlak_2_unit" => jednotka("Rm_tlak_2"),
                "Rm_tlak_5" => property("Rm_tlak_5"),
                "Rm_tlak_5_unit" => jednotka("Rm_tlak_5"),
                "creep_1000h" => property("creep_1000h"),
                "creep_1000h_unit" => jednotka("creep_1000h"),
                "KV_charpy" => property("KV_charpy"),
                "KV_charpy_unit" => jednotka("KV_charpy"),
                "tvrdost_kulicka" => property("tvrdost_kulicka"),
                "tvrdost_kulicka_unit" => jednotka("tvrdost_kulicka"),
                "mu_smyk" => property("mu_smyk"),
                "mu_smyk_unit" => jednotka("mu_smyk")
            )

            VVrozsahy = Dict{String,Any}(
                "Re_rozsahy" => re_rozsahy
            )
        end

        VV=merge(VVvstup, VVnames, VVnamesOcel, VVvelicina, VVrozsahy)
        return VV
        #if VVnames !== nothing
        #    return VV
        #else
        #    return nothing
        #end
    elseif VVdruh == "litina"
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

            properties = Dict{Tuple{String,String},Any}()
            for value in DBInterface.execute(
                db,
                "SELECT v.kod, lv.varianta, lv.hodnota " *
                    "FROM litina_velicina lv " *
                    "JOIN velicina v ON v.id = lv.velicina_id " *
                    "WHERE lv.litina_id = ? AND lv.rozsah_od_mm IS NULL " *
                    "AND lv.rozsah_do_mm IS NULL", (litina.id,))
                    properties[(value.kod, value.varianta)] = value.hodnota
            end

            row = (
                name=ismissing(litina.name) ? "" : litina.name,
                name_ISO=ismissing(litina.name_ISO) ? "" : litina.name_ISO,
                znacka_EN=ismissing(litina.znacka_EN) ? "" : litina.znacka_EN,
                cislo_EN=ismissing(litina.cislo_EN) ? "" : litina.cislo_EN,
                name_CSN=ismissing(litina.name_CSN) ? "" : litina.name_CSN,
                name_DIN=ismissing(litina.name_DIN) ? "" : litina.name_DIN,
                norma_CSN=ismissing(litina.norma_CSN) ? "" : litina.norma_CSN,
                druh=textvalue(litina.druh)
            )
        end
            VVnames = Dict{String,Any}(
                "name" => row.name, # název materiálu
                "name_ISO" => row.name_ISO, # název ISO
                "znacka_EN" => row.znacka_EN, # název EN značka
                "cislo_EN" => row.cislo_EN, # název EN číslo
                "name_CSN" => row.name_CSN, # název ČSN
                "name_DIN" => row.name_DIN, # název DIN
                "norma_CSN" => row.norma_CSN,
                "druh" => row.druh
            )
            VVnamesLitina = Dict{String,Any}(
                "stav" => textvalue(litina.stav),
                "zpracovani" => textvalue(litina.zpracovani),
                "vlastnosti" => textvalue(litina.vlastnosti),
                "pouziti" => textvalue(litina.pouziti),
                "svaritelnost" => textvalue(litina.svaritelnost),
                "obrobitelnost" => textvalue(litina.obrobitelnost),
                "korozivzdorna" => textvalue(litina.korozivzdorna),
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
                "Rp0_1" => property("Rp0.1", "zakladni"),
                "Rp0_1_unit" => jednotka("Rp0.1"),
                "Rp0_2" => property("Rp0.2", "zakladni", "min"),
                "Rp0_2_unit" => jednotka("Rp0.2"),
                "A" => property("A", "zakladni", "min"),
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
                "rho_unit" => jednotka("rho"),
                "tvrdost_HB" => property("HB"),
                "tvrdost_HB_unit" => jednotka("HB"),
                "tvrdost_HB_min" => property("HB", "min"),
                "tvrdost_HB_min_unit" => jednotka("HB"),
                "tvrdost_HB_max" => property("HB", "max"),
                "tvrdost_HB_max_unit" => jednotka("HB"),
                "tvrdost_HV" => property("HV"),
                "tvrdost_HV_unit" => jednotka("HV"),
                "tvrdost_HRC" => property("HRC"),
                "tvrdost_HRC_unit" => jednotka("HRC"),
                "Rm_tlak" => property("Rm_tlak"),
                "Rm_tlak_unit" => jednotka("Rm_tlak"),
                "M100" => property("M100"),
                "M100_unit" => jednotka("M100"),
                "TS" => property("TS"),
                "TS_unit" => jednotka("TS"),
                "tvrdost_ShA" => property("tvrdost_ShA"),
                "tvrdost_ShA_unit" => jednotka("tvrdost_ShA"),
                "T_min" => property("T_min"),
                "T_min_unit" => jednotka("T_min"),
                "T_max" => property("T_max"),
                "T_max_unit" => jednotka("T_max"),
                "compression_set" => property("compression_set"),
                "compression_set_unit" => jednotka("compression_set"),
                "A_break" => property("A_break"),
                "A_break_unit" => jednotka("A_break"),
                "E_tah" => property("E_tah"),
                "E_tah_unit" => jednotka("E_tah"),
                "Rm_tlak_1" => property("Rm_tlak_1"),
                "Rm_tlak_1_unit" => jednotka("Rm_tlak_1"),
                "Rm_tlak_2" => property("Rm_tlak_2"),
                "Rm_tlak_2_unit" => jednotka("Rm_tlak_2"),
                "Rm_tlak_5" => property("Rm_tlak_5"),
                "Rm_tlak_5_unit" => jednotka("Rm_tlak_5"),
                "creep_1000h" => property("creep_1000h"),
                "creep_1000h_unit" => jednotka("creep_1000h"),
                "KV_charpy" => property("KV_charpy"),
                "KV_charpy_unit" => jednotka("KV_charpy"),
                "tvrdost_kulicka" => property("tvrdost_kulicka"),
                "tvrdost_kulicka_unit" => jednotka("tvrdost_kulicka"),
                "mu_smyk" => property("mu_smyk"),
                "mu_smyk_unit" => jednotka("mu_smyk")
            )

        VV=merge(VVvstup, VVnames, VVnamesLitina, VVvelicina)
        return VV
        #if VV !== nothing
        #    return VV
        #else
        #    return nothing
        #end
    elseif VVdruh == "pryz"
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

            row = (
                name=ismissing(pryz.name) ? "" : pryz.name,
                name_ISO=ismissing(pryz.name_ISO) ? "" : pryz.name_ISO,
                znacka_EN=ismissing(pryz.znacka_EN) ? "" : pryz.znacka_EN,
                cislo_EN=ismissing(pryz.cislo_EN) ? "" : pryz.cislo_EN,
                name_CSN=ismissing(pryz.name_CSN) ? "" : pryz.name_CSN,
                name_DIN=ismissing(pryz.name_DIN) ? "" : pryz.name_DIN,
                norma_CSN=textvalue(pryz.norma_CSN),
                druh=textvalue(pryz.druh)
            )

            VVnames = Dict{String,Any}(
                "name" => row.name, # název materiálu
                "name_ISO" => row.name_ISO, # název ISO
                "znacka_EN" => row.znacka_EN, # název EN značka
                "cislo_EN" => row.cislo_EN, # název EN číslo
                "name_CSN" => row.name_CSN, # název ČSN
                "name_DIN" => row.name_DIN, # název DIN
                "norma_CSN" => row.norma_CSN,
                "druh" => row.druh,
            )
            VVnamesPryz = Dict{String,Any}(
                "stav" => textvalue(pryz.stav),
                "zpracovani" => textvalue(pryz.zpracovani),
                "vlastnosti" => textvalue(pryz.vlastnosti),
                "pouziti" => textvalue(pryz.pouziti),
                "odolnost_olej" => textvalue(pryz.odolnost_olej),
                "odolnost_ozon" => textvalue(pryz.odolnost_ozon),
                "odolnost_oder" => textvalue(pryz.odolnost_oder),
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
                "Rp0_1" => property("Rp0.1", "zakladni"),
                "Rp0_1_unit" => jednotka("Rp0.1"),
                "Rp0_2" => property("Rp0.2", "zakladni", "min"),
                "Rp0_2_unit" => jednotka("Rp0.2"),
                "A" => property("A", "zakladni", "min"),
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
                "rho_unit" => jednotka("rho"),
                "tvrdost_HB" => property("HB"),
                "tvrdost_HB_unit" => jednotka("HB"),
                "tvrdost_HB_min" => property("HB", "min"),
                "tvrdost_HB_min_unit" => jednotka("HB"),
                "tvrdost_HB_max" => property("HB", "max"),
                "tvrdost_HB_max_unit" => jednotka("HB"),
                "tvrdost_HV" => property("HV"),
                "tvrdost_HV_unit" => jednotka("HV"),
                "tvrdost_HRC" => property("HRC"),
                "tvrdost_HRC_unit" => jednotka("HRC"),
                "Rm_tlak" => property("Rm_tlak"),
                "Rm_tlak_unit" => jednotka("Rm_tlak"),
                "M100" => property("M100"),
                "M100_unit" => jednotka("M100"),
                "TS" => property("TS"),
                "TS_unit" => jednotka("TS"),
                "tvrdost_ShA" => property("tvrdost_ShA"),
                "tvrdost_ShA_unit" => jednotka("tvrdost_ShA"),
                "T_min" => property("T_min"),
                "T_min_unit" => jednotka("T_min"),
                "T_max" => property("T_max"),
                "T_max_unit" => jednotka("T_max"),
                "compression_set" => property("compression_set"),
                "compression_set_unit" => jednotka("compression_set"),
                "A_break" => property("A_break"),
                "A_break_unit" => jednotka("A_break"),
                "E_tah" => property("E_tah"),
                "E_tah_unit" => jednotka("E_tah"),
                "Rm_tlak_1" => property("Rm_tlak_1"),
                "Rm_tlak_1_unit" => jednotka("Rm_tlak_1"),
                "Rm_tlak_2" => property("Rm_tlak_2"),
                "Rm_tlak_2_unit" => jednotka("Rm_tlak_2"),
                "Rm_tlak_5" => property("Rm_tlak_5"),
                "Rm_tlak_5_unit" => jednotka("Rm_tlak_5"),
                "creep_1000h" => property("creep_1000h"),
                "creep_1000h_unit" => jednotka("creep_1000h"),
                "KV_charpy" => property("KV_charpy"),
                "KV_charpy_unit" => jednotka("KV_charpy"),
                "tvrdost_kulicka" => property("tvrdost_kulicka"),
                "tvrdost_kulicka_unit" => jednotka("tvrdost_kulicka"),
                "mu_smyk" => property("mu_smyk"),
                "mu_smyk_unit" => jednotka("mu_smyk")
            )

        VV=merge(VVvstup, VVnames, VVnamesPryz, VVvelicina)
        return VV
    elseif VVdruh == "nezelezne kovy"
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
            row = (
                name=ismissing(kov.name) ? "" : kov.name,
                name_ISO=ismissing(kov.name_ISO) ? "" : kov.name_ISO,
                znacka_EN=ismissing(kov.znacka_EN) ? "" : kov.znacka_EN,
                cislo_EN=ismissing(kov.cislo_EN) ? "" : kov.cislo_EN,
                name_CSN=ismissing(kov.name_CSN) ? "" : kov.name_CSN,
                name_DIN=ismissing(kov.name_DIN) ? "" : kov.name_DIN,
                norma_CSN=textvalue(kov.norma_CSN),
                druh=textvalue(kov.druh)
            )

            VVnames = Dict{String,Any}(
                "name" => row.name, # název materiálu
                "name_ISO" => row.name_ISO, # název ISO
                "znacka_EN" => row.znacka_EN, # název EN značka
                "cislo_EN" => row.cislo_EN, # název EN číslo
                "name_CSN" => row.name_CSN, # název ČSN
                "name_DIN" => row.name_DIN, # název DIN
                "norma_CSN" => row.norma_CSN,
                "druh" => row.druh
            )
            VVnamesKov = Dict{String,Any}(
                "stav" => textvalue(kov.stav),
                "zpracovani" => textvalue(kov.zpracovani),
                "vlastnosti" => textvalue(kov.vlastnosti),
                "pouziti" => textvalue(kov.pouziti),
                "svaritelnost" => textvalue(kov.svaritelnost),
                "obrobitelnost" => textvalue(kov.obrobitelnost),
                "korozivzdorna" => textvalue(kov.korozivzdorna)
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
                "Rp0_1" => property("Rp0.1", "zakladni"),
                "Rp0_1_unit" => jednotka("Rp0.1"),
                "Rp0_2" => property("Rp0.2", "zakladni", "min"),
                "Rp0_2_unit" => jednotka("Rp0.2"),
                "A" => property("A", "zakladni", "min"),
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
                "rho_unit" => jednotka("rho"),
                "tvrdost_HB" => property("HB"),
                "tvrdost_HB_unit" => jednotka("HB"),
                "tvrdost_HB_min" => property("HB", "min"),
                "tvrdost_HB_min_unit" => jednotka("HB"),
                "tvrdost_HB_max" => property("HB", "max"),
                "tvrdost_HB_max_unit" => jednotka("HB"),
                "tvrdost_HV" => property("HV"),
                "tvrdost_HV_unit" => jednotka("HV"),
                "tvrdost_HRC" => property("HRC"),
                "tvrdost_HRC_unit" => jednotka("HRC"),
                "Rm_tlak" => property("Rm_tlak"),
                "Rm_tlak_unit" => jednotka("Rm_tlak"),
                "M100" => property("M100"),
                "M100_unit" => jednotka("M100"),
                "TS" => property("TS"),
                "TS_unit" => jednotka("TS"),
                "tvrdost_ShA" => property("tvrdost_ShA"),
                "tvrdost_ShA_unit" => jednotka("tvrdost_ShA"),
                "T_min" => property("T_min"),
                "T_min_unit" => jednotka("T_min"),
                "T_max" => property("T_max"),
                "T_max_unit" => jednotka("T_max"),
                "compression_set" => property("compression_set"),
                "compression_set_unit" => jednotka("compression_set"),
                "A_break" => property("A_break"),
                "A_break_unit" => jednotka("A_break"),
                "E_tah" => property("E_tah"),
                "E_tah_unit" => jednotka("E_tah"),
                "Rm_tlak_1" => property("Rm_tlak_1"),
                "Rm_tlak_1_unit" => jednotka("Rm_tlak_1"),
                "Rm_tlak_2" => property("Rm_tlak_2"),
                "Rm_tlak_2_unit" => jednotka("Rm_tlak_2"),
                "Rm_tlak_5" => property("Rm_tlak_5"),
                "Rm_tlak_5_unit" => jednotka("Rm_tlak_5"),
                "creep_1000h" => property("creep_1000h"),
                "creep_1000h_unit" => jednotka("creep_1000h"),
                "KV_charpy" => property("KV_charpy"),
                "KV_charpy_unit" => jednotka("KV_charpy"),
                "tvrdost_kulicka" => property("tvrdost_kulicka"),
                "tvrdost_kulicka_unit" => jednotka("tvrdost_kulicka"),
                "mu_smyk" => property("mu_smyk"),
                "mu_smyk_unit" => jednotka("mu_smyk")
            )

        VV=merge(VVvstup, VVnames, VVnamesKov, VVvelicina)
        return VV
    elseif VVdruh == "plasty"
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
            row = (
                name=ismissing(plast.name) ? "" : plast.name,
                name_ISO=ismissing(plast.name_ISO) ? "" : plast.name_ISO,
                znacka_EN=ismissing(plast.znacka_EN) ? "" : plast.znacka_EN,
                cislo_EN=ismissing(plast.cislo_EN) ? "" : plast.cislo_EN,
                name_CSN=ismissing(plast.name_CSN) ? "" : plast.name_CSN,
                name_DIN=ismissing(plast.name_DIN) ? "" : plast.name_DIN,
                norma_CSN=textvalue(plast.norma_CSN),
                druh=textvalue(plast.druh)
            )

            VVnames = Dict{String,Any}(
                "name" => row.name, # název materiálu
                "name_ISO" => row.name_ISO, # název ISO
                "znacka_EN" => row.znacka_EN, # název EN značka
                "cislo_EN" => row.cislo_EN, # název EN číslo
                "name_CSN" => row.name_CSN, # název ČSN
                "name_DIN" => row.name_DIN, # název DIN
                "norma_CSN" => row.norma_CSN,
                "druh" => row.druh
            )
            VVnamesKov = Dict{String,Any}(
                "stav" => textvalue(plast.stav),
                "zpracovani" => textvalue(plast.zpracovani),
                "vlastnosti" => textvalue(plast.vlastnosti),
                "pouziti" => textvalue(plast.pouziti),
                "chemicka_odolnost" => textvalue(plast.chemicka_odolnost),
                "odolnost_uv" => textvalue(plast.odolnost_uv),
                "horlavost" => textvalue(plast.horlavost)
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
                "Rp0_1" => property("Rp0.1", "zakladni"),
                "Rp0_1_unit" => jednotka("Rp0.1"),
                "Rp0_2" => property("Rp0.2", "zakladni", "min"),
                "Rp0_2_unit" => jednotka("Rp0.2"),
                "A" => property("A", "zakladni", "min"),
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
                "rho_unit" => jednotka("rho"),
                "tvrdost_HB" => property("HB"),
                "tvrdost_HB_unit" => jednotka("HB"),
                "tvrdost_HB_min" => property("HB", "min"),
                "tvrdost_HB_min_unit" => jednotka("HB"),
                "tvrdost_HB_max" => property("HB", "max"),
                "tvrdost_HB_max_unit" => jednotka("HB"),
                "tvrdost_HV" => property("HV"),
                "tvrdost_HV_unit" => jednotka("HV"),
                "tvrdost_HRC" => property("HRC"),
                "tvrdost_HRC_unit" => jednotka("HRC"),
                "Rm_tlak" => property("Rm_tlak"),
                "Rm_tlak_unit" => jednotka("Rm_tlak"),
                "M100" => property("M100"),
                "M100_unit" => jednotka("M100"),
                "TS" => property("TS"),
                "TS_unit" => jednotka("TS"),
                "tvrdost_ShA" => property("tvrdost_ShA"),
                "tvrdost_ShA_unit" => jednotka("tvrdost_ShA"),
                "T_min" => property("T_min"),
                "T_min_unit" => jednotka("T_min"),
                "T_max" => property("T_max"),
                "T_max_unit" => jednotka("T_max"),
                "compression_set" => property("compression_set"),
                "compression_set_unit" => jednotka("compression_set"),
                "A_break" => property("A_break"),
                "A_break_unit" => jednotka("A_break"),
                "E_tah" => property("E_tah"),
                "E_tah_unit" => jednotka("E_tah"),
                "Rm_tlak_1" => property("Rm_tlak_1"),
                "Rm_tlak_1_unit" => jednotka("Rm_tlak_1"),
                "Rm_tlak_2" => property("Rm_tlak_2"),
                "Rm_tlak_2_unit" => jednotka("Rm_tlak_2"),
                "Rm_tlak_5" => property("Rm_tlak_5"),
                "Rm_tlak_5_unit" => jednotka("Rm_tlak_5"),
                "creep_1000h" => property("creep_1000h"),
                "creep_1000h_unit" => jednotka("creep_1000h"),
                "KV_charpy" => property("KV_charpy"),
                "KV_charpy_unit" => jednotka("KV_charpy"),
                "tvrdost_kulicka" => property("tvrdost_kulicka"),
                "tvrdost_kulicka_unit" => jednotka("tvrdost_kulicka"),
                "mu_smyk" => property("mu_smyk"),
                "mu_smyk_unit" => jednotka("mu_smyk")
            )

        VV=merge(VVvstup, VVnames, VVnamesKov, VVvelicina)
        return VV
    else
        error("Unsupported material type: $VVdruh")
    end

end
