# ver: 2026-10-13
## Funkce: materialyObecne()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/materialy/materialyObecne.jl
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
function materialyObecne(db, name::AbstractString)::Union{Dict{String, Any},
    Nothing}
# ---------------------------------------------------------------------
# pomocné funkce

# pomocné funkce konec
# ---------------------------------------------------------------------
    # -----------------------------------------------------
    # Ocel , Ocel na lití
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name", name, "obecne", "ocel")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # litina
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name", name, "obecne", "litina")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # pryž
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name", name, "obecne", "pryz")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # meželezné kovy
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name", name, "obecne", "nezelezne kovy")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # plasty
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name", name, "obecne", "plasty")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # dřevo
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name", name, "obecne", "drevo")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # nestandartni
    # -----------------------------------------------------

    return nothing
end
