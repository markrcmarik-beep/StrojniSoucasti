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
    nazvy = material -> Dict{String,Any}(
        "name" => textvalue(material.name),
        "name_ISO" => textvalue(material.name_ISO),
        "znacka_EN" => textvalue(material.znacka_EN),
        "cislo_EN" => textvalue(material.cislo_EN),
        "name_CSN" => textvalue(material.name_CSN),
        "name_DIN" => textvalue(material.name_DIN),
        "norma_CSN" => textvalue(material.norma_CSN),
        "druh" => textvalue(material.druh)
    )

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
    veliciny = function ()
        Dict{String,Any}(
            "Re" => property("Re", "zakladni", "min"),
            "Re_unit" => jednotka("Re"),
            "Re_min" => property("Re", "min"),
            "Re_min_unit" => jednotka("Re"),
            "Re_max" => property("Re", "max"),
            "Re_max_unit" => jednotka("Re"),
            "Rm" => property("Rm", "zakladni", "min"),
            "Rm_unit" => jednotka("Rm"),
            "Rm_min" => property("Rm", "min"),
            "Rm_min_unit" => jednotka("Rm"),
            "Rm_max" => property("Rm", "max"),
            "Rm_max_unit" => jednotka("Rm"),
            "Rp0_1" => property("Rp0.1", "zakladni", "min"),
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
    end
    # ---------------------------------------------------------------------
    names = ["name", "name_ISO", "znacka_EN", "cislo_EN", "name_CSN", "name_DIN", "norma_CSN", "druh"]
    if VVdruh == "ocel"
        namesOcel = ["stav", "zpracovani", "vlastnosti", "pouziti", "svaritelnost", "obrobitelnost",
            "k_cementovani", "k_nitridovani", "k_zuslechtovani", "k_povrchovemu_kaleni",
            "korozivzdorna", "obvykla_jakost"]

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

            VVnames = nazvy(steel)
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
            VVvelicina = veliciny()

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

            VVnames = nazvy(litina)
        end
            VVnamesLitina = Dict{String,Any}(
                "stav" => textvalue(litina.stav),
                "zpracovani" => textvalue(litina.zpracovani),
                "vlastnosti" => textvalue(litina.vlastnosti),
                "pouziti" => textvalue(litina.pouziti),
                "svaritelnost" => textvalue(litina.svaritelnost),
                "obrobitelnost" => textvalue(litina.obrobitelnost),
                "korozivzdorna" => textvalue(litina.korozivzdorna),
            )
            VVvelicina = veliciny()

        VV=merge(VVvstup, VVnames, VVnamesLitina, VVvelicina)
        return VV

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

            VVnames = nazvy(pryz)
            VVnamesPryz = Dict{String,Any}(
                "stav" => textvalue(pryz.stav),
                "zpracovani" => textvalue(pryz.zpracovani),
                "vlastnosti" => textvalue(pryz.vlastnosti),
                "pouziti" => textvalue(pryz.pouziti),
                "odolnost_olej" => textvalue(pryz.odolnost_olej),
                "odolnost_ozon" => textvalue(pryz.odolnost_ozon),
                "odolnost_oder" => textvalue(pryz.odolnost_oder),
            )
            VVvelicina = veliciny()

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

            VVnames = nazvy(kov)
            VVnamesKov = Dict{String,Any}(
                "stav" => textvalue(kov.stav),
                "zpracovani" => textvalue(kov.zpracovani),
                "vlastnosti" => textvalue(kov.vlastnosti),
                "pouziti" => textvalue(kov.pouziti),
                "svaritelnost" => textvalue(kov.svaritelnost),
                "obrobitelnost" => textvalue(kov.obrobitelnost),
                "korozivzdorna" => textvalue(kov.korozivzdorna)
            )
            VVvelicina = veliciny()

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

            VVnames = nazvy(plast)
            VVnamesPlast = Dict{String,Any}(
                "stav" => textvalue(plast.stav),
                "zpracovani" => textvalue(plast.zpracovani),
                "vlastnosti" => textvalue(plast.vlastnosti),
                "pouziti" => textvalue(plast.pouziti),
                "chemicka_odolnost" => textvalue(plast.chemicka_odolnost),
                "odolnost_uv" => textvalue(plast.odolnost_uv),
                "horlavost" => textvalue(plast.horlavost)
            )
            VVvelicina = veliciny()

        VV=merge(VVvstup, VVnames, VVnamesPlast, VVvelicina)
        return VV
    elseif VVdruh == "drevo"
        namesDrevo = ["stav", "skupina", "zpracovani", "vlastnosti", "pouziti",
            "trvanlivost", "odolnost_vlhkost", "odolnost_houby_hmyz"]
        result = DBInterface.execute(
            db,
            "SELECT " * join(vcat(["id"], names, namesDrevo), ", ") *
                " FROM drevo WHERE " * name * " = ? LIMIT 1",
            (celeoznaceni,))
        rows = [NamedTuple(row) for row in result]
        isempty(rows) && return nothing
        plast = first(rows)

        properties = Dict{Tuple{String,String},Any}()
        for value in DBInterface.execute(
            db,
            "SELECT v.kod, pv.varianta, pv.hodnota " *
                "FROM drevo_velicina pv " *
                "JOIN velicina v ON v.id = pv.velicina_id " *
                "WHERE pv.drevo_id = ? AND pv.rozsah_od_mm IS NULL " *
                "AND pv.rozsah_do_mm IS NULL", (drevo.id,))
            properties[(value.kod, value.varianta)] = value.hodnota
        end

            VVnames = nazvy(drevo)
            VVnamesDrevo = Dict{String,Any}(
                "stav" => textvalue(drevo.stav),
                "zpracovani" => textvalue(drevo.zpracovani),
                "vlastnosti" => textvalue(drevo.vlastnosti),
                "pouziti" => textvalue(drevo.pouziti),
                "chemicka_odolnost" => textvalue(drevo.chemicka_odolnost),
                "odolnost_uv" => textvalue(drevo.odolnost_uv),
                "horlavost" => textvalue(drevo.horlavost)
            )
            VVvelicina = veliciny()

        VV=merge(VVvstup, VVnames, VVnamesDrevo, VVvelicina)
        return VV
    else
        error("Unsupported material type: $VVdruh")
    end

end
