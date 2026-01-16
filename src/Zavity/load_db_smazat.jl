
using TOML

const ZAVITY_DB = TOML.parsefile(joinpath(@__DIR__, "zavityM.toml"))
println("Loaded ZAVITY_DB keys: ", keys(ZAVITY_DB))
