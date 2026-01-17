
function lookup_toml(db::Dict{String,Any}, key::AbstractString)
    haskey(db, key) || error("Položka '$key' nebyla nalezena.")

    row = db[key]

    return DbRecord(
        key,
        row["d"],
        get(row, "p", nothing),
        Dict(Symbol(k) => v for (k,v) in row if k ∉ ("d","p"))
    )
end
