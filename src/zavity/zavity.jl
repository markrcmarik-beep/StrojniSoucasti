# ver: 2026-09-11
## Funkce: zavity()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/zavity/zavity.jl
## Použité balíčky:
# SQLite
# DBInterface
## Použité uživatelské funkce:
#
###############################################################
## Použité proměnné vnitřní:
#
using DBInterface
using SQLite
"""
$(read(joinpath(@__DIR__, "..", "..", "docs", "src", "zavity", "zavity.md"), String))
"""
function zavity(oznaceni::AbstractString)
    oznaceni = replace(oznaceni, "," => ".")
    RX_METRIC = r"^(?:[mM])(\d+(?:\.\d+)?)(?:[xX](\d+(?:\.\d+)?))?$"
    RX_TRAPEZ = r"^(?:TR|Tr|tR|tr)(\d+(?:\.\d+)?)(?:[xX](\d+(?:\.\d+)?))?$"
    # detect type: metric, trapezoidal, pipe (trubkový) or unknown
    db = nothing
    # use the compiled regex values directly
    db_path = joinpath(@__DIR__, "zavity.db") # Path to the database file
    isfile(db_path) || error("Databáze závitů nebyla nalezena: $db_path") # Check if the database file exists
    db = SQLite.DB(db_path) # Načte databázi závitů, pokud ještě nebyla načtena
    if match(RX_METRIC, oznaceni) !== nothing
        db = get_zavity_db("M") # Načte databázi M až zde, pokud ještě nebyla načtena
        m_metric = match(RX_METRIC, oznaceni)
        D = m_metric.captures[1] # first capture group is the diameter
        p = m_metric.captures[2] # second capture group is the pitch (stoupání)
        if p === nothing
            klic = ("M$D")
        else
            klic = replace("M$D x $p", " " => "")
        end
    elseif match(RX_TRAPEZ, oznaceni) !== nothing
        db = get_zavity_db("Tr") # Načte databázi TR až zde, pokud ještě nebyla načtena
        m_trapez = match(RX_TRAPEZ, oznaceni)
        D = m_trapez.captures[1] # first capture group is the diameter
        p = m_trapez.captures[2] # second capture group is the pitch (stoupání)
        if p !== nothing
            klic = replace("Tr$D x $p", " " => "")
            key = ("Tr$D")
        else
            return nothing # označení musí obsahovat stoupání pro trapezový závit, jinak vracíme nothing
        end
    else
        return nothing
    end

    metric = match(RX_METRIC, oznaceni)
    trapez = match(RX_TRAPEZ, oznaceni)
    metric === nothing && trapez === nothing && return nothing

    db_path = joinpath(@__DIR__, "zavity.db")
    isfile(db_path) || error("Databáze závitů nebyla nalezena: $db_path")

    db = SQLite.DB(db_path)
    try
        d = nothing
        p_val = nothing
        name = nothing
        split_schema = !isempty(collect(DBInterface.execute(
            db,
            "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'zavit_m' LIMIT 1",
        )))

        if metric !== nothing
            d_text, p_text = metric.captures
            klic = "M$d_text"

            if p_text === nothing
                query = DBInterface.execute(
                    db,
                    split_schema ?
                    """
                    SELECT d, p_norm FROM zavit_m WHERE klic = ? LIMIT 1
                    """ :
                    """
                    SELECT d, p_norm FROM zavit WHERE klic = ? AND druh = 'M' LIMIT 1
                    """,
                    (klic,),
                )
                for row in query
                    d = Float64(row.d)
                    p_val = Float64(row.p_norm)
                    name = klic
                    break
                end
            else
                p_val = parse(Float64, p_text)
                query = DBInterface.execute(
                    db,
                    split_schema ?
                    """
                    SELECT m.d FROM zavit_m AS m
                    INNER JOIN zavit_m_stoupani AS s ON s.zavit_id = m.id
                    WHERE m.klic = ? AND s.p = ? LIMIT 1
                    """ :
                    """
                    SELECT z.d FROM zavit AS z
                    INNER JOIN zavit_stoupani AS s ON s.zavit_id = z.id
                    WHERE z.klic = ? AND z.druh = 'M' AND s.p = ? LIMIT 1
                    """,
                    (klic, p_val),
                )
                for row in query
                    d = Float64(row.d)
                    name = "$klic" * "x$p_text"
                    break
                end
            end
        else
            d_text, p_text = trapez.captures
            p_text === nothing && return nothing

            p_val = parse(Float64, p_text)
            klic = "Tr$(d_text)x$(p_text)"
            query = DBInterface.execute(
                db,
                split_schema ?
                """
                SELECT d FROM zavit_tr WHERE klic = ? AND p = ? LIMIT 1
                """ :
                """
                SELECT z.d FROM zavit AS z
                INNER JOIN zavit_stoupani AS s ON s.zavit_id = z.id
                WHERE z.klic = ? AND z.druh = 'Tr' AND s.p = ? LIMIT 1
                """,
                (klic, p_val),
            )
            for row in query
                d = Float64(row.d)
                name = klic
                break
            end
        end

        d === nothing && return nothing
        return Dict{Symbol, Any}(
            :name => name,
            :name_info => "označení závitu",
            :d => d,
            :d_info => "průměr závitu",
            :p => p_val,
            :p_info => "stoupání závitu",
        )
    finally
        SQLite.close(db)
    end
end
