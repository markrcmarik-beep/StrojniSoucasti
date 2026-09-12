# ver: 2026-09-12
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
        m_metric = match(RX_METRIC, oznaceni)
        D = m_metric.captures[1] # first capture group is the diameter
        p = m_metric.captures[2] # second capture group is the pitch (stoupání)
        if p === nothing
            klic = ("M$D")
            result1 = DBInterface.execute(
                db,
                "SELECT stoupani FROM metric_vychozi WHERE zavit = ?", (klic,)
            )
            if isempty(result1)
                SQLite.close(db)
                return nothing
            end
            row1 = first(result1) # Get the first row and first column
            p = row1.stoupani # Get the first row and first column
        end
            klic = replace("M$D x $p", " " => "")
            result = DBInterface.execute(
                db,
                "SELECT d, p_norm, klic FROM zavit WHERE klic = ?", (klic,)
            )
            if isempty(result)
                SQLite.close(db)
                return nothing
            end
            row = first(result) # Get the first row and first column
            d = row.d # Get the first row and first column
            p_val = row.p_norm # Get the first row and second column
            nazv = row.klic
    elseif match(RX_TRAPEZ, oznaceni) !== nothing
        m_trapez = match(RX_TRAPEZ, oznaceni)
        D = m_trapez.captures[1] # first capture group is the diameter
        p = m_trapez.captures[2] # second capture group is the pitch (stoupání)
        if p !== nothing
            klic = replace("Tr$D x $p", " " => "")
        else
            return nothing # označení musí obsahovat stoupání pro trapezový závit, jinak vracíme nothing
        end
                    result = DBInterface.execute(
                db,
                "SELECT d, p_norm, klic FROM zavit WHERE klic = ?", (klic,)
            )
            if isempty(result)
                SQLite.close(db)
                return nothing
            end
            row = first(result) # Get the first row and first column
            d = row.d # Get the first row and first column
            p_val = row.p_norm # Get the first row and second column
            nazv = row.klic
    else
        return nothing
    end

        vysledek = Dict{Symbol, Any}(
            :name => nazv,
            :name_info => "označení závitu",
            :d => d,
            :d_info => "průměr závitu",
            :p => p_val,
            :p_info => "stoupání závitu",
        )
        SQLite.close(db)
        return vysledek
end
