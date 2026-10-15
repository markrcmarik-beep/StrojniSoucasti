# ver: 2026-10-14
## Funkce: materialyDIN()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/materialy/materialyDIN.jl
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
function materialyDIN(db, name::AbstractString)::Union{Dict{String, Any},
    Nothing}
# ---------------------------------------------------------------------
# pomocné funkce

# pomocné funkce konec
# ---------------------------------------------------------------------
    # -----------------------------------------------------
    # Ocel , Ocel na lití
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name_DIN", name, "-", "ocel")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # litina
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name_DIN", name, "-", "litina")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # pryž
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name_DIN", name, "-", "pryz")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # meželezné kovy
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name_DIN", name, "-", "nezelezne kovy")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # plasty
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name_DIN", name, "-", "plasty")
    if VV !== nothing
        return VV
    end
    # -----------------------------------------------------
    # dřevo
    # -----------------------------------------------------
    
    # -----------------------------------------------------
    # nestandartni
    # -----------------------------------------------------

    return nothing
end
