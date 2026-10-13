# ver: 2026-10-13
## Funkce: materialyCSN()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/materialy/materialyCSN.jl
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
# _materialyNactiDB.jl
###############################################################
## Použité proměnné vnitřní:
#
using TOML

"""
$(read(joinpath(@__DIR__, "..", "..", "docs", "src", "materialy", "materialyCSN.md"), String))
"""
function materialyCSN(db, name::AbstractString)::Union{Dict{String, Any},
    Nothing}
# ---------------------------------------------------------------------
# pomocné funkce

# pomocné funkce konec
# ---------------------------------------------------------------------
    # -----------------------------------------------------
    # OCEL (11-17, 19), Ocel na lití (42)
    # -----------------------------------------------------
    regex1a = r"^\s*(1[0-7]|19)\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$" # oceli (11-17, 19)
    m1a = match(regex1a, name)
    if m1a !== nothing
        #oznaceni, index1, index2, poznamky = rozpoznej_materialCSN(name)
        # Označení materiálu
        oznaceni = m1a.captures[1] * m1a.captures[2]
        # Indexy
        index = m1a.captures[3]
        index1 = nothing
        if index !== nothing
            index1 = parse(Int, index[1])
            if length(index) == 2
                index2 = parse(Int, index[2])
            end
        end
        # Poznámky
        poznamky = String[]
        if m1a.captures[4] !== nothing
            poznamky = [
                strip(p)
                for p in split(m1a.captures[4], ",")
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
        VV = StrojniSoucasti._materialyNactiDB(db, "name_CSN", celeoznaceni, "ČSN", "ocel")

        if VV !== nothing
           return VV
        end
    end
    regex1b = r"^\s*(42)\s?(\d{4})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$" # Ocel na lití
    m1b = match(regex1b, name)
    if m1b !== nothing
        oznaceni = m1b.captures[1] * m1b.captures[2]
        index = m1b.captures[3]
        index1 = nothing
        if index !== nothing
            index1 = parse(Int, index[1])
            if length(index) == 2
                index2 = parse(Int, index[2])
            end
        end
        poznamky = String[]
        if m1b.captures[4] !== nothing
            poznamky = [
                strip(p)
                for p in split(m1b.captures[4], ",")
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
        VV = StrojniSoucasti._materialyNactiDB(db, "name_CSN", celeoznaceni, "ČSN", "ocel")

        if VV !== nothing
           return VV
        end
    end
    # -----------------------------------------------------
    # LITINA (42)
    # -----------------------------------------------------
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

        celeoznaceni = oznaceni * (index === nothing ? "" : "." * index)
        VV = StrojniSoucasti._materialyNactiDB(db, "name_CSN", celeoznaceni, "ČSN", "litina")

        if VV !== nothing
           return VV
        end
    end
    # -----------------------------------------------------
    # PRYŽ (42)
    # -----------------------------------------------------
    regex3a = r"^\s*(42)\s?(\d{4})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$" # pryže
    m3a = match(regex3a, name)
    if m3a !== nothing
        oznaceni = m3a.captures[1] * m3a.captures[2]
        index = m3a.captures[3]
        index1 = nothing
        if index !== nothing
            index1 = parse(Int, index[1])
            if length(index) == 2
                index2 = parse(Int, index[2])
            end
        end
        celeoznaceni = oznaceni * (index === nothing ? "" : "." * index)
        VV = StrojniSoucasti._materialyNactiDB(db, "name_CSN", celeoznaceni, "ČSN", "pryz")

        if VV !== nothing
           return VV
        end
    end
    # -----------------------------------------------------
    # NEŽELEZNÉ KOVY
    # -----------------------------------------------------
    regex4a = r"^\s*(42)\s?(\d{4})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$" # kovy
    m4a = match(regex4a, name)
    regex4b = r"^\s*(1[0-7]|19)\s?(\d{3})(?:\.(\d{1,2}))?(?:\s+(.+?))?\s*$"
    m4b = match(regex4b, name)
    if m4a !== nothing || m4b !== nothing
        m4 = m4a === nothing ? m4b : m4a
        celeoznaceni = m4.captures[1] * m4.captures[2] *
            (m4.captures[3] === nothing ? "" : "." * m4.captures[3])
        VV = StrojniSoucasti._materialyNactiDB(db, "name_CSN", celeoznaceni, "ČSN", "nezelezne kovy")
        if VV !== nothing
            return VV
        end
    end
    # -----------------------------------------------------
    # PLASTY
    # -----------------------------------------------------
    
    # -----------------------------------------------------
    # nestandartni
    # -----------------------------------------------------
    VV = StrojniSoucasti._materialyNactiDB(db, "name_CSN", name, "ČSN", "ocel")
    if VV !== nothing
        return VV
    end
    VV = StrojniSoucasti._materialyNactiDB(db, "name_CSN", name, "ČSN", "litina")
    if VV !== nothing
        return VV
    end
    VV = StrojniSoucasti._materialyNactiDB(db, "name_CSN", name, "ČSN", "pryz")
    if VV !== nothing
        return VV
    end
    if VV !== nothing
        return VV
    end
    VV = StrojniSoucasti._materialyNactiDB(db, "name_CSN", name, "ČSN", "nezelezne kovy")
    if VV !== nothing
        return VV
    end
    VV = StrojniSoucasti._materialyNactiDB(db, "name_CSN", name, "ČSN", "plasty")
    if VV !== nothing
        return VV
    end
    return nothing
end
