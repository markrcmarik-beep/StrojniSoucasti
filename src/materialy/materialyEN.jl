# ver: 2026-10-13
## Funkce: materialyEN()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/materialy/materialyEN.jl
## Použité balíčky:
#
## Použité uživatelské funkce:
# _materialyNactiDB.jl
###############################################################
## Použité proměnné vnitřní:
#

"""
$(read(joinpath(@__DIR__, "..", "..", "docs", "src", "materialy", "materialyCSN.md"), String))
"""
function materialyEN(db, name::AbstractString)::Union{Dict{String, Any},
    Nothing}
# ---------------------------------------------------------------------
# pomocné funkce

# pomocné funkce konec
# ---------------------------------------------------------------------
    # -----------------------------------------------------
    # Ocel , Ocel na lití
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "znacka_EN", name, "EN", "ocel")
    if VV !== nothing
        return VV
    end
    VV = StrojniSoucasti._materialyNactiDB(db, "cislo_EN", name, "EN", "ocel")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # litina
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "znacka_EN", name, "EN", "litina")
    if VV !== nothing
        return VV
    end
    VV = StrojniSoucasti._materialyNactiDB(db, "cislo_EN", name, "EN", "litina")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # pryž
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "znacka_EN", name, "EN", "pryz")
    if VV !== nothing
        return VV
    end
    VV = StrojniSoucasti._materialyNactiDB(db, "cislo_EN", name, "EN", "pryz")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # meželezné kovy
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "znacka_EN", name, "EN", "nezelezne kovy")
    if VV !== nothing
        return VV
    end
    VV = StrojniSoucasti._materialyNactiDB(db, "cislo_EN", name, "EN", "nezelezne kovy")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # plasty
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "znacka_EN", name, "EN", "plasty")
    if VV !== nothing
        return VV
    end
    VV = StrojniSoucasti._materialyNactiDB(db, "cislo_EN", name, "EN", "plasty")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # dřevo
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "znacka_EN", name, "EN", "drevo")
    if VV !== nothing
        return VV
    end
    VV = StrojniSoucasti._materialyNactiDB(db, "cislo_EN", name, "EN", "drevo")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # nestandartni
    # -----------------------------------------------------

    return nothing
end
