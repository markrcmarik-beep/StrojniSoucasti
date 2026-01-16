using TOML
db = TOML.parsefile(joinpath(@__DIR__,"src","zavity","zavityM.toml"))
println("Keys: ", keys(db))
for k in keys(db)
    println("$k => $(db[k])")
end