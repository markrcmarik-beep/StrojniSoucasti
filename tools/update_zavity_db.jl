using DBInterface
using SQLite

const DB_PATH = normpath(joinpath(@__DIR__, "..", "src", "zavity", "zavity.db"))
const MIGRATIONS_DIR = normpath(joinpath(@__DIR__, "..", "src", "zavity", "migrations"))

function sql_statements(sql::AbstractString)
    statements = String[]
    for statement in split(sql, ';')
        stripped = strip(statement)
        isempty(stripped) || push!(statements, stripped)
    end
    return statements
end

function migration_files()
    isdir(MIGRATIONS_DIR) || error("Adresář migrací neexistuje: $MIGRATIONS_DIR")
    return sort(filter(name -> endswith(name, ".sql"), readdir(MIGRATIONS_DIR)))
end

function migration_applied(db, filename::AbstractString)
    applied = false
    for _ in DBInterface.execute(
        db,
        "SELECT 1 FROM schema_migration WHERE filename = ? LIMIT 1",
        (filename,),
    )
        applied = true
    end
    return applied
end

function apply_migration!(db, filename::AbstractString)
    sql = read(joinpath(MIGRATIONS_DIR, filename), String)
    SQLite.execute(db, "BEGIN IMMEDIATE")
    try
        for statement in sql_statements(sql)
            SQLite.execute(db, statement)
        end
        DBInterface.execute(
            db,
            "INSERT INTO schema_migration (filename) VALUES (?)",
            (filename,),
        )
        SQLite.execute(db, "COMMIT")
    catch
        SQLite.execute(db, "ROLLBACK")
        rethrow()
    end
end

mkpath(dirname(DB_PATH))
db = SQLite.DB(DB_PATH)
try
    SQLite.execute(db, "PRAGMA foreign_keys = ON")
    SQLite.execute(
        db,
        """
        CREATE TABLE IF NOT EXISTS schema_migration (
            filename TEXT PRIMARY KEY,
            applied_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        """,
    )

    for filename in migration_files()
        migration_applied(db, filename) && continue
        apply_migration!(db, filename)
        println("Použita migrace: $filename")
    end
finally
    SQLite.close(db)
end
